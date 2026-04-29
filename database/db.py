import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "tempus.db")

def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    c = conn.cursor()
    c.executescript('''
        CREATE TABLE IF NOT EXISTS actividades (
            id INTEGER PRIMARY KEY, nombre TEXT, duracion_estimada INTEGER,
            prioridad INTEGER, deadline TEXT, categoria TEXT, estado TEXT,
            proyecto_id INTEGER
        );
        CREATE TABLE IF NOT EXISTS proyectos (
            id INTEGER PRIMARY KEY, nombre TEXT, duracion_total INTEGER,
            progreso REAL, prioridad INTEGER, estado TEXT
        );
        CREATE TABLE IF NOT EXISTS sesiones_proyecto (
            id INTEGER PRIMARY KEY, id_proyecto INTEGER, duracion INTEGER,
            completado INTEGER, fecha_asignada TEXT
        );
        CREATE TABLE IF NOT EXISTS eventos_fijos (
            id INTEGER PRIMARY KEY, nombre TEXT, inicio TEXT, fin TEXT, recurrencia TEXT
        );
        CREATE TABLE IF NOT EXISTS eventos_ocasionales (
            id INTEGER PRIMARY KEY, nombre TEXT, inicio TEXT, fin TEXT
        );
        CREATE TABLE IF NOT EXISTS recordatorios (
            id INTEGER PRIMARY KEY, nombre TEXT, fecha_hora TEXT, notificado INTEGER
        );
        CREATE TABLE IF NOT EXISTS historial_completado (
            id INTEGER PRIMARY KEY, id_actividad INTEGER, fecha_asignada TEXT,
            hora_asignada INTEGER, duracion_real INTEGER, completado INTEGER,
            energia_usuario INTEGER
        );
        CREATE TABLE IF NOT EXISTS estados_subjetivos (
            id INTEGER PRIMARY KEY, timestamp TEXT, energia INTEGER
        );
        CREATE TABLE IF NOT EXISTS planificacion_actual (
            id INTEGER PRIMARY KEY, actividad_id INTEGER, nombre TEXT,
            dia_iso TEXT, hora_inicio INTEGER, duracion INTEGER,
            tipo TEXT, categoria TEXT, manual INTEGER DEFAULT 0
        );
    ''')
    conn.commit()
    conn.close()

init_db()
