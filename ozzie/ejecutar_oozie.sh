#!/bin/bash
# 1. Crear directorios base en HDFS
hdfs dfs -mkdir -p /user/cloudera/proyecto/raw/games_sqoop
hdfs dfs -mkdir -p /user/cloudera/proyecto/processed
hdfs dfs -mkdir -p /user/cloudera/proyecto/output
hdfs dfs -mkdir -p /user/cloudera/proyecto/scripts
hdfs dfs -mkdir -p /user/cloudera/proyecto/oozie

# 2. Cargar el dataset disponible en pig/ hacia la ruta esperada de Sqoop
hdfs dfs -put -f /home/cloudera/workspace/BigData_solemne_1/pig/dataset_final_hive.tsv /user/cloudera/proyecto/raw/games_sqoop/part-m-00000

# 3. Subir los scripts ejecutables a HDFS
hdfs dfs -put -f /home/cloudera/workspace/BigData_solemne_1/pig/etl_steam.pig /user/cloudera/proyecto/scripts/
hdfs dfs -put -f /home/cloudera/workspace/BigData_solemne_1/hive/analisis_steam.sql /user/cloudera/proyecto/scripts/
hdfs dfs -put -f /home/cloudera/workspace/BigData_solemne_1/oozie/workflow.xml /user/cloudera/proyecto/oozie/

# 4. Limpiar salidas previas
hdfs dfs -rm -r /user/cloudera/proyecto/processed/juegos_etiquetados 2>/dev/null || true
hdfs dfs -rm -r /user/cloudera/proyecto/output/top_satisfaccion 2>/dev/null || true

# 5. Lanzar el flujo coordinado
echo "Lanzando Workflow en Oozie..."
oozie job -oozie http://localhost:11000/oozie -config job.properties -run
