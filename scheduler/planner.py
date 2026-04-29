import datetime
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import crud
from model import predict

def obtener_disponibilidad_dia(fecha_iso, eventos):
    """Retorna franjas libres (horas 8 a 22) quitando eventos fijos y ocasionales."""
    franjas = set(range(8, 23))
    for ev in eventos:
        if ev['inicio'].startswith(fecha_iso):
            ini_h = int(ev['inicio'].split('T')[1].split(':')[0])
            fin_h = int(ev['fin'].split('T')[1].split(':')[0])
            for h in range(ini_h, fin_h):
                franjas.discard(h)
    return sorted(list(franjas))

def capacidad_diaria_recomendada():
    df = crud.obtener_historial_para_entrenamiento()
    if len(df) == 0:
        return 240 # Fallback 4h
    return int(df['duracion'].quantile(0.80))

def generar_sesiones_proyecto(proyecto):
    sesiones = []
    restante = proyecto['duracion_total'] - (proyecto['progreso'] * proyecto['duracion_total'])
    while restante > 0:
        d = min(45, restante) # Bloques de 45 min
        sesiones.append({'id_proyecto': proyecto['id'], 'duracion': d})
        restante -= d
    return sesiones

def planificar_semana(fecha_inicio_iso):
    actividades = crud.obtener_actividades_pendientes()
    manuales = crud.obtener_planificacion_actual()
    
    # Filtrar actividades que ya están planeadas manualmente
    id_manuales = [m['actividad_id'] for m in manuales if m['manual'] == 1]
    actividades = [a for a in actividades if a['id'] not in id_manuales]
    
    actividades.sort(key=lambda x: (x['prioridad'], x.get('deadline') or '9999-12-31'))
    
    energia = crud.obtener_ultimo_estado_energia()
    capacidad = capacidad_diaria_recomendada()
    inicio = datetime.date.fromisoformat(fecha_inicio_iso)
    
    asignaciones = []
    
    for i in range(7):
        dia = inicio + datetime.timedelta(days=i)
        dia_iso = dia.isoformat()
        eventos = crud.obtener_eventos_entre_fechas(f"{dia_iso}T00:00:00", f"{dia_iso}T23:59:59")
        libres = obtener_disponibilidad_dia(dia_iso, eventos)
        
        # Quitar slots ocupados por manuales
        for m in manuales:
            if m['dia_iso'] == dia_iso:
                if m['hora_inicio'] in libres:
                    libres.remove(m['hora_inicio'])

        ocupado = 0
        for act in list(actividades):
            if ocupado + act['duracion_estimada'] > capacidad: continue
            if not libres: break
            
            tarea = {'duracion': act['duracion_estimada'], 'categoria': act['categoria'], 'energia': energia, 'dia_semana': dia.weekday()}
            mejor_hora, _ = predict.recomendar_horario(tarea, libres)
            
            if mejor_hora is not None:
                asignaciones.append({
                    'actividad_id': act['id'], 'nombre': act['nombre'], 
                    'dia_iso': dia_iso, 'hora_inicio': mejor_hora, 
                    'duracion': act['duracion_estimada'], 'tipo': 'actividad', 
                    'categoria': act['categoria'], 'manual': 0
                })
                libres.remove(mejor_hora)
                ocupado += act['duracion_estimada']
                actividades.remove(act)
    
    for act in actividades: # Forzadas
        asignaciones.append({
            'actividad_id': act['id'], 'nombre': act['nombre'] + " [FUERA DE PLAZO]", 
            'dia_iso': fecha_inicio_iso, 'hora_inicio': 23, 
            'duracion': act['duracion_estimada'], 'tipo': 'forzado', 
            'categoria': act['categoria'], 'manual': 0
        })
        
    crud.guardar_planificacion(asignaciones)
    return crud.obtener_planificacion_actual()
