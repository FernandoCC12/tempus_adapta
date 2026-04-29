import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from database import crud
from scheduler import planner
import datetime

def run_test():
    print("Iniciando prueba de Fase 3...")
    
    hoy_iso = datetime.date.today().isoformat()
    
    # Insertar 2 actividades
    crud.agregar_actividad("Estudiar ML", 120, 2, hoy_iso, "estudio")
    crud.agregar_actividad("Hacer deporte", 60, 3, hoy_iso, "personal")
    
    # Insertar 1 evento fijo para hoy
    crud.agregar_evento_fijo("Reunión trabajo", hoy_iso + "T10:00:00", hoy_iso + "T11:00:00", "NINGUNA")
    
    # El proyecto no lo insertamos porque no hicimos CRUD de proyectos,
    # pero podemos probar que el generar sesiones funciona
    proyecto_mock = {'id': 1, 'nombre': 'Proyecto Largo', 'duracion_total': 300, 'progreso': 0.0, 'prioridad': 1}
    sesiones = planner.generar_sesiones_proyecto(proyecto_mock)
    print(f"Sesiones generadas para proyecto: {len(sesiones)}")
    
    agenda = planner.planificar_semana(hoy_iso)
    print("\nAgenda Semanal Generada:")
    for a in agenda:
        print(f"- Día: {a['dia_iso']} Hora: {a['hora_inicio']}:00 | Actividad: {a['nombre']} ({a['duracion']} min)")
    
    assert len(agenda) >= 2, "La agenda no planificó las actividades."
    print("\n¡Prueba de Fase 3 exitosa!")

if __name__ == "__main__":
    run_test()
