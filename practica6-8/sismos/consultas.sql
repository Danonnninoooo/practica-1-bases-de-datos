\pset pager off
BEGIN READ ONLY;
\echo === INVENTARIO DEL ALMACEN SISMOS ===
SELECT current_database() AS base, version() AS gestor;
SELECT 'dim_sismos' AS tabla, count(*) AS filas FROM dim_sismos
UNION ALL SELECT 'dim_tiempo',count(*) FROM dim_tiempo
UNION ALL SELECT 'dim_zonas',count(*) FROM dim_zonas
UNION ALL SELECT 'dim_economia',count(*) FROM dim_economia
UNION ALL SELECT 'fact_impacto_sismos_imputed',count(*) FROM fact_impacto_sismos_imputed;
\echo === 01 ZONAS CON MAS DE 50000 HABITANTES ===
SELECT DISTINCT pobtot,nom_ent FROM dim_zonas WHERE pobtot > 50000 ORDER BY nom_ent,pobtot;
\echo === 02 SISMOS DE MAGNITUD 6 O SUPERIOR EN 2017 ===
SELECT DISTINCT s.id_sismo,s.magnitud,t.fecha,s.profundidad
FROM dim_sismos s
JOIN fact_impacto_sismos_imputed f ON s.id_sismo=f.id_sismo
JOIN dim_tiempo t ON f.id_tiempo=t.id_tiempo
WHERE s.magnitud >= 6 AND t.fecha BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
ORDER BY t.fecha,s.id_sismo,s.magnitud,s.profundidad;
\echo === 03 PRODUCCION BRUTA TOTAL POR ENTIDAD ===
SELECT nombre_entidad,SUM(produccion_bruta_total) AS total_produccion
FROM dim_economia WHERE nombre_entidad IS NOT NULL
GROUP BY nombre_entidad ORDER BY nombre_entidad;
\echo === COMPROBACION NULOS PARA RELAX ===
SELECT count(*) FILTER (WHERE nombre_entidad IS NULL) AS nombres_nulos,
       count(*) FILTER (WHERE produccion_bruta_total IS NULL) AS produccion_nula
FROM dim_economia;
COMMIT;
