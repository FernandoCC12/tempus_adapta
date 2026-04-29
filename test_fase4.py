import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from fastapi.testclient import TestClient
from main import app
import datetime

def run_tests(client):
    print("Iniciando pruebas de API REST (Fase 4)...")
    
    # 1. Crear actividad
    print("\nPOST /actividad")
    response = client.post("/actividad", json={
        "nombre": "Actividad API Test",
        "duracion_estimada": 60,
        "prioridad": 2,
        "deadline": "2024-12-31",
        "categoria": "trabajo"
    })
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    assert response.status_code == 200

    # 2. Obtener planificacion
    print("\nGET /planificacion")
    hoy = datetime.date.today().isoformat()
    response = client.get(f"/planificacion?fecha={hoy}")
    print(f"Status: {response.status_code}")
    plan = response.json()
    print(f"Items planificados: {len(plan)}")
    assert response.status_code == 200
    
    # 3. Completar actividad
    print("\nPOST /completar/1")
    response = client.post("/completar/1", json={
        "duracion_real": 50,
        "energia": 2
    })
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    assert response.status_code == 200

    # 4. Obtener sugerencia
    print("\nGET /sugerencia")
    response = client.get("/sugerencia?duracion=60&categoria=estudio&energia=2&dia_semana=1&franjas=9,10,11")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    assert response.status_code == 200

    # 5. Reubicar
    print("\nPOST /reubicar")
    response = client.post("/reubicar", json={
        "actividad_id": 1,
        "nueva_hora": 15,
        "nuevo_dia_iso": hoy
    })
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    assert response.status_code == 200

    print("\n¡Pruebas de Fase 4 exitosas! Todos los endpoints responden correctamente en JSON.")

if __name__ == "__main__":
    # Necesitamos usar el decorador startup_event manualmente si usamos TestClient
    with TestClient(app) as client:
        run_tests(client)
