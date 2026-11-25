\pset pager off
\set ON_ERROR_STOP on
BEGIN READ ONLY;
\echo === ALMACEN SISMOS: BASE Y GESTOR ===
SELECT current_database() AS base, current_schema() AS esquema;
\echo === INVENTARIO DE PK, UNIQUE Y FK ===
SELECT conrelid::regclass AS tabla, conname, contype, convalidated,
       pg_get_constraintdef(oid) AS definicion
FROM pg_constraint WHERE connamespace='public'::regnamespace
AND contype IN ('p','u','f') ORDER BY 1,2;
\echo === HUERFANOS Y NULOS DE LAS CUATRO REFERENCIAS ===
SELECT 'id_sismo' AS clave, count(*) FILTER (WHERE f.id_sismo IS NULL) AS nulos,
 count(*) FILTER (WHERE f.id_sismo IS NOT NULL AND d.id_sismo IS NULL) AS huerfanos
FROM fact_impacto_sismos_imputed f LEFT JOIN dim_sismos d USING(id_sismo)
UNION ALL SELECT 'id_zonas',count(*) FILTER (WHERE f.id_zonas IS NULL),
 count(*) FILTER (WHERE f.id_zonas IS NOT NULL AND d.id_zonas IS NULL)
FROM fact_impacto_sismos_imputed f LEFT JOIN dim_zonas d USING(id_zonas)
UNION ALL SELECT 'id_economia',count(*) FILTER (WHERE f.id_economia IS NULL),
 count(*) FILTER (WHERE f.id_economia IS NOT NULL AND d.id_economia IS NULL)
FROM fact_impacto_sismos_imputed f LEFT JOIN dim_economia d USING(id_economia)
UNION ALL SELECT 'id_tiempo',count(*) FILTER (WHERE f.id_tiempo IS NULL),
 count(*) FILTER (WHERE f.id_tiempo IS NOT NULL AND d.id_tiempo IS NULL)
FROM fact_impacto_sismos_imputed f LEFT JOIN dim_tiempo d USING(id_tiempo);
\echo === DUPLICADOS DE CLAVES DE DIMENSION Y COMBINACION CANDIDATA DE HECHOS ===
SELECT 'dim_sismos' AS tabla,count(*) AS grupos_duplicados FROM
 (SELECT id_sismo FROM dim_sismos GROUP BY id_sismo HAVING count(*)>1) d
UNION ALL SELECT 'dim_zonas',count(*) FROM
 (SELECT id_zonas FROM dim_zonas GROUP BY id_zonas HAVING count(*)>1) d
UNION ALL SELECT 'dim_economia',count(*) FROM
 (SELECT id_economia FROM dim_economia GROUP BY id_economia HAVING count(*)>1) d
UNION ALL SELECT 'dim_tiempo',count(*) FROM
 (SELECT id_tiempo FROM dim_tiempo GROUP BY id_tiempo HAVING count(*)>1) d
UNION ALL SELECT 'hechos: cuatro referencias',count(*) FROM
 (SELECT id_sismo,id_zonas,id_economia,id_tiempo FROM fact_impacto_sismos_imputed
 GROUP BY id_sismo,id_zonas,id_economia,id_tiempo HAVING count(*)>1) d;
\echo === DUPLICADOS EXACTOS EN HECHOS ===
SELECT count(*) AS grupos_duplicados_exactos,coalesce(sum(n-1),0) AS filas_excedentes
FROM (SELECT count(*) AS n FROM fact_impacto_sismos_imputed
GROUP BY id_sismo,id_zonas,id_economia,id_tiempo,poblacion_afectada,
impacto_economico,determinante_de_riesgo,riesgo_proporcional,indice_zscore
HAVING count(*)>1) d;
\echo === NULOS EN CLAVES DE DIMENSION ===
SELECT 'dim_sismos' AS tabla,count(*) FILTER (WHERE id_sismo IS NULL) AS nulos FROM dim_sismos
UNION ALL SELECT 'dim_zonas',count(*) FILTER (WHERE id_zonas IS NULL) FROM dim_zonas
UNION ALL SELECT 'dim_economia',count(*) FILTER (WHERE id_economia IS NULL) FROM dim_economia
UNION ALL SELECT 'dim_tiempo',count(*) FILTER (WHERE id_tiempo IS NULL) FROM dim_tiempo;
\echo === NULOS EN MEDIDAS DE HECHOS (INFORMATIVO) ===
SELECT count(*) FILTER (WHERE poblacion_afectada IS NULL) AS poblacion,
 count(*) FILTER (WHERE impacto_economico IS NULL) AS impacto,
 count(*) FILTER (WHERE determinante_de_riesgo IS NULL) AS determinante,
 count(*) FILTER (WHERE riesgo_proporcional IS NULL) AS riesgo,
 count(*) FILTER (WHERE indice_zscore IS NULL) AS zscore
FROM fact_impacto_sismos_imputed;
COMMIT;
\echo === FIN: CONSULTAS DE SOLO LECTURA ===
