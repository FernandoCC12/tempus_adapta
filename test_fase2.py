import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from model import predict

def run_test():
    print("Iniciando prueba de Fase 2...")
    
    tarea = {
        'duracion': 60,
        'categoria': 'estudio',
        'energia': 2,
        'dia_semana': 3
    }
    
    franjas = [8, 12, 16, 20]
    print(f"Buscando mejor horario para la tarea en franjas {franjas}...")
    
    mejor_hora, prob = predict.recomendar_horario(tarea, franjas)
    
    print(f"Mejor hora recomendada: {mejor_hora}:00 con probabilidad de éxito del {prob:.2%}")
    print("\n¡Prueba de Fase 2 exitosa!")

if __name__ == "__main__":
    run_test()
