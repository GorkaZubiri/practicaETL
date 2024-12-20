# Análisis del Rendimiento de Jugadores de la Premier League 23/24

## Propósitos y Objetivos del Proyecto

El propósito de este proyecto es analizar el rendimiento de los jugadores de la Premier League en la temporada 23/24, centrándonos en sus posiciones y nacionalidades. Buscamos responder preguntas como:

- ¿Qué nacionalidades destacan en ciertas posiciones?
- ¿Quiénes son los jugadores más sobresalientes en cada posición?

Los objetivos específicos incluyen:

- Clasificar a los jugadores por posición y asignarles una métrica que mida su desempeño.
- Identificar las nacionalidades que sobresalen en ciertas posiciones.
- Comparar el rendimiento de los jugadores según su posición, considerando tanto sus estadísticas individuales como el club al que pertenecen.
- Extraer conclusiones útiles para equipos, entrenadores y analistas de la Premier League.

## Dataset

Los datasets utilizados en este trabajo provienen de Kaggle, una plataforma muy reconocida. Elegimos los datasets **‘Premier League Player Stats 23/24’** porque encajan perfectamente con los objetivos del proyecto. Estos datasets contienen dos archivos:

- **`players_overview`**: Información general sobre los jugadores.
- **`players_stats`**: Estadísticas detalladas de rendimiento de los jugadores.

Ambos datasets están en formato CSV, un formato ampliamente utilizado, fácil de manipular y compatible con casi todas las herramientas de análisis de datos.

## Scripts del Proyecto

Este proyecto está compuesto por tres scripts principales:

1. **Extract**: Código que realiza la extracción de datos.
2. **Transform**: Código encargado de la transformación de los datos.
3. **Load**: Código que carga los datos transformados en el sistema de destino.