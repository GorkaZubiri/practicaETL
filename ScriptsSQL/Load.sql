-- El principal objetivo de este script es carga los datos transformados en el sistema de destino,
-- organizándolos en tablas dimensionales y de hechos.

-- Se incluyen algunas consultas para evaluar el proceso
USE MiBaseDeDatos;

SELECT * FROM TemporaryOverview;
SELECT * FROM TemporaryStats;

-- Paso 1: Crear la dimensión de los jugadores para almacenar información básica de los jugadores
CREATE TABLE Dim_Player (
    ID_player INTEGER,
    Name VARCHAR(100),  
    Nationality VARCHAR(100),  
    `Date of Birth` VARCHAR(100),  
    Height FLOAT,          
    Club VARCHAR(100)
);


-- Paso 1.1: Insertar los datos de los jugadores desde TemporaryOverview en la dimensión de los jugadores
INSERT INTO Dim_Player (ID_player, Name,  Nationality, `Date of Birth`, Height, Club)
SELECT ID_player, Name,  Nationality, `Date of Birth`, Height, Club 
FROM TemporaryOverview;


-- Paso 1.2: Exportación de datos a un CSV
SELECT * FROM Dim_Player;


SELECT * 
INTO OUTFILE '/var/lib/mysql-files/Dim_Player.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''  
LINES TERMINATED BY '\n'
FROM Dim_Player;





-- Paso 2: Crear la tabla de hechos para almacenar las métricas de desempeño de los jugadores
CREATE TABLE Fact_Performance (
    ID_player INTEGER,
    Nationality VARCHAR(100),  
    Position VARCHAR(100),  
    `Foward Metric` FLOAT,
    `Midfielder Metric` FLOAT,
    `Defender Metric` FLOAT,
    `Goalkeeper Metric` FLOAT
);


-- Paso 2.1: Insertar las métricas de desempeño de los jugadores 
INSERT INTO Fact_Performance (ID_player, Nationality, Position, `Foward Metric`, `Midfielder Metric`, `Defender Metric`, `Goalkeeper Metric`)
SELECT o.ID_player, o.Nationality, o.Position, 
       s.`Foward Metric`, s.`Midfielder Metric`, s.`Defender Metric`, s.`Goalkeeper Metric`
FROM TemporaryOverview o
JOIN TemporaryStats s ON o.ID_player = s.ID_player;


-- Paso 2.2: Exportación de datos a un CSV
SELECT * FROM Fact_Performance;


SELECT * 
INTO OUTFILE '/var/lib/mysql-files/Fact_Performance.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''  
LINES TERMINATED BY '\n'
FROM Fact_Performance;



-- Paso 3: Crear la dimensión de estadísticas generales para almacenar las estadísticas globales de los jugadores
CREATE TABLE Dim_GeneralStats (
	ID_player INTEGER,
	Position VARCHAR(100),  
	Appearances INTEGER,
	Goals INTEGER,
	Assists INTEGER,
	Passes INTEGER,
	`Passes per match` FLOAT,
	`Big Chances Created` INTEGER
);


-- Paso 3.1: Insertar las estadísticas generales de los jugadores en la dimensión de estadísticas generales
INSERT INTO Dim_GeneralStats (ID_player, Position, Appearances, Goals, Assists, Passes, `Passes per match`, `Big Chances Created`)
SELECT o.ID_player, o.Position, 
       s.Appearances, s.Goals, s.Assists, s.Passes, s.`Passes per match`, s.`Big Chances Created`
FROM TemporaryOverview o
JOIN TemporaryStats s ON o.ID_player = s.ID_player;


-- Paso 3.2: Exportación de datos a un CSV
SELECT * FROM Dim_GeneralStats;


SELECT * 
INTO OUTFILE '/var/lib/mysql-files/Dim_GeneralStats.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''  
LINES TERMINATED BY '\n'
FROM Dim_GeneralStats;



-- Paso 4: Crear la dimensión de estadísticas defensivas
CREATE TABLE Dim_DefensiveStats (
	ID_player INTEGER,
	Interceptions INTEGER,
	Clearances INTEGER,
	`Duels won` INTEGER,
	`Aerial battles won` INTEGER,
	`Errors leading to goal` INTEGER
);


-- Paso 4.1: Insertar las estadísticas defensivas de los jugadores 
INSERT INTO Dim_DefensiveStats (ID_player, Interceptions, Clearances, `Duels won`, `Aerial battles won`, `Errors leading to goal`)
SELECT ID_player, Interceptions, Clearances, `Duels won`, `Aerial battles won`, `Errors leading to goal`
FROM TemporaryStats;


-- Paso 4.2: Exportación de datos a un CSV
SELECT * FROM Dim_DefensiveStats;


SELECT * 
INTO OUTFILE '/var/lib/mysql-files/Dim_DefensiveStats.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''  
LINES TERMINATED BY '\n'
FROM Dim_DefensiveStats;



-- Paso 5: Crear la dimensión de estadísticas ofensivas
CREATE TABLE Dim_OfensiveStats (
	ID_player INTEGER,
	`Headed goals` INTEGER,
    `Goals with right foot` INTEGER,
    `Goals with left foot` INTEGER
);


-- Paso 5.1: Insertar las estadísticas ofensivas de los jugadores 
INSERT INTO Dim_OfensiveStats (ID_player, `Headed goals`, `Goals with right foot`, `Goals with left foot`)
SELECT ID_player, `Headed goals`, `Goals with right foot`, `Goals with left foot`
FROM TemporaryStats;


-- Paso 5.2: Exportación de datos a un CSV
SELECT * FROM Dim_OfensiveStats;


SELECT * 
INTO OUTFILE '/var/lib/mysql-files/Dim_OfensiveStats.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''  
LINES TERMINATED BY '\n'
FROM Dim_OfensiveStats;



-- Paso 6: Crear la dimensión de estadísticas de porteros
CREATE TABLE Dim_GoalkeepingStats (
	ID_player INTEGER,
	Saves INTEGER,
    `Penalties Saved` INTEGER,
    Catches INTEGER
);


-- Paso 6.1: Insertar las estadísticas de porteros 
INSERT INTO Dim_GoalkeepingStats (ID_player, Saves, `Penalties Saved`, Catches)
SELECT ID_player, Saves, `Penalties Saved`, Catches
FROM TemporaryStats;



-- Paso 6.2: Exportación de datos a un CSV
SELECT * FROM Dim_GoalkeepingStats;


SELECT * 
INTO OUTFILE '/var/lib/mysql-files/Dim_GoalkeepingStats.csv'
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''  
LINES TERMINATED BY '\n'
FROM Dim_GoalkeepingStats;






-- Pregunta: ¿Qué nacionalidades destacan en cada posición?
-- Consulta para la posición de delantero
SELECT 
    Nationality,
    ROUND(AVG(`Foward Metric`), 3) AS Avg_Foward_Metric
FROM 
    Fact_Performance
WHERE 
    Position = 'Forward'
GROUP BY 
    Nationality
ORDER BY 
    Avg_Foward_Metric DESC;
   

-- Consulta para la posición de mediocentro
SELECT 
    Nationality,
    ROUND(AVG(`Midfielder Metric`), 3) AS Avg_Midfielder_Metric
FROM 
    Fact_Performance
WHERE 
    Position = 'Midfielder'
GROUP BY 
    Nationality
ORDER BY 
    Avg_Midfielder_Metric DESC;
   

-- Consulta para la posición de defensa
SELECT 
    Nationality,
    ROUND(AVG(`Defender Metric`), 3) AS Avg_Defender_Metric
FROM 
    Fact_Performance
WHERE 
    Position = 'Defender'
GROUP BY 
    Nationality
ORDER BY 
    Avg_Defender_Metric DESC;


-- Consulta para la posición de portero
SELECT 
    Nationality,
    ROUND(AVG(`Goalkeeper Metric`), 3) AS Avg_Goalkeeper_Metric
FROM 
    Fact_Performance
WHERE 
    Position = 'Goalkeeper'
GROUP BY 
    Nationality
ORDER BY 
    Avg_Goalkeeper_Metric DESC;

   
   
-- Pregunta: ¿Quiénes son los jugadores más sobresalientes en cada posición?
-- Consulta para la posición de delantero
SELECT 
    dp.Name,
    fp.`Foward Metric`
FROM 
    Fact_Performance fp
JOIN 
    Dim_Player dp ON fp.ID_player = dp.ID_player
WHERE 
    fp.Position = 'Forward'
ORDER BY 
    fp.`Foward Metric` DESC;
 
   
-- Consulta para la posición de mediocentro   
SELECT 
    dp.Name,
    fp.`Midfielder Metric`
FROM 
    Fact_Performance fp
JOIN 
    Dim_Player dp ON fp.ID_player = dp.ID_player
WHERE 
    fp.Position = 'Midfielder'
ORDER BY 
    fp.`Midfielder Metric` DESC;

   
-- Consulta para la posición de defensa 
SELECT 
    dp.Name,
    fp.`Defender Metric`
FROM 
    Fact_Performance fp
JOIN 
    Dim_Player dp ON fp.ID_player = dp.ID_player
WHERE 
    fp.Position = 'Defender'
ORDER BY 
    fp.`Defender Metric` DESC;

   
-- Consulta para la posición de portero
SELECT 
    dp.Name,
    fp.`Goalkeeper Metric`
FROM 
    Fact_Performance fp
JOIN 
    Dim_Player dp ON fp.ID_player = dp.ID_player
WHERE 
    fp.Position = 'Goalkeeper'
ORDER BY 
    fp.`Goalkeeper Metric` DESC;
    
   
   
-- Pregunta: ¿Podría haber algún jugador que rinda mejor en otra posición?
SELECT 
    dp.Name,
    fp.`Midfielder Metric`, 
    fp.`Defender Metric`
FROM 
    Fact_Performance fp
JOIN 
    Dim_Player dp ON fp.ID_player = dp.ID_player
WHERE 
    fp.Position = 'Defender'
ORDER BY 
    fp.`Midfielder Metric` DESC;
    

SELECT 
    dp.Name,
    fp.`Defender Metric`,
    fp.`Midfielder Metric`
FROM 
    Fact_Performance fp
JOIN 
    Dim_Player dp ON fp.ID_player = dp.ID_player
WHERE 
    fp.Position = 'Midfielder'
ORDER BY 
    fp.`Defender Metric` DESC;