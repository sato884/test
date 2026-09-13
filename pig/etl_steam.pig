-- 1. Cargar el dataset mapeando las 27 columnas reales delimitadas por tabulacion
juegos_raw = LOAD '/user/cloudera/proyecto/raw/games_sqoop' USING PigStorage('\t') AS (
    AppID:chararray,
    Name:chararray,
    Release_date:chararray,
    Estimated_owners:chararray,
    Peak_CCU:long,
    Required_age:int,
    Price:double,
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

-- 2. Filtrar registros corruptos o encabezados de texto
juegos_limpios = FILTER juegos_raw BY 
    AppID IS NOT NULL AND 
    AppID != 'AppID' AND
    Price IS NOT NULL AND 
    Price >= 0.0 AND 
    (Positive + Negative) > 0;

-- 3. Proyectar metricas reales conservando los datos originales
juegos_transformados = FOREACH juegos_limpios GENERATE 
    AppID AS appid:chararray,
    Name AS name:chararray,
    Price AS price:double,
    ((Price == 0.0) ? 1 : 0) AS is_free_to_play:int,
    (DiscountDLC_count IS NULL ? 0 : DiscountDLC_count) AS dlc_count:int,
    (Achievements IS NULL ? 0 : Achievements) AS achievements:int,
    Positive AS positive:long,
    Negative AS negative:long,
    ((double)Positive / (double)(Positive + Negative)) AS satisfaction_ratio:double,
    ((Mac == 'True' OR Linux == 'True') ? 1 : 0) AS is_multiplatform:int,
    (Median_playtime_forever IS NULL ? 0 : Median_playtime_forever) AS median_playtime:int,
    (Peak_CCU IS NULL ? 0L : Peak_CCU) AS peak_ccu:long,
    Genres AS genres:chararray,
    Supported_languages AS supported_languages:chararray;

-- 4. Guardar salida limpia en HDFS para Hive
STORE juegos_transformados INTO '/user/cloudera/proyecto/processed/juegos_etiquetados' USING PigStorage('\t');
