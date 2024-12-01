-- El principal objetivo de este script es realizar la transformación de los datos.
-- Paso 1: Estudiar la Calidad de los Datos
-- Paso 2: Realizar la Limpieza de los Datos
-- Paso 3: Estimar la métrica de rendimiento de los jugadores 
USE MiBaseDeDatos;


-- Calidad de los Datos:

-- Primer archivo CSV: player_overview.csv
-- 1. Métrica de Precisión: Mide la cantidad de información que es correcta respecto a una fuente verificable
-- En este caso, y como se indica en el datacard de Kaggle, la información es precisa al 100% en la mayoría de los casos 
-- Los datos se han extraído mediante técnicas de web scraping y, tras realizar algunas comprobaciones, podemos confirmar que 
-- los datos reflejan con precisión lo que está disponible en la página oficial de la Premier League
-- Dado que el web scraping es una técnica consistente, al revisar algunos casos de cada columna (especialmente los más destacados), 
-- hemos verificado que la información ha sido extraída de forma adecuada
-- Sin embargo, hay un único caso a destacar relacionado con la variable 'Facebook'. A pesar de que la URL de Facebook aparece en la página, 
-- el programa no ha podido acceder para copiar la URL. Esto probablemente se deba a que Facebook bloqueó el acceso 
-- debido a múltiples intentos por segundo o a que el sistema de captcha no fue superado
-- Por tanto, la precisión de esta variable es del 0%, ya que no se ha podido extraer ninguna URL en ningún caso
-- 
-- Información adicional a tener en cuenta:
-- 1. En algunos casos, la columna 'Date_of_Birth' presenta la edad del jugador entre paréntesis, lo cual puede requerir un tratamiento adicional
-- 2. La columna 'Height' tiene un formato inválido para su uso, ya que los datos se han extraído directamente sin un tratamiento adecuado
-- 3. La columna 'Clean_sheets' solo se completa en caso de jugadores defensores o porteros, por lo que en otros casos está vacía



-- 2. Métrica de Linaje: Se evalua validando la fuente de origen
-- El linaje de los datos es correcto, ya que provienen de la página oficial de la Premier League, 
-- que es la principal fuente de estadísticas y tiene acceso directo a los datos personales de los jugadores



-- 3. Métrica de Semántica: Se refiere a determinar si los datos tienen el significado correcto o si pueden interpretarse de diferentes maneras.
-- La precisión es del 100% ya que todas las columnas tienen un único significado y no pueden variar



-- 4. Métrica de Estructura: Determinar si los datos representados tienen un patrón y estructuras válidos
-- Variables tipo texto
SELECT Name, Nationality	-- Variables alta cardinalidad
FROM TemporaryOverview o
WHERE Name REGEXP '[0-9@#$%^&*()_+=]' -- Verifica nombres con caracteres no deseados
   OR Nationality REGEXP '[0-9@#$%^&*()_+=]';

-- Al revisar los valores únicos, podemos confirmar que todos los datos siguen la estructura definida sin excepciones
SELECT DISTINCT Nationality
FROM TemporaryOverview;

SELECT DISTINCT Club
FROM TemporaryOverview;
 
SELECT DISTINCT Position
FROM TemporaryOverview;


-- Variables tipo numéricas
-- La primera verificación de la estructura consiste en comprobar la existencia de valores negativos, lo cual no es válido, como en el caso de asistencias negativas
SELECT Goals, Assists, `Clean sheets`, Appearances
FROM TemporaryOverview
WHERE Appearances < 0
   OR Goals < 0
   OR Assists < 0
   OR `Clean sheets` < 0;
  
-- La segunda comprobación es si tiene caracteres no numéricos   
SELECT *
FROM TemporaryOverview
WHERE NOT (Appearances REGEXP '^[0-9]+(\.[0-9]+)?$'
           AND Goals REGEXP '^[0-9]+(\.[0-9]+)?$'
           AND Assists REGEXP '^[0-9]+(\.[0-9]+)?$'
           AND `Clean sheets` REGEXP '^[0-9]+(\.[0-9]+)?$');
  
-- Casos especiales:
-- 'Height' sigue un patrón válido (formato 'x cm'), pero su tipo de dato actual es 'VARCHAR' cuando debería ser numérico
-- Por ello, su estructura es del 0%
-- 'Date_of_Birth' en algunos casos incluye la edad del jugador junto con la fecha de nacimiento, manteniendo la estructura 
-- correcta en el 49.71% de los casos
SELECT (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)) AS Porcentaje_estructura_fecha
FROM TemporaryOverview
WHERE LENGTH(TRIM(`Date of Birth`)) = 10 -- Asegura que tenga exactamente 10 caracteres
  AND SUBSTRING(TRIM(`Date of Birth`), 3, 1) = '/' -- Verifica que el tercer carácter sea "/"
  AND SUBSTRING(TRIM(`Date of Birth`), 6, 1) = '/' -- Verifica que el sexto carácter sea "/"
  AND `Date of Birth` REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'; -- Confirma el patrón final
  

  
-- 5. Métrica de Completitud: El grado en el que los campos están rellenados
-- La columna 'Name' es el único campo obligatorio, ya que sin ella no podemos identificar a quién corresponden los datos
SELECT *
FROM TemporaryOverview
WHERE Name IS NULL;

SELECT 'Name' AS Column_Name,
    ROUND((COUNT(Name) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) AS Completitud
FROM TemporaryOverview
WHERE Name IS NOT NULL AND Name != ''
UNION ALL
SELECT 'Nationality', 
    ROUND((COUNT(Nationality) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) 
FROM TemporaryOverview
WHERE Nationality IS NOT NULL AND Nationality != ''
UNION ALL
SELECT 'Date of Birth', 
    ROUND((COUNT(`Date of Birth`) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) 
FROM TemporaryOverview
WHERE `Date of Birth` IS NOT NULL AND `Date of Birth` != ''
UNION ALL
SELECT 'Height', 
    ROUND((COUNT(Height) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) 
FROM TemporaryOverview
WHERE Height IS NOT NULL AND Height != ''
UNION ALL
SELECT 'Club', 
    ROUND((COUNT(Club) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) 
FROM TemporaryOverview
WHERE Club IS NOT NULL AND Club != ''
UNION ALL
SELECT 'Position', 
    ROUND((COUNT(Position) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) 
FROM TemporaryOverview
WHERE Position IS NOT NULL AND Position != ''
UNION ALL
SELECT 'Appearances', 
    ROUND((COUNT(Appearances) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) 
FROM TemporaryOverview
WHERE Appearances IS NOT NULL
UNION ALL
SELECT 'Goals', 
    ROUND((COUNT(Goals) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) 
FROM TemporaryOverview
WHERE Goals IS NOT NULL
UNION ALL
SELECT 'Assists', 
    ROUND((COUNT(Assists) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) 
FROM TemporaryOverview
WHERE Assists IS NOT NULL
UNION ALL
SELECT 'Clean sheets', 
    ROUND((COUNT(`Clean sheets`) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) 
FROM TemporaryOverview
WHERE `Clean sheets` IS NOT NULL
UNION ALL
SELECT 'Facebook', 
    ROUND((COUNT(Facebook) * 100.0 / (SELECT COUNT(*) FROM TemporaryOverview)), 2) 
FROM TemporaryOverview
WHERE Facebook IS NOT NULL AND Facebook != '';



-- 6. Métrica de Consistencia: Evalúa si los datos no presentan contradicciones y son coherentes en términos de significado, estructura y formato
-- En este caso, la consistencia es similar a la de la estructura, ya que los únicos datos inconsistentes son los de 'Date of Birth'
-- En cuanto a 'Height', aunque presenta una estructura errónea, los datos son consistentes a lo largo del dataset, 
-- por lo que su consistencia se considera del 100%



-- 7. Métrica de Moneda: Evalúa la antigüedad en el contexto de uso
-- Este dataset corresponde a datos de la temporada 23/24, recopilados al finalizar dicha temporada
-- Dado que los datos son estáticos y reflejan un momento específico, no se actualizarán más



-- 8. Métrica de Puntualidad: Mide el tiempo de acceso a la información solicitada 
-- Al haber sido extraído de Kaggle, y siendo un dataset relativamente pequeño, 
-- su puntualidad es del 100%. El acceso es casi instantáneo con conexión a internet, y al no ser especialmente pesado, no presenta problemas



-- 9. Métrica de Razonabilidad: Evalúa si los valores de los datos tienen un tipo y tamaño razonables
-- Tras revisar las consultas previas, podemos concluir que la razonabilidad es adecuada en las columnas de tipo numéricas
-- Para las columnas de tipo texto, también es adecuada en su mayoría, excepto en las columnas 'Date of Birth' y 'Height', donde
-- encontramos más problemas. En este caso, la razonabilidad se ve afectada por el mismo problema de la estructura, ya que 
-- 'Date of Birth' no sigue un formato de fecha consistente y 'Height' está configurado como texto con valores en centímetros, 
-- cuando debería ser de tipo numérico



-- 10. Métrica de Identificabilidad: Evalúa el grado en que los registros de los datos son identificables de forma única y no están duplicados 
-- En este caso, solo es relevante analizarlo con la columna 'Name', ya que representa nuestro "valor único" para identificar a cada jugador.
SELECT Name, COUNT(*) AS Apariciones
FROM TemporaryOverview
GROUP BY Name
HAVING COUNT(*) != 1; 



-- Segundo archivo CSV: player_stats.csv
-- 1. Métrica de Precisión:
-- La precisión de los datos es generalmente correcta al compararlo con la página original
-- Sin embargo, el proceso de web scraping falló en algunos casos, especialmente con 'Facebook', donde no se pudo extraer ningún dato
-- También hubo problemas con otras redes sociales, posiblemente por la variabilidad en la disposición de los datos en la página
-- En 'Passes per match', los decimales están con coma (,) en lugar de punto (.), aunque en otras columnas también se usa la coma para miles

-- Redes sociales:
WITH twitter_twitter AS (
    SELECT COUNT(*) AS total_con_https_twitter
    FROM TemporaryStats
    WHERE Twitter LIKE 'https://twitter%'
)
SELECT 
    tt.total_con_https_twitter,
    (tt.total_con_https_twitter * 1.0 / 
     (SELECT COUNT(*) 
      FROM TemporaryStats
      WHERE Twitter IS NOT NULL AND Twitter != '')) AS ratio_twitter
FROM twitter_twitter tt;


WITH instagram_instagram AS (
    SELECT COUNT(*) AS total_con_https_instagram 
    FROM TemporaryStats
    WHERE Instagram LIKE 'https://twitter%'
)
SELECT 
    ii.total_con_https_instagram, 
    (ii.total_con_https_instagram * 1.0 / 
     (SELECT COUNT(*) 
      FROM TemporaryStats
      WHERE Instagram IS NOT NULL AND Instagram != '')) AS ratio_instagram
FROM instagram_instagram ii;

-- La columna 'passes_per_match' no se extrajo correctamente, ya que los números con decimales se capturaron con coma, 
-- mientras que en la página original (inglesa) se usan puntos.
SELECT 
    COUNT(*) / (SELECT COUNT(`Passes per match`) FROM TemporaryStats) AS filas_con_decimales
FROM 
    TemporaryStats
WHERE 
    `Passes per match` % 1 != 0;




-- 2. Métrica de Linaje: 
-- Como ocurre con el primer CSV el linaje de los datos es correcto, ya que provienen de la página oficial de la Premier League,
-- que es la principal fuente de estadísticas y tiene acceso directo a los datos personales de los jugadores



-- 3. Métrica de Semántica: 
-- Como ocurre con el primer CSV, la precisión es del 100% ya que todas las columnas tienen un único significado y no pueden variar


   
-- 4. Métrica de Estructura:
-- Los resultados son similares a los de precisión
-- Las redes sociales deberían seguir el patrón 'https://www.red_social', pero hay casos en los que los datos se mezclan
-- En 'Pases per match', se usa ',' en lugar de punto como debería ser
-- En los demás casos, las variables numéricas están bien rellenadas con números adecuados
SELECT Name	-- Variables alta cardinalidad 
FROM TemporaryStats
WHERE Name REGEXP '[0-9@#$%^&*()_+=]'; 



-- 5. Métrica de Completitud: 
-- Al analizar la completitud de las variables, es importante considerar que un '[NULL]' generalmente indica que la estadística no se aplica a la posición del jugador 
-- Para verificar esto, revisaremos los nulos en cada fila
-- Si varias estadísticas tienen nulos en una misma fila, es probable que esa posición no los incluya, por lo que no es un error de llenado, sino una ausencia de datos

SELECT 
    (COUNT(*) - COUNT(Name)) * 100.0 / COUNT(*) AS porcentaje_nulos_name,
    (COUNT(*) - COUNT(Appearances)) * 100.0 / COUNT(*) AS porcentaje_nulos_appearances,
    (COUNT(*) - COUNT(Goals)) * 100.0 / COUNT(*) AS porcentaje_nulos_goals,
    (COUNT(*) - COUNT(Wins)) * 100.0 / COUNT(*) AS porcentaje_nulos_wins,
    (COUNT(*) - COUNT(Losses)) * 100.0 / COUNT(*) AS porcentaje_nulos_losses,
    (COUNT(*) - COUNT(`Clean sheets`)) * 100.0 / COUNT(*) AS porcentaje_nulos_clean_sheets,
    (COUNT(*) - COUNT(`Goals Conceded`)) * 100.0 / COUNT(*) AS porcentaje_nulos_goals_conceded,
    (COUNT(*) - COUNT(Tackles)) * 100.0 / COUNT(*) AS porcentaje_nulos_tackles,
    (COUNT(*) - COUNT(`Tackle success %`)) * 100.0 / COUNT(*) AS porcentaje_nulos_tackle_success,
    (COUNT(*) - COUNT(`Last man tackles`)) * 100.0 / COUNT(*) AS porcentaje_nulos_last_man_tackles,
    (COUNT(*) - COUNT(`Blocked shots`)) * 100.0 / COUNT(*) AS porcentaje_nulos_blocked_shots,
    (COUNT(*) - COUNT(Interceptions)) * 100.0 / COUNT(*) AS porcentaje_nulos_interceptions,
    (COUNT(*) - COUNT(Clearances)) * 100.0 / COUNT(*) AS porcentaje_nulos_clearances,
    (COUNT(*) - COUNT(`Headed Clearance`)) * 100.0 / COUNT(*) AS porcentaje_nulos_headed_clearance,
    (COUNT(*) - COUNT(`Clearances off line`)) * 100.0 / COUNT(*) AS porcentaje_nulos_clearances_off_line,
    (COUNT(*) - COUNT(Recoveries)) * 100.0 / COUNT(*) AS porcentaje_nulos_recoveries,
    (COUNT(*) - COUNT(`Duels won`)) * 100.0 / COUNT(*) AS porcentaje_nulos_duels_won,
    (COUNT(*) - COUNT(`Duels lost`)) * 100.0 / COUNT(*) AS porcentaje_nulos_duels_lost,
    (COUNT(*) - COUNT(`Successful 50/50s`)) * 100.0 / COUNT(*) AS porcentaje_nulos_successful_50_50s,
    (COUNT(*) - COUNT(`Aerial battles won`)) * 100.0 / COUNT(*) AS porcentaje_nulos_aerial_battles_won,
    (COUNT(*) - COUNT(`Aerial battles lost`)) * 100.0 / COUNT(*) AS porcentaje_nulos_aerial_battles_lost,
    (COUNT(*) - COUNT(`Own goals`)) * 100.0 / COUNT(*) AS porcentaje_nulos_own_goals,
    (COUNT(*) - COUNT(`Errors leading to goal`)) * 100.0 / COUNT(*) AS porcentaje_nulos_errors_leading_to_goal,
    (COUNT(*) - COUNT(Assists)) * 100.0 / COUNT(*) AS porcentaje_nulos_assists,
    (COUNT(*) - COUNT(Passes)) * 100.0 / COUNT(*) AS porcentaje_nulos_passes,
    (COUNT(*) - COUNT(`Passes per match`)) * 100.0 / COUNT(*) AS porcentaje_nulos_passes_per_match,
    (COUNT(*) - COUNT(`Big Chances Created`)) * 100.0 / COUNT(*) AS porcentaje_nulos_big_chances_created,
    (COUNT(*) - COUNT(Crosses)) * 100.0 / COUNT(*) AS porcentaje_nulos_crosses,
    (COUNT(*) - COUNT(`Cross accuracy %`)) * 100.0 / COUNT(*) AS porcentaje_nulos_cross_accuracy,
    (COUNT(*) - COUNT(`Through balls`)) * 100.0 / COUNT(*) AS porcentaje_nulos_through_balls,
    (COUNT(*) - COUNT(`Accurate long balls`)) * 100.0 / COUNT(*) AS porcentaje_nulos_accurate_long_balls,
    (COUNT(*) - COUNT(`Yellow cards`)) * 100.0 / COUNT(*) AS porcentaje_nulos_yellow_cards,
    (COUNT(*) - COUNT(`Red cards`)) * 100.0 / COUNT(*) AS porcentaje_nulos_red_cards,
    (COUNT(*) - COUNT(Fouls)) * 100.0 / COUNT(*) AS porcentaje_nulos_fouls,
    (COUNT(*) - COUNT(Offsides)) * 100.0 / COUNT(*) AS porcentaje_nulos_offsides,
    (COUNT(*) - COUNT(`Headed goals`)) * 100.0 / COUNT(*) AS porcentaje_nulos_headed_goals,
    (COUNT(*) - COUNT(`Goals with right foot`)) * 100.0 / COUNT(*) AS porcentaje_nulos_goals_with_right_foot,
    (COUNT(*) - COUNT(`Goals with left foot`)) * 100.0 / COUNT(*) AS porcentaje_nulos_goals_with_left_foot,
    (COUNT(*) - COUNT(`Hit woodwork`)) * 100.0 / COUNT(*) AS porcentaje_nulos_hit_woodwork,
    (COUNT(*) - COUNT(`Goals per match`)) * 100.0 / COUNT(*) AS porcentaje_nulos_goals_per_match,
    (COUNT(*) - COUNT(`Penalties scored`)) * 100.0 / COUNT(*) AS porcentaje_nulos_penalties_scored,
    (COUNT(*) - COUNT(`Freekicks scored`)) * 100.0 / COUNT(*) AS porcentaje_nulos_freekicks_scored,
    (COUNT(*) - COUNT(Shots)) * 100.0 / COUNT(*) AS porcentaje_nulos_shots,
    (COUNT(*) - COUNT(`Shots on target`)) * 100.0 / COUNT(*) AS porcentaje_nulos_shots_on_target,
    (COUNT(*) - COUNT(`Shooting accuracy %`)) * 100.0 / COUNT(*) AS porcentaje_nulos_shooting_accuracy,
    (COUNT(*) - COUNT(`Big chances missed`)) * 100.0 / COUNT(*) AS porcentaje_nulos_big_chances_missed,
    (COUNT(*) - COUNT(Saves)) * 100.0 / COUNT(*) AS porcentaje_nulos_saves,
    (COUNT(*) - COUNT(`Penalties Saved`)) * 100.0 / COUNT(*) AS porcentaje_nulos_penalties_saved,
    (COUNT(*) - COUNT(Punches)) * 100.0 / COUNT(*) AS porcentaje_nulos_punches,
    (COUNT(*) - COUNT(`High Claims`)) * 100.0 / COUNT(*) AS porcentaje_nulos_high_claims,
    (COUNT(*) - COUNT(Catches)) * 100.0 / COUNT(*) AS porcentaje_nulos_catches,
    (COUNT(*) - COUNT(`Sweeper clearances`)) * 100.0 / COUNT(*) AS porcentaje_nulos_sweeper_clearances,
    (COUNT(*) - COUNT(`Throw outs`)) * 100.0 / COUNT(*) AS porcentaje_nulos_throw_outs,
    (COUNT(*) - COUNT(`Goal Kicks`)) * 100.0 / COUNT(*) AS porcentaje_nulos_goal_kicks,
    (COUNT(*) - COUNT(Facebook)) * 100.0 / COUNT(*) AS porcentaje_nulos_facebook
FROM TemporaryStats;


SELECT 
    (SELECT COUNT(*) FROM TemporaryStats WHERE Appearances REGEXP '[0-9]') AS numeros_appearances,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Goals REGEXP '[0-9]') AS numeros_goals,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Wins REGEXP '[0-9]') AS numeros_wins,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Losses REGEXP '[0-9]') AS numeros_losses,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Clean sheets` REGEXP '[0-9]') AS numeros_clean_sheets,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Goals Conceded` REGEXP '[0-9]') AS numeros_goals_conceded,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Tackles REGEXP '[0-9]') AS numeros_tackles,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Tackle success %` REGEXP '[0-9]') AS numeros_tackle_success,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Last man tackles` REGEXP '[0-9]') AS numeros_last_man_tackles,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Blocked shots` REGEXP '[0-9]') AS numeros_blocked_shots,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Interceptions REGEXP '[0-9]') AS numeros_interceptions,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Clearances REGEXP '[0-9]') AS numeros_clearances,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Headed Clearance` REGEXP '[0-9]') AS numeros_headed_clearance,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Clearances off line` REGEXP '[0-9]') AS numeros_clearances_off_line,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Recoveries REGEXP '[0-9]') AS numeros_recoveries,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Duels won` REGEXP '[0-9]') AS numeros_duels_won,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Duels lost` REGEXP '[0-9]') AS numeros_duels_lost,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Successful 50/50s` REGEXP '[0-9]') AS numeros_successful_50_50s,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Aerial battles won` REGEXP '[0-9]') AS numeros_aerial_battles_won,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Aerial battles lost` REGEXP '[0-9]') AS numeros_aerial_battles_lost,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Own goals` REGEXP '[0-9]') AS numeros_own_goals,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Errors leading to goal` REGEXP '[0-9]') AS numeros_errors_leading_to_goal,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Assists REGEXP '[0-9]') AS numeros_assists,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Passes REGEXP '[0-9]') AS numeros_passes,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Passes per match` REGEXP '[0-9]') AS numeros_passes_per_match,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Big Chances Created` REGEXP '[0-9]') AS numeros_big_chances_created,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Crosses REGEXP '[0-9]') AS numeros_crosses,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Cross accuracy %` REGEXP '[0-9]') AS numeros_cross_accuracy,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Through balls` REGEXP '[0-9]') AS numeros_through_balls,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Accurate long balls` REGEXP '[0-9]') AS numeros_accurate_long_balls,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Yellow cards` REGEXP '[0-9]') AS numeros_yellow_cards,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Red cards` REGEXP '[0-9]') AS numeros_red_cards,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Fouls REGEXP '[0-9]') AS numeros_fouls,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Offsides REGEXP '[0-9]') AS numeros_offsides,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Headed goals` REGEXP '[0-9]') AS numeros_headed_goals,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Goals with right foot` REGEXP '[0-9]') AS numeros_goals_with_right_foot,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Goals with left foot` REGEXP '[0-9]') AS numeros_goals_with_left_foot,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Hit woodwork` REGEXP '[0-9]') AS numeros_hit_woodwork,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Goals per match` REGEXP '[0-9]') AS numeros_goals_per_match,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Penalties scored` REGEXP '[0-9]') AS numeros_penalties_scored,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Freekicks scored` REGEXP '[0-9]') AS numeros_freekicks_scored,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Shots REGEXP '[0-9]') AS numeros_shots,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Shots on target` REGEXP '[0-9]') AS numeros_shots_on_target,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Shooting accuracy %` REGEXP '[0-9]') AS numeros_shooting_accuracy,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Big chances missed` REGEXP '[0-9]') AS numeros_big_chances_missed,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Saves REGEXP '[0-9]') AS numeros_saves,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Penalties Saved` REGEXP '[0-9]') AS numeros_penalties_saved,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Punches REGEXP '[0-9]') AS numeros_punches,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `High Claims` REGEXP '[0-9]') AS numeros_high_claims,
    (SELECT COUNT(*) FROM TemporaryStats WHERE Catches REGEXP '[0-9]') AS numeros_catches,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Sweeper clearances` REGEXP '[0-9]') AS numeros_sweeper_clearances,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Throw outs` REGEXP '[0-9]') AS numeros_throw_outs,
    (SELECT COUNT(*) FROM TemporaryStats WHERE `Goal Kicks` REGEXP '[0-9]') AS numeros_goal_kicks;

SELECT 
    (COUNT(CASE WHEN Twitter IS NOT NULL AND Twitter != '' THEN 1 END) * 100.0 / COUNT(*)) AS porcentaje_rellenados_twitter,
    (COUNT(CASE WHEN Instagram IS NOT NULL AND Instagram != '' THEN 1 END) * 100.0 / COUNT(*)) AS porcentaje_rellenados_instagram
FROM TemporaryStats;

-- Este código muestra los casos en los que un campo no ha sido rellenado, excluyendo las filas nulas 
-- Las filas nulas en las estadísticas indican que ese dato no es relevante para el jugador
-- La tabla resultante muestra que todas las columnas están completas, excepto aquellas que registran porcentajes

SELECT
    (COUNT(CASE WHEN Twitter REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Twitter)) AS porcentaje_filas_con_numeros_twitter,
    (COUNT(CASE WHEN Appearances REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Appearances)) AS porcentaje_filas_con_numeros_appearances,
    (COUNT(CASE WHEN Goals REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Goals)) AS porcentaje_filas_con_numeros_goals,
    (COUNT(CASE WHEN Wins REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Wins)) AS porcentaje_filas_con_numeros_wins,
    (COUNT(CASE WHEN Losses REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Losses)) AS porcentaje_filas_con_numeros_losses,
    (COUNT(CASE WHEN `Clean sheets` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Clean sheets`)) AS porcentaje_filas_con_numeros_clean_sheets,
    (COUNT(CASE WHEN `Goals Conceded` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Goals Conceded`)) AS porcentaje_filas_con_numeros_goals_conceded,
    (COUNT(CASE WHEN Tackles REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Tackles)) AS porcentaje_filas_con_numeros_tackles,
    (COUNT(CASE WHEN `Tackle success %` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Tackle success %`)) AS porcentaje_filas_con_numeros_tackle_success,
    (COUNT(CASE WHEN `Last man tackles` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Last man tackles`)) AS porcentaje_filas_con_numeros_last_man_tackles,
    (COUNT(CASE WHEN `Blocked shots` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Blocked shots`)) AS porcentaje_filas_con_numeros_blocked_shots,
    (COUNT(CASE WHEN Interceptions REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Interceptions)) AS porcentaje_filas_con_numeros_interceptions,
    (COUNT(CASE WHEN Clearances REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Clearances)) AS porcentaje_filas_con_numeros_clearances,
    (COUNT(CASE WHEN `Headed Clearance` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Headed Clearance`)) AS porcentaje_filas_con_numeros_headed_clearance,
    (COUNT(CASE WHEN `Clearances off line` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Clearances off line`)) AS porcentaje_filas_con_numeros_clearances_off_line,
    (COUNT(CASE WHEN Recoveries REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Recoveries)) AS porcentaje_filas_con_numeros_recoveries,
    (COUNT(CASE WHEN `Duels won` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Duels won`)) AS porcentaje_filas_con_numeros_duels_won,
    (COUNT(CASE WHEN `Duels lost` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Duels lost`)) AS porcentaje_filas_con_numeros_duels_lost,
    (COUNT(CASE WHEN `Successful 50/50s` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Successful 50/50s`)) AS porcentaje_filas_con_numeros_successful_50_50s,
    (COUNT(CASE WHEN `Aerial battles won` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Aerial battles won`)) AS porcentaje_filas_con_numeros_aerial_battles_won,
    (COUNT(CASE WHEN `Aerial battles lost` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Aerial battles lost`)) AS porcentaje_filas_con_numeros_aerial_battles_lost,
    (COUNT(CASE WHEN `Own goals` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Own goals`)) AS porcentaje_filas_con_numeros_own_goals,
    (COUNT(CASE WHEN `Errors leading to goal` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Errors leading to goal`)) AS porcentaje_filas_con_numeros_errors_leading_to_goal,
    (COUNT(CASE WHEN Assists REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Assists)) AS porcentaje_filas_con_numeros_assists,
    (COUNT(CASE WHEN Passes REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Passes)) AS porcentaje_filas_con_numeros_passes,
    (COUNT(CASE WHEN `Passes per match` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Passes per match`)) AS porcentaje_filas_con_numeros_passes_per_match,
    (COUNT(CASE WHEN `Big Chances Created` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Big Chances Created`)) AS porcentaje_filas_con_numeros_big_chances_created,
    (COUNT(CASE WHEN Crosses REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Crosses)) AS porcentaje_filas_con_numeros_crosses,
    (COUNT(CASE WHEN `Cross accuracy %` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Cross accuracy %`)) AS porcentaje_filas_con_numeros_cross_accuracy,
    (COUNT(CASE WHEN `Through balls` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Through balls`)) AS porcentaje_filas_con_numeros_through_balls,
    (COUNT(CASE WHEN `Accurate long balls` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Accurate long balls`)) AS porcentaje_filas_con_numeros_accurate_long_balls,
    (COUNT(CASE WHEN `Yellow cards` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Yellow cards`)) AS porcentaje_filas_con_numeros_yellow_cards,
    (COUNT(CASE WHEN `Red cards` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Red cards`)) AS porcentaje_filas_con_numeros_red_cards,
    (COUNT(CASE WHEN Fouls REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Fouls)) AS porcentaje_filas_con_numeros_fouls,
    (COUNT(CASE WHEN Offsides REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Offsides)) AS porcentaje_filas_con_numeros_offsides,
    (COUNT(CASE WHEN `Headed goals` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Headed goals`)) AS porcentaje_filas_con_numeros_headed_goals,
    (COUNT(CASE WHEN `Goals with right foot` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Goals with right foot`)) AS porcentaje_filas_con_numeros_goals_with_right_foot,
    (COUNT(CASE WHEN `Goals with left foot` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Goals with left foot`)) AS porcentaje_filas_con_numeros_goals_with_left_foot,
    (COUNT(CASE WHEN `Hit woodwork` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Hit woodwork`)) AS porcentaje_filas_con_numeros_hit_woodwork,
    (COUNT(CASE WHEN `Goals per match` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Goals per match`)) AS porcentaje_filas_con_numeros_goals_per_match,
    (COUNT(CASE WHEN `Penalties scored` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Penalties scored`)) AS porcentaje_filas_con_numeros_penalties_scored,
    (COUNT(CASE WHEN `Freekicks scored` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Freekicks scored`)) AS porcentaje_filas_con_numeros_freekicks_scored,
    (COUNT(CASE WHEN Shots REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Shots)) AS porcentaje_filas_con_numeros_shots
	(COUNT(CASE WHEN `Shots on target` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Shots on target`)) AS porcentaje_filas_con_numeros_shots_on_target,
    (COUNT(CASE WHEN `Shooting accuracy %` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Shooting accuracy %`)) AS porcentaje_filas_con_numeros_shooting_accuracy,
    (COUNT(CASE WHEN `Big chances missed` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Big chances missed`)) AS porcentaje_filas_con_numeros_big_chances_missed,
    (COUNT(CASE WHEN Saves REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Saves)) AS porcentaje_filas_con_numeros_saves,
    (COUNT(CASE WHEN `Penalties Saved` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Penalties Saved`)) AS porcentaje_filas_con_numeros_penalties_saved,
    (COUNT(CASE WHEN Punches REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Punches)) AS porcentaje_filas_con_numeros_punches,
    (COUNT(CASE WHEN `High Claims` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`High Claims`)) AS porcentaje_filas_con_numeros_high_claims,
    (COUNT(CASE WHEN Catches REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(Catches)) AS porcentaje_filas_con_numeros_catches,
    (COUNT(CASE WHEN `Sweeper clearances` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Sweeper clearances`)) AS porcentaje_filas_con_numeros_sweeper_clearances,
    (COUNT(CASE WHEN `Throw outs` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Throw outs`)) AS porcentaje_filas_con_numeros_throw_outs,
    (COUNT(CASE WHEN `Goal Kicks` REGEXP '[0-9]' THEN 1 END) * 1.0 / COUNT(`Goal Kicks`)) AS porcentaje_filas_con_numeros_goal_kicks
FROM TemporaryStats;
    


-- 6. Métrica de Consistencia: 
-- En este caso, la consistencia es similar a la de la estructura, ya que los únicos datos inconsistentes son los de 'Date_of_Birth'.
-- En cuanto a 'Height', aunque presenta una estructura errónea, los datos son consistentes a lo largo del dataset, 
-- por lo que su consistencia se considera del 100%.



-- 7. Métrica de Moneda: 
-- Este dataset corresponde a datos de la temporada 23/24, recopilados al finalizar dicha temporada
-- Dado que los datos son estáticos y reflejan un momento específico, no se actualizarán más



-- 8. Métrica de Puntualidad: 
-- Como ocurria en el CSV anterior, al haber sido extraído de Kaggle, y siendo un dataset relativamente pequeño, 
-- su puntualidad es del 100%. 



-- 9. Métrica de Razonabilidad: Evalúa si los valores de los datos tienen un tipo y tamaño razonables
-- Tras revisar las consultas previas, podemos concluir que la razonabilidad es adecuada en las columnas de tipo numéricas y de texo



-- 10. Métrica de Identificabilidad:
-- Al igual que en la tabla anterior, la columna que utilizamos para identificar las filas es 'Name'. Es necesario verificar si existen 
-- duplicados en esta columna, ya que la presencia de valores repetidos afectaría su capacidad para funcionar como identificador único
-- Después de realizar el análisis, hemos encontrado que existen 91 duplicados en la columna 'Name'. Esto indica que algunos nombres se repiten,
-- lo cual reduce la efectividad de esta columna para distinguir cada fila de manera única
-- En términos de identificabilidad, la columna 'Name' presenta un porcentaje de un 91.07%. Es decir, el 91.07% de las filas tienen un valor 
-- único en esta columna, mientras que el 8.93% restante contiene duplicados
SELECT Name, COUNT(*) AS Apariciones
FROM TemporaryStats
GROUP BY Name
HAVING COUNT(*) != 1;






-- Limpieza de los Datos:
-- Se muestran a continuación los pasos realizados para limpiar los datos ya estudiados: 

-- Primer archivo CSV: player_overview.csv
-- Paso 1: Añadir una columna de clave primaria (ID único) para cada jugador
ALTER TABLE TemporaryOverview
ADD COLUMN ID_player INT AUTO_INCREMENT PRIMARY KEY FIRST;
    


-- Paso 2: Verificar la cantidad de valores nulos en cada columna
SELECT
    SUM(CASE WHEN Name IS NULL OR Name = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Name,
    SUM(CASE WHEN Nationality IS NULL OR Nationality = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Nationality,
    SUM(CASE WHEN `Date of Birth` IS NULL OR `Date of Birth` = '' THEN 1 ELSE 0 END) AS nulos_faltantes_DateOfBirth,
    SUM(CASE WHEN Height IS NULL OR Height = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Height,
    SUM(CASE WHEN Club IS NULL OR Club = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Club,
    SUM(CASE WHEN Position IS NULL OR Position = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Position,
    SUM(CASE WHEN Appearances IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Appearances,
    SUM(CASE WHEN Goals IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Goals,
    SUM(CASE WHEN Assists IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Assists,
    SUM(CASE WHEN `Clean sheets` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_CleanSheets,
    SUM(CASE WHEN Facebook IS NULL OR Facebook = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Facebook
FROM
    TemporaryOverview;

  
   
-- Paso 3: Eliminar las columnas innecesarias debido a la alta cantidad de valores nulos
ALTER TABLE TemporaryOverview
DROP COLUMN `Clean sheets`,
DROP COLUMN Facebook;



-- Paso 4: Eliminar las columnas que no son relevantes para los objetivos de este trabajo
ALTER TABLE TemporaryOverview
DROP COLUMN Appearances,
DROP COLUMN Goals, 
DROP COLUMN Assists;



-- Paso 5: Eliminar registros duplicados basados en el nombre
SELECT
    Name,
    COUNT(*) AS cantidad_duplicados
FROM
    TemporaryOverview
GROUP BY
    Name
HAVING
    COUNT(*) > 1;

   
CREATE TEMPORARY TABLE TempIDs AS
SELECT MIN(ID_player) AS ID_player
FROM TemporaryOverview
GROUP BY Name
HAVING COUNT(*) > 1

UNION

SELECT ID_player
FROM TemporaryOverview
WHERE Name NOT IN (
    SELECT Name
    FROM TemporaryOverview
    GROUP BY Name
    HAVING COUNT(*) > 1
);


DELETE FROM TemporaryOverview
WHERE ID_player NOT IN (SELECT ID_player FROM TempIDs);


DROP TEMPORARY TABLE TempIDs;



-- Paso 6: Limpiar la columna 'Height' eliminando el sufijo 'cm'
UPDATE TemporaryOverview
SET Height = REPLACE(Height, 'cm', '')
WHERE Height LIKE '%cm';



-- Paso 6: Limpiar la columna 'Date of Birth' eliminando cualquier texto no deseado 
UPDATE TemporaryOverview
SET `Date of Birth` = 
    STR_TO_DATE(
        REGEXP_REPLACE(`Date of Birth`, '\\(.*\\)', ''), 
        '%d/%m/%Y'
    )
WHERE `Date of Birth` LIKE '%/%/%';



-- Paso 7: Reemplazar los valores nulos de la columna 'Height' con la media de los valores existentes
SET @avg_height = (
    SELECT ROUND(AVG(CAST(Height AS UNSIGNED)), 1)
    FROM TemporaryOverview
    WHERE Height IS NOT NULL AND Height != ''
);


UPDATE TemporaryOverview
SET Height = @avg_height
WHERE Height IS NULL OR Height = '';



-- Paso 10: Corregir el formato de los tipos de datos
ALTER TABLE TemporaryOverview
MODIFY COLUMN Height FLOAT;


ALTER TABLE TemporaryOverview
MODIFY COLUMN `Date of Birth` DATE;



-- Paso 11: Verificar que no haya valores nulos o vacíos después de las actualizaciones
SELECT
    SUM(CASE WHEN Name IS NULL OR Name = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Name,
    SUM(CASE WHEN Nationality IS NULL OR Nationality = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Nationality,
    SUM(CASE WHEN `Date of Birth` IS NULL OR `Date of Birth` = '' THEN 1 ELSE 0 END) AS nulos_faltantes_DateOfBirth,
    SUM(CASE WHEN Height IS NULL OR Height = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Height,
    SUM(CASE WHEN Club IS NULL OR Club = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Club,
    SUM(CASE WHEN Position IS NULL OR Position = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Position
FROM
    TemporaryOverview;
    
   

-- Segundo archivo CSV: player_stats.csv
-- Paso 1: Eliminar registros duplicados basados en el nombre
-- Paso 1.1: Añadir una columna de clave temporal para cada jugador
ALTER TABLE TemporaryStats
ADD COLUMN ID_temporary INT AUTO_INCREMENT PRIMARY KEY FIRST;


-- Paso 1.2: Eliminar registros duplicados basados en el nombre
SELECT
    Name,
    COUNT(*) AS cantidad_duplicados
FROM
    TemporaryStats
GROUP BY
    Name
HAVING
    COUNT(*) > 1;

   
CREATE TEMPORARY TABLE TempIDs AS
SELECT MIN(ID_temporary) AS ID_temporary
FROM TemporaryStats
GROUP BY Name
HAVING COUNT(*) > 1

UNION

SELECT ID_temporary
FROM TemporaryStats
WHERE Name NOT IN (
    SELECT Name
    FROM TemporaryStats
    GROUP BY Name
    HAVING COUNT(*) > 1
);


DELETE FROM TemporaryStats
WHERE ID_temporary  NOT IN (SELECT ID_temporary  FROM TempIDs);


DROP TEMPORARY TABLE TempIDs;


ALTER TABLE TemporaryStats DROP COLUMN ID_temporary;



-- Paso 2: Añadir una columna de clave primaria (ID único) para cada jugador
ALTER TABLE TemporaryStats
ADD COLUMN ID_player INT FIRST;


UPDATE TemporaryStats
JOIN TemporaryOverview
ON TemporaryStats.Name = TemporaryOverview.Name
SET TemporaryStats.ID_player = TemporaryOverview.ID_player;


ALTER TABLE TemporaryStats
ADD PRIMARY KEY (ID_player);



-- Paso 3: Verificar la cantidad de valores nulos en cada columna
SELECT
	SUM(CASE WHEN ID_player IS NULL OR ID_player = '' THEN 1 ELSE 0 END) AS nulos_faltantes_id,
    SUM(CASE WHEN Name IS NULL OR Name = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Name,
    SUM(CASE WHEN Twitter IS NULL OR Twitter = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Twitter,
    SUM(CASE WHEN Instagram IS NULL OR Instagram = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Instagram,
    SUM(CASE WHEN Appearances IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Appearances,
    SUM(CASE WHEN Goals IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Goals,
    SUM(CASE WHEN Wins IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Wins,
    SUM(CASE WHEN Losses IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Losses,
    SUM(CASE WHEN `Clean sheets` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_CleanSheets,
    SUM(CASE WHEN `Goals Conceded` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_GoalsConceded,
    SUM(CASE WHEN Tackles IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Tackles,
    SUM(CASE WHEN `Tackle success %` IS NULL OR `Tackle success %` = '' THEN 1 ELSE 0 END) AS nulos_faltantes_TackleSuccessPercent,
    SUM(CASE WHEN `Last man tackles` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_LastManTackles,
    SUM(CASE WHEN `Blocked shots` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_BlockedShots,
    SUM(CASE WHEN Interceptions IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Interceptions,
    SUM(CASE WHEN Clearances IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Clearances,
    SUM(CASE WHEN `Headed Clearance` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_HeadedClearance,
    SUM(CASE WHEN `Clearances off line` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_ClearancesOffLine,
    SUM(CASE WHEN Recoveries IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Recoveries,
    SUM(CASE WHEN `Duels won` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_DuelsWon,
    SUM(CASE WHEN `Duels lost` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_DuelsLost,
    SUM(CASE WHEN `Successful 50/50s` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Successful5050s,
    SUM(CASE WHEN `Aerial battles won` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_AerialBattlesWon,
    SUM(CASE WHEN `Aerial battles lost` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_AerialBattlesLost,
    SUM(CASE WHEN `Own goals` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_OwnGoals,
    SUM(CASE WHEN `Errors leading to goal` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_ErrorsLeadingToGoal,
    SUM(CASE WHEN Assists IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Assists,
    SUM(CASE WHEN Passes IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Passes,
    SUM(CASE WHEN `Passes per match` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_PassesPerMatch,
    SUM(CASE WHEN `Big Chances Created` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_BigChancesCreated,
    SUM(CASE WHEN Crosses IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Crosses,
    SUM(CASE WHEN `Cross accuracy %` IS NULL OR `Cross accuracy %` = '' THEN 1 ELSE 0 END) AS nulos_faltantes_CrossAccuracyPercent,
    SUM(CASE WHEN `Through balls` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_ThroughBalls,
    SUM(CASE WHEN `Accurate long balls` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_AccurateLongBalls,
    SUM(CASE WHEN `Yellow cards` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_YellowCards,
    SUM(CASE WHEN `Red cards` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_RedCards,
    SUM(CASE WHEN Fouls IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Fouls,
    SUM(CASE WHEN Offsides IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Offsides,
    SUM(CASE WHEN `Headed goals` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_HeadedGoals,
    SUM(CASE WHEN `Goals with right foot` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_GoalsWithRightFoot,
    SUM(CASE WHEN `Goals with left foot` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_GoalsWithLeftFoot,
    SUM(CASE WHEN `Hit woodwork` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_HitWoodwork,
    SUM(CASE WHEN `Goals per match` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_GoalsPerMatch,
    SUM(CASE WHEN `Penalties scored` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_PenaltiesScored,
    SUM(CASE WHEN `Freekicks scored` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_FreekicksScored,
    SUM(CASE WHEN Shots IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Shots,
    SUM(CASE WHEN `Shots on target` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_ShotsOnTarget,
    SUM(CASE WHEN `Shooting accuracy %` IS NULL OR `Shooting accuracy %` = '' THEN 1 ELSE 0 END) AS nulos_faltantes_ShootingAccuracyPercent,
    SUM(CASE WHEN `Big chances missed` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_BigChancesMissed,
    SUM(CASE WHEN Saves IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Saves,
    SUM(CASE WHEN `Penalties Saved` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_PenaltiesSaved,
    SUM(CASE WHEN Punches IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Punches,
    SUM(CASE WHEN `High Claims` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_HighClaims,
    SUM(CASE WHEN Catches IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Catches,
    SUM(CASE WHEN `Sweeper clearances` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_SweeperClearances,
    SUM(CASE WHEN `Throw outs` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_ThrowOuts,
    SUM(CASE WHEN `Goal Kicks` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_GoalKicks,
    SUM(CASE WHEN Facebook IS NULL OR Facebook = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Facebook
FROM
    TemporaryStats;

   
   
-- Paso 4: Eliminar las columnas innecesarias debido a la alta cantidad de valores nulos
ALTER TABLE TemporaryStats
DROP COLUMN Twitter,
DROP COLUMN Instagram,
DROP COLUMN `Clean sheets`, 
DROP COLUMN `Goals Conceded`, 
DROP COLUMN `Last man tackles`,
DROP COLUMN `Clearances off line`,
DROP COLUMN `Own goals`, 
DROP COLUMN `Goals per match`,
DROP COLUMN `Penalties scored`,
DROP COLUMN `Freekicks scored`,
DROP COLUMN `Shots on target`,
DROP COLUMN `Big chances missed`,
DROP COLUMN Punches,
DROP COLUMN `High Claims`,
DROP COLUMN `Sweeper clearances`,
DROP COLUMN `Throw outs`,
DROP COLUMN `Goal Kicks`,
DROP COLUMN Facebook;



-- Paso 5: Eliminar las columnas innecesarias para definir las métricas de los jugadores
ALTER TABLE TemporaryStats 
DROP COLUMN Wins,
DROP COLUMN Losses,
DROP COLUMN `Tackle success %`,
DROP COLUMN `Blocked shots`,
DROP COLUMN `Headed Clearance`,
DROP COLUMN `Recoveries`,
DROP COLUMN `Duels lost`,
DROP COLUMN `Successful 50/50s`,
DROP COLUMN `Aerial battles lost`,
DROP COLUMN `Crosses`,
DROP COLUMN `Cross accuracy %`,
DROP COLUMN `Through balls`,
DROP COLUMN `Accurate long balls`,
DROP COLUMN `Yellow cards`,
DROP COLUMN `Red cards`,
DROP COLUMN `Fouls`,
DROP COLUMN `Offsides`,
DROP COLUMN `Hit woodwork`;


                                                           
-- Paso 7: Limpiar y actualizar los datos
-- Paso 7.1: Limpiar la columna 'Passes'                    
UPDATE TemporaryStats
SET Passes = REPLACE(Passes, ',', '')
WHERE Passes LIKE '%,%'; 


ALTER TABLE TemporaryStats
MODIFY COLUMN Passes INTEGER;


-- Paso 7.2: Limpiar la columna 'Shooting accuracy %'
UPDATE TemporaryStats
SET `Shooting accuracy %` = REPLACE(`Shooting accuracy %`, '%', '')
WHERE `Shooting accuracy %` LIKE '%';

UPDATE TemporaryStats
SET `Shooting accuracy %` = NULL
WHERE `Shooting accuracy %` = '';

ALTER TABLE TemporaryStats
MODIFY COLUMN `Shooting accuracy %` INTEGER;


-- Paso 7.3: Actualizar estadísticas de porteros
UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.Saves = 0
WHERE tov.Position != 'Goalkeeper';


UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.`Penalties Saved` = 0
WHERE tov.Position != 'Goalkeeper';


UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.Catches = 0
WHERE tov.Position != 'Goalkeeper';


-- Paso 7.4: Actualizar otras estadísticas, si es necesario, con valores promedio
-- Columna 'Duels won'
SET @avg_duels_won = (
    SELECT ROUND(AVG(CAST(`Duels won` AS UNSIGNED)), 0)
    FROM TemporaryStats
    WHERE `Duels won` IS NOT NULL AND Appearances > 0
);


UPDATE TemporaryStats
SET `Duels won` = @avg_duels_won
WHERE `Duels won` IS NULL;


-- Columna 'Aerial battles won'
SET @avg_aerial = (
    SELECT ROUND(AVG(CAST(`Aerial battles won` AS UNSIGNED)), 0)
    FROM TemporaryStats
    WHERE `Aerial battles won` IS NOT NULL AND Appearances > 0
);


UPDATE TemporaryStats
SET `Aerial battles won` = @avg_aerial
WHERE `Aerial battles won` IS NULL;


-- Columna 'Errors leading to goal'
SET @avg_errors = (
    SELECT ROUND(AVG(CAST(`Errors leading to goal` AS UNSIGNED)), 1)
    FROM TemporaryStats
    WHERE `Errors leading to goal` IS NOT NULL AND Appearances > 0
);


UPDATE TemporaryStats
SET `Errors leading to goal` = @avg_errors
WHERE `Errors leading to goal` IS NULL;


-- Columna 'Shots'
SET @avg_shots = (
    SELECT ROUND(AVG(CAST(Shots AS UNSIGNED)), 0)
    FROM TemporaryStats
    WHERE Shots IS NOT NULL AND Appearances > 0
);


UPDATE TemporaryStats
SET Shots = @avg_shots
WHERE Shots IS NULL;


-- Columna 'Shooting accuracy %'
SET @avg_shooting_accuracy = (
    SELECT ROUND(AVG(CAST(`Shooting accuracy %` AS UNSIGNED)), 0)
    FROM TemporaryStats
    WHERE `Shooting accuracy %` IS NOT NULL AND Appearances > 0
);


UPDATE TemporaryStats
SET `Shooting accuracy %` = @avg_shooting_accuracy
WHERE `Shooting accuracy %` IS NULL;



-- Paso 7.5: Actualizar estadísticas de los porteros
UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.Tackles = 0
WHERE tov.Position = 'Goalkeeper';


UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.Interceptions = 0
WHERE tov.Position = 'Goalkeeper';


UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.Clearances = 0
WHERE tov.Position= 'Goalkeeper';

UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.`Duels won` = 0
WHERE tov.Position = 'Goalkeeper';

UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.`Aerial battles won` = 0
WHERE tov.Position = 'Goalkeeper';

UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.`Big Chances Created` = 0
WHERE tov.Position = 'Goalkeeper';

UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.`Headed goals` = 0
WHERE tov.Position = 'Goalkeeper';

UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.`Goals with right foot` = 0
WHERE tov.Position = 'Goalkeeper';

UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.`Goals with left foot` = 0
WHERE tov.Position = 'Goalkeeper';

UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.Shots = 0
WHERE tov.Position = 'Goalkeeper';

UPDATE TemporaryStats ts
JOIN TemporaryOverview tov ON ts.ID_player = tov.ID_player
SET ts.`Shooting accuracy %` = 0
WHERE tov.Position = 'Goalkeeper';


-- Paso 8: Verificar que no haya valores nulos o vacíos después de las actualizaciones
SELECT
    SUM(CASE WHEN ID_player IS NULL OR ID_player = '' THEN 1 ELSE 0 END) AS nulos_faltantes_id,
    SUM(CASE WHEN Name IS NULL OR Name = '' THEN 1 ELSE 0 END) AS nulos_faltantes_Name,
    SUM(CASE WHEN Appearances IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Appearances,
    SUM(CASE WHEN Goals IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Goals,
    SUM(CASE WHEN Tackles IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Tackles,
    SUM(CASE WHEN Interceptions IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Interceptions,
    SUM(CASE WHEN Clearances IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Clearances,
    SUM(CASE WHEN `Duels won` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_DuelsWon,
    SUM(CASE WHEN `Aerial battles won` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_AerialBattlesWon,
    SUM(CASE WHEN `Errors leading to goal` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_ErrorsLeadingToGoal,
    SUM(CASE WHEN Assists IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Assists,
    SUM(CASE WHEN Passes IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Passes,
    SUM(CASE WHEN `Passes per match` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_PassesPerMatch,
    SUM(CASE WHEN `Big Chances Created` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_BigChancesCreated,
    SUM(CASE WHEN `Headed goals` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_HeadedGoals,
    SUM(CASE WHEN `Goals with right foot` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_GoalsWithRightFoot,
    SUM(CASE WHEN `Goals with left foot` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_GoalsWithLeftFoot,
    SUM(CASE WHEN Shots IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Shots,
    SUM(CASE WHEN `Shooting accuracy %` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_ShootingAccuracyPercent,
    SUM(CASE WHEN Saves IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Saves,
    SUM(CASE WHEN `Penalties Saved` IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_PenaltiesSaved,
    SUM(CASE WHEN Catches IS NULL THEN 1 ELSE 0 END) AS nulos_faltantes_Catches
FROM
    TemporaryStats;

 
 
-- Paso 9: Normalizar de nombres de columnas
ALTER TABLE TemporaryStats
CHANGE COLUMN `Duels won` `Duels Won` INTEGER;   
   

ALTER TABLE TemporaryStats
CHANGE COLUMN `Aerial battles won` `Aerial Battles Won` INTEGER; 
 

ALTER TABLE TemporaryStats
CHANGE COLUMN `Errors leading to goal` `Errors Leading to Goal` INTEGER;
  

ALTER TABLE TemporaryStats
CHANGE COLUMN `Passes per match` `Passes per Match` INTEGER;
   
 
ALTER TABLE TemporaryStats
CHANGE COLUMN `Headed goals` `Headed Goals` INTEGER;


ALTER TABLE TemporaryStats
CHANGE COLUMN `Goals with right foot` `Goals with Right Foot` INTEGER;


ALTER TABLE TemporaryStats
CHANGE COLUMN `Goals with left foot` `Goals with Left Foot` INTEGER;


ALTER TABLE TemporaryStats
CHANGE COLUMN `Shooting accuracy %` `Shooting Accuracy %` INTEGER;


-- Una vez finalizada la Limpieza de los Datos:
-- Calculamos las métricas de rendimiento de los jugadores
-- Calculamos la métrica de la posición de delantero
ALTER TABLE TemporaryStats
ADD COLUMN `Foward Metric` DECIMAL(10, 2);


UPDATE TemporaryStats ts
JOIN (
    SELECT 
        MAX(`Goals`) AS max_goals,
        MAX(`Assists`) AS max_assists,
        MAX(`Shots`) AS max_shots,
        MAX(`Shooting Accuracy %`) AS max_shooting_accuracy,
        MAX(`Goals with Right Foot` + `Goals with Left Foot` + `Headed Goals`) AS max_goals_with_all_parts,
        MAX(`Big Chances Created`) AS max_big_chances
    FROM TemporaryStats
) max_values ON 1 = 1
SET ts.`Foward Metric` = (
    (0.30 * (ts.`Goals` / max_values.max_goals)) + 
    (0.20 * (ts.`Assists` / max_values.max_assists)) + 
    (0.10 * (ts.`Shots` / max_values.max_shots)) + 
    (0.15 * (ts.`Shooting Accuracy %` / max_values.max_shooting_accuracy)) + 
    (0.15 * ((ts.`Goals with Right Foot` + ts.`Goals with Left Foot` + ts.`Headed Goals`) / max_values.max_goals_with_all_parts)) + 
    (0.10 * (ts.`Big Chances Created` / max_values.max_big_chances))
);



-- Calculamos la métrica de la posición de mediocentro
ALTER TABLE TemporaryStats
ADD COLUMN `Midfielder Metric` DECIMAL(10, 2);


UPDATE TemporaryStats ts
JOIN (
    SELECT 
        MAX(`Passes`) AS max_passes,
        MAX(`Passes per Match`) AS max_passes_per_match,
        MAX(`Big Chances Created`) AS max_big_chances,
        MAX(`Tackles`) AS max_tackles,
        MAX(`Interceptions`) AS max_interceptions
    FROM TemporaryStats
) max_values ON 1 = 1
SET ts.`Midfielder Metric` = (
    (0.10 * (ts.`Passes` / max_values.max_passes)) + 
    (0.45 * (ts.`Passes per Match` / max_values.max_passes_per_match)) + 
    (0.15 * (ts.`Big Chances Created` / max_values.max_big_chances)) + 
    (0.15 * (ts.`Tackles` / max_values.max_tackles)) + 
    (0.15 * (ts.`Interceptions` / max_values.max_interceptions))
);



-- Calculamos la métrica de la posición de defensa
ALTER TABLE TemporaryStats
ADD COLUMN `Defender Metric` DECIMAL(10, 2);


UPDATE TemporaryStats ts
JOIN (
    SELECT 
        MAX(`Tackles`) AS max_tackles,
        MAX(`Interceptions`) AS max_interceptions,
        MAX(`Clearances`) AS max_clearances,
        MAX(`Duels Won`) AS max_duels_won,
        MAX(`Aerial Battles Won`) AS max_aerial_battles_won,
        MAX(`Errors Leading to Goal`) AS max_errors_leading_to_goal
    FROM TemporaryStats
) max_values ON 1 = 1
SET ts.`Defender Metric` = (
    (0.20 * (ts.`Tackles` / max_values.max_tackles)) + 
    (0.20 * (ts.`Interceptions` / max_values.max_interceptions)) + 
    (0.15 * (ts.`Clearances` / max_values.max_clearances)) + 
    (0.15 * (ts.`Duels Won` / max_values.max_duels_won)) + 
    (0.15 * (ts.`Aerial Battles won` / max_values.max_aerial_battles_won)) + 
    (0.15 * (ts.`Errors Leading to Goal` / max_values.max_errors_leading_to_goal))
);



-- Calculamos la métrica de la posición de portero
ALTER TABLE TemporaryStats
ADD COLUMN `Goalkeeper Metric` DECIMAL(10, 2);


UPDATE TemporaryStats ts
JOIN (
    SELECT 
        MAX(`Saves`) AS max_saves,
        MAX(`Penalties Saved`) AS max_penalties_saved,
        MAX(`Catches`) AS max_catches,
        MAX(`Clearances`) AS max_clearances
    FROM TemporaryStats
) max_values ON 1 = 1
SET ts.`Goalkeeper Metric` = (
    (0.40 * (ts.`Saves` / max_values.max_saves)) + 
    (0.30 * (ts.`Penalties Saved` / max_values.max_penalties_saved)) + 
    (0.20 * (ts.`Catches` / max_values.max_catches)) + 
    (0.10 * (ts.`Clearances` / max_values.max_clearances))
);