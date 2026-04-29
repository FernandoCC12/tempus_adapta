import os
import pickle
import numpy as np
import pandas as pd
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split

import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from database import crud

MODEL_DIR = os.path.join(os.path.dirname(__file__), "model_data")
CATEGORIAS = ['trabajo', 'estudio', 'personal', 'ocio']

def _sin_cos_hora(hora_series):
    h = np.array(hora_series, dtype=float)
    return np.sin(2 * np.pi * h / 24.0), np.cos(2 * np.pi * h / 24.0)

def _generar_sinteticos(n=120):
    np.random.seed(42)
    horas = np.random.randint(0, 24, n)
    duraciones = np.random.randint(15, 180, n)
    categorias = np.random.choice(CATEGORIAS, n)
    energias = np.random.randint(0, 3, n)
    dias = np.random.randint(0, 7, n)
    completados = []
    for h, d, c, e in zip(horas, duraciones, categorias, energias):
        p = 0.5 + (e - 1) * 0.15
        if 8 <= h <= 18 and c in ('trabajo', 'estudio'): p += 0.15
        if d > 120: p -= 0.10
        completados.append(1 if np.random.rand() < np.clip(p, 0.1, 0.9) else 0)
    return pd.DataFrame({
        'hora': horas, 'duracion': duraciones, 'categoria': categorias,
        'energia': energias, 'dia_semana': dias, 'completado': completados
    })

def train_model():
    df = crud.obtener_historial_para_entrenamiento()
    if len(df) < 50:
        print("[train] Datos < 50. Usando datos sintéticos.")
        df = _generar_sinteticos()

    hora_sin, hora_cos = _sin_cos_hora(df['hora'])
    df = df.copy()
    df['hora_sin'] = hora_sin
    df['hora_cos'] = hora_cos

    scaler = StandardScaler()
    df['duracion_esc'] = scaler.fit_transform(df[['duracion']])

    encoder = LabelEncoder()
    encoder.classes_ = np.array(CATEGORIAS)
    df['categoria_enc'] = encoder.transform(df['categoria'])

    features = ['hora_sin', 'hora_cos', 'duracion_esc', 'categoria_enc', 'energia', 'dia_semana']
    X = df[features]
    y = df['completado']

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X_train, y_train)
    print(f"[train] Exactitud test: {model.score(X_test, y_test):.2f}")

    os.makedirs(MODEL_DIR, exist_ok=True)
    joblib.dump(model, os.path.join(MODEL_DIR, "model.pkl"))
    joblib.dump(scaler, os.path.join(MODEL_DIR, "scaler.pkl"))
    joblib.dump(encoder, os.path.join(MODEL_DIR, "encoder.pkl"))
    print("[train] Modelo guardado en model_data/")

if __name__ == "__main__":
    train_model()
