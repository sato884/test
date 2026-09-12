-- Cargar las 27 columnas reales del dataset de Steam
juegos_raw = LOAD '/user/cloudera/proyecto/raw/games_sqoop' USING PigStorage('\t') AS (
    AppID:chararray,
    Name:chararray,
    Release_date:chararray,
    Estimated_owners:chararray,
    Peak_CCU:long,
    Required_age:int,
    Price:float,
    DiscountDLC_count:int,
    Supported_languages:chararray,
    Windows:chararray,
    Mac:chararray,
    Linux:chararray,
    Metacritic_score:int,
    User_score:int,
    Positive:long,
    Negative:long,
    Achievements:int,
    Recommendations:long,
    Average_playtime_forever:int,
    Average_playtime_two_weeks:int,
    Median_playtime_forever:int,
    Median_playtime_two_weeks:int,
    Developers:chararray,
    Publishers:chararray,
    Categories:chararray,
    Genres:chararray,
    Tags:chararray
);

-- Filtrar registros nulos o inconsistentes
juegos_limpios = FILTER juegos_raw BY 
    AppID IS NOT NULL AND 
    Price >= 0.0 AND 
    Peak_CCU >= 0 AND 
    (Positive + Negative) > 0;

-- Transformacion y calculo de metricas
juegos_transformados = FOREACH juegos_limpios GENERATE 
    AppID, 
    Name, 
    Price, 
    (Price == 0.0 ? 1 : 0) AS is_free_to_play:int, 
    DiscountDLC_count, 
    Achievements, 
    Positive, 
    Negative, 
    ((double)Positive / (double)(Positive + Negative)) AS satisfaction_ratio:double, 
    ((Mac == 'True' OR Linux == 'True') ? 1 : 0) AS is_multiplatform:int, 
    Median_playtime_forever, 
    Peak_CCU, 
    Genres, 
    Supported_languages;

-- Guardar resultado procesado en HDFS
STORE juegos_transformados INTO '/user/cloudera/proyecto/processed/juegos_etiquetados' USING PigStorage('\t');
