-- 1. Cargar el dataset TSV mapeando tipos numéricos reales
juegos_raw = LOAD '/user/cloudera/proyecto/raw/games_sqoop/part-m-00000' USING PigStorage('\t') AS (
    Name:chararray,
    Release_date:chararray,
    Price:double,
    Positive:long,
    Negative:long,
    Peak_CCU:long,
    Publishers:chararray,
    Developers:chararray,
    Genres:chararray,
    Supported_languages:chararray
);

-- 2. Filtrar inconsistencias y divisiones por cero
juegos_limpios = FILTER juegos_raw BY 
    Name IS NOT NULL AND 
    Price IS NOT NULL AND 
    Price >= 0.0 AND 
    (Positive + Negative) > 0;

-- 3. Proyectar conservando el precio real y calculando el ratio
juegos_transformados = FOREACH juegos_limpios GENERATE 
    1000 AS AppID:int,
    Name AS Name:chararray,
    Price AS Price:double,
    ((Price == 0.0) ? 1 : 0) AS is_free_to_play:int,
    0 AS DiscountDLC_count:int,
    0 AS Achievements:int,
    Positive AS Positive:long,
    Negative AS Negative:long,
    ((double)Positive / (double)(Positive + Negative)) AS satisfaction_ratio:double,
    1 AS is_multiplatform:int,
    0 AS Median_playtime_forever:int,
    Peak_CCU AS Peak_CCU:long,
    Genres AS Genres:chararray,
    Supported_languages AS Supported_languages:chararray;

-- 4. Almacenar resultado procesado en HDFS
STORE juegos_transformados INTO '/user/cloudera/proyecto/processed/juegos_etiquetados' USING PigStorage('\t');
