from database.db import get_db_connection
import pandas as pd
import datetime

# ── Actividades ───────────────────────────────────────────────────────────────

def agregar_actividad(nombre, duracion_estimada, prioridad, deadline, categoria, proyecto_id=None):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO actividades (nombre, duracion_estimada, prioridad, deadline, categoria, estado, proyecto_id) "
        "VALUES (?, ?, ?, ?, ?, 'pendiente', ?)",
        (nombre, duracion_estimada, prioridad, deadline, categoria, proyecto_id)
    )
    conn.commit()
    act_id = cur.lastrowid
    conn.close()
    return act_id

def obtener_actividades_pendientes():
    conn = get_db_connection()
    rows = conn.execute("SELECT * FROM actividades WHERE estado='pendiente'").fetchall()
    conn.close()
    return [dict(r) for r in rows]

def registrar_completado(id_actividad, duracion_real, energia):
    conn = get_db_connection()
    ahora = datetime.datetime.now()
    
    # Obtener info de la actividad antes de marcarla
    act = conn.execute("SELECT proyecto_id FROM actividades WHERE id=?", (id_actividad,)).fetchone()
    
    conn.execute("UPDATE actividades SET estado='completado' WHERE id=?", (id_actividad,))
    conn.execute(
        "INSERT INTO historial_completado "
        "(id_actividad, fecha_asignada, hora_asignada, duracion_real, completado, energia_usuario) "
        "VALUES (?, ?, ?, ?, 1, ?)",
        (id_actividad, ahora.strftime('%Y-%m-%d'), ahora.hour, duracion_real, energia)
    )
    
    if act and act['proyecto_id']:
        pid = act['proyecto_id']
        total = conn.execute("SELECT duracion_total FROM proyectos WHERE id=?", (pid,)).fetchone()['duracion_total']
        completado = conn.execute(
            "SELECT SUM(duracion_estimada) as done FROM actividades WHERE proyecto_id=? AND estado='completado'", 
            (pid,)
        ).fetchone()['done'] or 0
        progreso = min(1.0, completado / total)
        conn.execute("UPDATE proyectos SET progreso=? WHERE id=?", (progreso, pid))
        
    conn.commit()
    conn.close()

def obtener_historial_para_entrenamiento():
    conn = get_db_connection()
    query = '''
        SELECT h.hora_asignada AS hora, h.duracion_real AS duracion,
               a.categoria, h.energia_usuario AS energia,
               CAST(strftime('%w', h.fecha_asignada) AS INTEGER) AS dia_semana,
               h.completado
        FROM historial_completado h
        JOIN actividades a ON h.id_actividad = a.id
    '''
    df = pd.read_sql_query(query, conn)
    conn.close()
    return df

# ── Proyectos ─────────────────────────────────────────────────────────────────

def agregar_proyecto(nombre, duracion_total, prioridad):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO proyectos (nombre, duracion_total, progreso, prioridad, estado) VALUES (?,?,0.0,?,'activo')",
        (nombre, duracion_total, prioridad)
    )
    conn.commit()
    pid = cur.lastrowid
    conn.close()
    return pid

def obtener_proyectos():
    conn = get_db_connection()
    rows = conn.execute("SELECT * FROM proyectos").fetchall()
    conn.close()
    return [dict(r) for r in rows]

def actualizar_progreso_proyecto(id_proyecto, progreso):
    conn = get_db_connection()
    conn.execute("UPDATE proyectos SET progreso=? WHERE id=?", (progreso, id_proyecto))
    conn.commit()
    conn.close()

# ── Eventos ───────────────────────────────────────────────────────────────────

def agregar_evento_fijo(nombre, inicio, fin, recurrencia):
    conn = get_db_connection()
    conn.execute(
        "INSERT INTO eventos_fijos (nombre, inicio, fin, recurrencia) VALUES (?,?,?,?)",
        (nombre, inicio, fin, recurrencia)
    )
    conn.commit()
    conn.close()

def agregar_evento_ocasional(nombre, inicio, fin):
    conn = get_db_connection()
    conn.execute(
        "INSERT INTO eventos_ocasionales (nombre, inicio, fin) VALUES (?,?,?)",
        (nombre, inicio, fin)
    )
    conn.commit()
    conn.close()

def obtener_eventos_entre_fechas(fecha_inicio, fecha_fin):
    conn = get_db_connection()
    ocasionales = conn.execute(
        "SELECT nombre, inicio, fin, 'ocasional' AS tipo FROM eventos_ocasionales "
        "WHERE inicio >= ? AND fin <= ?", (fecha_inicio, fecha_fin)
    ).fetchall()
    fijos = conn.execute(
        "SELECT nombre, inicio, fin, 'fijo' AS tipo FROM eventos_fijos"
    ).fetchall()
    conn.close()
    return [dict(r) for r in ocasionales] + [dict(r) for r in fijos]

# ── Energía ───────────────────────────────────────────────────────────────────

def guardar_estado_energia(energia):
    conn = get_db_connection()
    conn.execute(
        "INSERT INTO estados_subjetivos (timestamp, energia) VALUES (?,?)",
        (datetime.datetime.now().isoformat(), energia)
    )
    conn.commit()
    conn.close()

def obtener_ultimo_estado_energia():
    conn = get_db_connection()
    row = conn.execute(
        "SELECT energia FROM estados_subjetivos ORDER BY id DESC LIMIT 1"
    ).fetchone()
    conn.close()
    return row['energia'] if row else 1

# ── Recordatorios ─────────────────────────────────────────────────────────────

def agregar_recordatorio(nombre, fecha_hora):
    conn = get_db_connection()
    conn.execute(
        "INSERT INTO recordatorios (nombre, fecha_hora, notificado) VALUES (?,?,0)",
        (nombre, fecha_hora)
    )
    conn.commit()
    conn.close()

def obtener_recordatorios():
    conn = get_db_connection()
    rows = conn.execute("SELECT * FROM recordatorios ORDER BY fecha_hora ASC").fetchall()
    conn.close()
    return [dict(r) for r in rows]

# ── Planificación actual ──────────────────────────────────────────────────────

def guardar_planificacion(asignaciones):
    conn = get_db_connection()
    # Solo borramos lo que NO es manual
    conn.execute("DELETE FROM planificacion_actual WHERE manual = 0")
    for a in asignaciones:
        conn.execute(
            "INSERT INTO planificacion_actual "
            "(actividad_id, nombre, dia_iso, hora_inicio, duracion, tipo, categoria, manual) "
            "VALUES (?,?,?,?,?,?,?,?)",
            (a.get('actividad_id'), a['nombre'], a['dia_iso'],
             a['hora_inicio'], a['duracion'], a['tipo'], a.get('categoria', ''), a.get('manual', 0))
        )
    conn.commit()
    conn.close()

def reubicar_en_planificacion(actividad_id, nueva_hora, nuevo_dia_iso):
    conn = get_db_connection()
    conn.execute(
        "UPDATE planificacion_actual SET hora_inicio=?, dia_iso=?, manual=1 WHERE actividad_id=?",
        (nueva_hora, nuevo_dia_iso, actividad_id)
    )
    conn.commit()
    conn.close()

def obtener_planificacion_actual():
    conn = get_db_connection()
    rows = conn.execute("SELECT * FROM planificacion_actual").fetchall()
    conn.close()
    return [dict(r) for r in rows]
