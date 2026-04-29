import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import datetime
import uvicorn

from database import db, crud
from scheduler import planner
from model import predict, train

app = FastAPI(title="Tempus Adapta API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

class ActividadCreate(BaseModel):
    nombre: str
    duracion_estimada: int
    prioridad: int
    deadline: str
    categoria: str

class CompletarBody(BaseModel):
    duracion_real: int
    energia: int

class EstadoBody(BaseModel):
    energia: int

class ReubicarBody(BaseModel):
    actividad_id: int
    nueva_hora: int
    nuevo_dia_iso: str

class ProyectoCreate(BaseModel):
    nombre: str
    duracion_total: int
    prioridad: int

class EventoFijoCreate(BaseModel):
    nombre: str
    inicio: str
    fin: str
    recurrencia: str

class EventoOcasionalCreate(BaseModel):
    nombre: str
    inicio: str
    fin: str

class RecordatorioCreate(BaseModel):
    nombre: str
    fecha_hora: str

@app.on_event("startup")
def startup_event():
    db.init_db()
    if not os.path.exists(os.path.join(train.MODEL_DIR, "model.pkl")):
        train.train_model()

@app.get("/planificacion")
def get_planificacion(fecha: str):
    return planner.planificar_semana(fecha)

@app.get("/sugerencia")
def get_sugerencia(duracion: int, categoria: str, energia: int, dia_semana: int, franjas: str):
    franjas_list = [int(x) for x in franjas.split(",")]
    tarea = {"duracion": duracion, "categoria": categoria, "energia": energia, "dia_semana": dia_semana}
    hora, prob = predict.recomendar_horario(tarea, franjas_list)
    return {"hora": hora, "probabilidad": prob}

@app.post("/actividad")
def post_actividad(act: ActividadCreate):
    crud.agregar_actividad(act.nombre, act.duracion_estimada, act.prioridad, act.deadline, act.categoria)
    return planner.planificar_semana(datetime.date.today().isoformat())

@app.post("/completar/{id}")
def post_completar(id: int, body: CompletarBody):
    crud.registrar_completado(id, body.duracion_real, body.energia)
    return planner.planificar_semana(datetime.date.today().isoformat())

@app.post("/reubicar")
def post_reubicar(body: ReubicarBody):
    crud.reubicar_en_planificacion(body.actividad_id, body.nueva_hora, body.nuevo_dia_iso)
    return planner.planificar_semana(datetime.date.today().isoformat())

@app.post("/estado")
def post_estado(body: EstadoBody):
    crud.guardar_estado_energia(body.energia)
    return {"message": "Estado guardado"}

@app.post("/proyecto")
def post_proyecto(p: ProyectoCreate):
    pid = crud.agregar_proyecto(p.nombre, p.duracion_total, p.prioridad)
    proyecto = {"id": pid, "nombre": p.nombre, "duracion_total": p.duracion_total, "progreso": 0.0, "prioridad": p.prioridad}
    sesiones = planner.generar_sesiones_proyecto(proyecto)
    
    # Agregar sesiones como actividades individuales
    for i, s in enumerate(sesiones):
        crud.agregar_actividad(
            nombre=f"{p.nombre} (Sesión {i+1})",
            duracion_estimada=s['duracion'],
            prioridad=p.prioridad,
            deadline="", # Proyectos se planifican sin deadline fijo por sesión
            categoria="trabajo",
            proyecto_id=pid
        )
    
    return {"id": pid, "sesiones_generadas": len(sesiones)}

@app.get("/proyectos")
def get_proyectos():
    return crud.obtener_proyectos()

@app.post("/evento_fijo")
def post_evento_fijo(e: EventoFijoCreate):
    crud.agregar_evento_fijo(e.nombre, e.inicio, e.fin, e.recurrencia)
    return {"message": "Evento fijo creado"}

@app.post("/evento_ocasional")
def post_evento_ocasional(e: EventoOcasionalCreate):
    crud.agregar_evento_ocasional(e.nombre, e.inicio, e.fin)
    return {"message": "Evento ocasional creado"}

@app.post("/recordatorio")
def post_recordatorio(r: RecordatorioCreate):
    crud.agregar_recordatorio(r.nombre, r.fecha_hora)
    return {"message": "Recordatorio creado"}

@app.get("/recordatorios")
def get_recordatorios():
    return crud.obtener_recordatorios()

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
