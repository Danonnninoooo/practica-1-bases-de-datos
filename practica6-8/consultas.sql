\pset pager off
BEGIN READ ONLY;
\echo === 01 Selección ===
SELECT vin,color,anio,id_modelo FROM vehiculo WHERE color='Blanco';

\echo === 02 Proyección ===
SELECT DISTINCT marca FROM modelo;

\echo === 03 Unión ===
SELECT vin FROM vehiculo WHERE color='Blanco' UNION SELECT vin FROM vehiculo WHERE anio=2020;

\echo === 04 Intersección ===
SELECT vin FROM vehiculo WHERE color='Blanco' INTERSECT SELECT vin FROM vehiculo WHERE anio=2020;

\echo === 05 Diferencia ===
SELECT vin FROM vehiculo WHERE color='Blanco' EXCEPT SELECT vin FROM vehiculo WHERE anio=2020;

\echo === 06 Producto cartesiano ===
SELECT DISTINCT c.estado,s.num_semana FROM contrato c CROSS JOIN (VALUES (1),(2),(3),(4)) AS s(num_semana);

\echo === 07 Reunión natural y selección ===
SELECT v.vin,m.marca,m.nombre FROM vehiculo v JOIN modelo m ON v.id_modelo=m.id_modelo WHERE v.vin='TEST0000000000001';

\echo === 08 Agrupación ===
SELECT color,COUNT(*) AS cantidad FROM vehiculo GROUP BY color;

\echo === 09 División ===
SELECT DISTINCT p.id_contrato FROM pago_semanal p WHERE NOT EXISTS (SELECT 1 FROM (VALUES (1),(2),(3),(4)) AS s(num_semana) WHERE NOT EXISTS (SELECT 1 FROM pago_semanal q WHERE q.id_contrato=p.id_contrato AND q.num_semana=s.num_semana));
\echo === RESUMEN DE CARDINALIDADES ===
SELECT '01' AS ejercicio,COUNT(*) AS filas FROM (SELECT vin,color,anio,id_modelo FROM vehiculo WHERE color='Blanco') AS resultado
UNION ALL
SELECT '02' AS ejercicio,COUNT(*) AS filas FROM (SELECT DISTINCT marca FROM modelo) AS resultado
UNION ALL
SELECT '03' AS ejercicio,COUNT(*) AS filas FROM (SELECT vin FROM vehiculo WHERE color='Blanco' UNION SELECT vin FROM vehiculo WHERE anio=2020) AS resultado
UNION ALL
SELECT '04' AS ejercicio,COUNT(*) AS filas FROM (SELECT vin FROM vehiculo WHERE color='Blanco' INTERSECT SELECT vin FROM vehiculo WHERE anio=2020) AS resultado
UNION ALL
SELECT '05' AS ejercicio,COUNT(*) AS filas FROM (SELECT vin FROM vehiculo WHERE color='Blanco' EXCEPT SELECT vin FROM vehiculo WHERE anio=2020) AS resultado
UNION ALL
SELECT '06' AS ejercicio,COUNT(*) AS filas FROM (SELECT DISTINCT c.estado,s.num_semana FROM contrato c CROSS JOIN (VALUES (1),(2),(3),(4)) AS s(num_semana)) AS resultado
UNION ALL
SELECT '07' AS ejercicio,COUNT(*) AS filas FROM (SELECT v.vin,m.marca,m.nombre FROM vehiculo v JOIN modelo m ON v.id_modelo=m.id_modelo WHERE v.vin='TEST0000000000001') AS resultado
UNION ALL
SELECT '08' AS ejercicio,COUNT(*) AS filas FROM (SELECT color,COUNT(*) AS cantidad FROM vehiculo GROUP BY color) AS resultado
UNION ALL
SELECT '09' AS ejercicio,COUNT(*) AS filas FROM (SELECT DISTINCT p.id_contrato FROM pago_semanal p WHERE NOT EXISTS (SELECT 1 FROM (VALUES (1),(2),(3),(4)) AS s(num_semana) WHERE NOT EXISTS (SELECT 1 FROM pago_semanal q WHERE q.id_contrato=p.id_contrato AND q.num_semana=s.num_semana))) AS resultado ORDER BY ejercicio;
COMMIT;
