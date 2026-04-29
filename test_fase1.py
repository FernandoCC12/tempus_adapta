import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from database import crud

def run_test():
    print("Iniciando prueba de Fase 1...")
    
    # 1. Insertar actividad
    act_id = crud.agregar_actividad(
        nombre="Aprender Flutter",
        duracion_estimada=120,
        prioridad=1,
        deadline="2024-12-31",
        categoria="estudio"
    )
    print(f"Actividad insertada con ID: {act_id}")
    
    # 2. Completar actividad
    crud.registrar_completado(id_actividad=act_id, duracion_real=110, energia=2)
    print("Actividad marcada como completada en el historial.")
    
    # 3. Obtener historial como DataFrame
    df = crud.obtener_historial_para_entrenamiento()
    
    print("\nDataFrame de Historial:")
    print(df)
    
    assert not df.empty, "El DataFrame del historial está vacío."
    print("\n¡Prueba de Fase 1 exitosa!")

if __name__ == "__main__":
    run_test()
