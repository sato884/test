
-- Cargar dataset TSV mapeando su estructura real
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

-- Filtrar registros nulos o inconsistentes
juegos_limpios = FILTER juegos_raw BY 
    Name IS NOT NULL AND 
    Price >= 0.0 AND 
    Peak_CCU >= 0 AND 
    (Positive + Negative) > 0;

-- Transformacion y calculo de metricas esperadas por Hive
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

-- Almacenar resultado procesado en HDFS
STORE juegos_transformados INTO '/user/cloudera/proyecto/processed/juegos_etiquetados' USING PigStorage('\t');
EOF

# Limpiar directorio previo directamente desde HDFS
hdfs dfs -rm -r /user/cloudera/proyecto/processed/juegos_etiquetados 2>/dev/null || true

# Ejecutar Pig
pig -x mapreduce /home/cloudera/workspace/test/pig/etl_steam.pig
