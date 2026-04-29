# Tempus Adapta

La aplicación consiste en un planificador de tiempo inteligente diseñado para optimizar la organización personal mediante el uso de IA. A diferencia de un calendario convencional, el sistema analiza el historial de cumplimiento y los niveles de energía del usuario para sugerir los momentos más adecuados para realizar cada tarea.

## Funcionalidades principales

### 🧠 Planificación Inteligente
- **Motor de Recomendación:** Utiliza un modelo de Random Forest para calcular la probabilidad de éxito de una tarea en diferentes franjas horarias.
- **Balanceo Energía-Prioridad:** El algoritmo decide si asignar una tarea crítica o una ligera dependiendo de tu estado de ánimo y energía actual.
- **Ajuste por Historial:** La IA aprende cuánto tardas realmente en ciertas categorías y corrige tus estimaciones futuras de forma automática.

### 📊 Gestión de Proyectos y Tareas
- **Desglose Proactivo:** Divide proyectos grandes en sesiones de trabajo y ajusta su frecuencia automáticamente según el tiempo restante para el deadline.
- **Seguimiento de Progreso:** Visualización en tiempo real del porcentaje de avance de cada proyecto activo.

### 🔔 Notificaciones y Alertas Inteligentes
- **Protección del Sueño:** El sistema respeta tus horas de descanso y envía alertas si detecta que trasnochas y tienes compromisos temprano al día siguiente.

### 📅 Agenda Dinámica
- **Liberación de Espacios (Early Release):** Si una clase o reunión termina antes, puedes liberarla para que la IA replanifique inmediatamente y aproveches ese tiempo extra.
- **Reorganización por Incumplimiento:** Si no marcas una tarea como completada, el sistema la desplaza automáticamente al siguiente espacio disponible.

## Tecnologías utilizadas
- **Backend:** Python con FastAPI y SQLite.
- **Inteligencia Artificial:** Scikit-learn (Random Forest Classifier), Pandas y NumPy.
- **Frontend:** Flutter (Dart) con Material Design 3.

## Estructura del Proyecto

El código está organizado para separar la lógica de IA del backend y la interfaz móvil:

- **`/lib`**: Contiene todo el código fuente de Flutter (Frontend).
  - `/screens`: Pantallas principales (Home, Agregar actividad, Proyectos, etc.).
  - `/services`: Lógica de conexión con la API y notificaciones locales.
  - `/widgets`: Componentes visuales reutilizables (bloques de actividad, barras de progreso).
  - `/models`: Definición de las clases de datos (tareas, proyectos, planeación).
- **`main.py`**: Punto de entrada del Backend (FastAPI). Define los endpoints de la API.
- **`/database`**: Lógica de base de datos SQLite y funciones CRUD.
- **`/model`**: Implementación de la Inteligencia Artificial (entrenamiento y predicción).
- **`/scheduler`**: Motor de planificación que organiza la agenda semanal.
- **`requirements.txt`**: Lista de dependencias de Python necesarias.
- **`pubspec.yaml`**: Configuración de dependencias y assets de Flutter.

## Configuración y ejecución

### Backend
1. Activar el entorno virtual:
   ```bash
   source venv/bin/activate  # Linux/Mac
   .\venv\Scripts\activate   # Windows
   ```
2. Ejecutar: `python main.py`

### Frontend
1. Obtener paquetes: `flutter pub get`
2. Ejecutar: `flutter run`

---
**Nota:** El sistema incluye un modelo base pre-entrenado para ser funcional desde el primer uso mientras construye tu historial personal.
