-- 90-resumen.sql | Resumen de todas las tablas al terminar.
-- 'rechazados' se registra en cero para estas filas generadas y válidas.
-- Si falla una restricción, ON_ERROR_STOP y -1 revierten toda la transacción.
WITH despues AS (
SELECT 'administrativo'::text AS tabla, COUNT(*)::bigint AS total FROM administrativo
UNION ALL
SELECT 'cliente'::text AS tabla, COUNT(*)::bigint AS total FROM cliente
UNION ALL
SELECT 'cliente_telefono'::text AS tabla, COUNT(*)::bigint AS total FROM cliente_telefono
UNION ALL
SELECT 'contrato'::text AS tabla, COUNT(*)::bigint AS total FROM contrato
UNION ALL
SELECT 'empleado'::text AS tabla, COUNT(*)::bigint AS total FROM empleado
UNION ALL
SELECT 'inspeccion'::text AS tabla, COUNT(*)::bigint AS total FROM inspeccion
UNION ALL
SELECT 'mecanico'::text AS tabla, COUNT(*)::bigint AS total FROM mecanico
UNION ALL
SELECT 'modelo'::text AS tabla, COUNT(*)::bigint AS total FROM modelo
UNION ALL
SELECT 'pago_semanal'::text AS tabla, COUNT(*)::bigint AS total FROM pago_semanal
UNION ALL
SELECT 'refaccion'::text AS tabla, COUNT(*)::bigint AS total FROM refaccion
UNION ALL
SELECT 'reparacion'::text AS tabla, COUNT(*)::bigint AS total FROM reparacion
UNION ALL
SELECT 'revision'::text AS tabla, COUNT(*)::bigint AS total FROM revision
UNION ALL
SELECT 'vehiculo'::text AS tabla, COUNT(*)::bigint AS total FROM vehiculo
)
SELECT d.tabla, a.antes, d.total - a.antes AS insertados,
       0 AS rechazados_por_restriccion,
       d.total AS total_actual
FROM despues d
JOIN conteos_antes a USING (tabla)
ORDER BY d.tabla;

-- Estos 650 no son rechazos de integridad: son registros NHTSA no seleccionados
-- deliberadamente mediante la lista de autos de renta.
SELECT (SELECT COUNT(*) FROM vpic) AS registros_vpic,
       (SELECT COUNT(*) FROM candidatos) AS modelos_seleccionados,
       (SELECT COUNT(*) FROM vpic) - (SELECT COUNT(*) FROM candidatos) AS fuera_de_lista;
