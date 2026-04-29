import os
import numpy as np
import pandas as pd
import joblib

import sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from model.train import MODEL_DIR, _sin_cos_hora

def predecir_probabilidad(hora, duracion, categoria, energia, dia_semana):
    model = joblib.load(os.path.join(MODEL_DIR, "model.pkl"))
    scaler = joblib.load(os.path.join(MODEL_DIR, "scaler.pkl"))
    encoder = joblib.load(os.path.join(MODEL_DIR, "encoder.pkl"))

    hora_sin, hora_cos = _sin_cos_hora(np.array([hora]))
    dur_esc = scaler.transform([[duracion]])[0][0]
    cat_enc = encoder.transform([categoria])[0]
    
    features = pd.DataFrame([{
        'hora_sin': hora_sin[0], 'hora_cos': hora_cos[0], 
        'duracion_esc': dur_esc, 'categoria_enc': cat_enc, 
        'energia': energia, 'dia_semana': dia_semana
    }])
    
    prob = model.predict_proba(features)[0][1] # prob de clase 1 (completado)
    return float(prob)

def recomendar_horario(tarea: dict, franjas: list) -> tuple:
    mejor_hora = None
    mejor_prob = -1.0
    for h in franjas:
        prob = predecir_probabilidad(h, tarea['duracion'], tarea['categoria'], tarea['energia'], tarea['dia_semana'])
        if prob > mejor_prob:
            mejor_prob = prob
            mejor_hora = h
    return mejor_hora, mejor_prob
