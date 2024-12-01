-- El principal objetivo de este script es realizar la extracción de datos
USE MiBaseDeDatos;


-- Primer archivo CSV: player_overview.csv
-- Paso 1: Crear la tabla de destino 
CREATE TABLE IF NOT EXISTS TemporaryOverview (
    Name VARCHAR(100),
    Nationality VARCHAR(100),
    `Date of Birth` VARCHAR(100),  
    Height VARCHAR(100),          
    Club VARCHAR(100),
    Position VARCHAR(100),
    Appearances INTEGER,            
    Goals INTEGER,
    Assists INTEGER,
    `Clean sheets`  INTEGER,
    Facebook VARCHAR(100)
);



-- Paso 2: Leer el CSV e insertar en la tabla
LOAD DATA INFILE '/var/lib/mysql-files/player_overview.csv' 
INTO TABLE TemporaryOverview
FIELDS TERMINATED BY ',' 
ENCLOSED BY ''  
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Name, Nationality, `Date of Birth`, Height, Club, Position, 
    @Appearances, @Goals, @Assists, @CleanSheets, Facebook)
SET 
    Appearances = IF(@Appearances = '', NULL, @Appearances),
    Goals = IF(@Goals = '', NULL, @Goals),
    Assists = IF(@Assists = '', NULL, @Assists),
    `Clean sheets` = IF(@CleanSheets = '', NULL, @CleanSheets);



-- Paso 3: Verificar cantidad de filas importadas
SET @total_esperado = 1018;  


SELECT 
    @total_esperado AS total_esperado,
    COUNT(*) AS total_real,
    CASE
        WHEN @total_esperado = COUNT(*) THEN 'Importación exitosa'
        ELSE 'Error: las filas importadas no coinciden'
    END AS resultado
FROM TemporaryOverview;



-- Segundo archivo CSV: player_stats.csv
-- Paso 1: Crear la tabla de destino 
CREATE TABLE IF NOT EXISTS TemporaryStats (
    Name VARCHAR(100),
    Twitter VARCHAR(100),
    Instagram VARCHAR(100),
    Appearances INTEGER,
    Goals INTEGER,
    Wins INTEGER,
    Losses INTEGER,
    `Clean sheets` INTEGER,
    `Goals Conceded` INTEGER,
    Tackles INTEGER,
    `Tackle success %` VARCHAR(10), 
    `Last man tackles` INTEGER,
    `Blocked shots` INTEGER,
    Interceptions INTEGER,
    Clearances INTEGER,
    `Headed Clearance` INTEGER,
    `Clearances off line` INTEGER,
    Recoveries INTEGER,
    `Duels won` INTEGER,
    `Duels lost` INTEGER,
    `Successful 50/50s` INTEGER,
    `Aerial battles won` INTEGER,
    `Aerial battles lost` INTEGER,
    `Own goals` INTEGER,
    `Errors leading to goal` INTEGER,
    Assists INTEGER,
    Passes VARCHAR(10),  -- Los separadores de miles son ,
    `Passes per match` FLOAT,
    `Big Chances Created` INTEGER,
    Crosses INTEGER,
    `Cross accuracy %` VARCHAR(10), 
    `Through balls` INTEGER,
    `Accurate long balls` INTEGER,
    `Yellow cards` INTEGER,
    `Red cards` INTEGER,
    Fouls INTEGER,
    Offsides INTEGER,
    `Headed goals` INTEGER,
    `Goals with right foot` INTEGER,
    `Goals with left foot` INTEGER,
    `Hit woodwork` INTEGER,
    `Goals per match` INTEGER,
    `Penalties scored` INTEGER,
    `Freekicks scored` INTEGER,
    Shots INTEGER,
    `Shots on target` INTEGER,
    `Shooting accuracy %` VARCHAR(10), 
    `Big chances missed` INTEGER,
    Saves INTEGER,
    `Penalties Saved` INTEGER,
    Punches INTEGER,
    `High Claims` INTEGER,
    Catches INTEGER,
    `Sweeper clearances` INTEGER,
    `Throw outs` INTEGER,
    `Goal Kicks` INTEGER,
    Facebook VARCHAR(100)
);



-- Paso 2: Leer el CSV e insertarlo en la tabla
-- Debido a la gran cantidad de columnas y al hecho de que los números de la columna "Passes" utilizan comas como 
-- separadores de miles (lo cual puede confundirse con los delimitadores del CSV), optamos por cargar el archivo CSV
-- manualmente en la tabla. Para ello, utilizamos la opción de importar datos a través del clic derecho en la tabla.



-- Paso 3: Verificar cantidad de filas importadas
SET @total_esperado = 1019;  


SELECT 
    @total_esperado AS total_esperado,
    COUNT(*) AS total_real,
    CASE
        WHEN @total_esperado = COUNT(*) THEN 'Importación exitosa'
        ELSE 'Error: las filas importadas no coinciden'
    END AS resultado
FROM TemporaryStats;