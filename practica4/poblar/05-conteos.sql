-- 05-conteos.sql | Fotografia de los conteos antes de una carga.
-- Este registro temporal desaparece al terminar la conexion de psql.
CREATE TEMP TABLE conteos_antes AS
SELECT 'administrativo'::text AS tabla, COUNT(*)::bigint AS antes FROM administrativo
UNION ALL
SELECT 'cliente'::text AS tabla, COUNT(*)::bigint AS antes FROM cliente
UNION ALL
SELECT 'cliente_telefono'::text AS tabla, COUNT(*)::bigint AS antes FROM cliente_telefono
UNION ALL
SELECT 'contrato'::text AS tabla, COUNT(*)::bigint AS antes FROM contrato
UNION ALL
SELECT 'empleado'::text AS tabla, COUNT(*)::bigint AS antes FROM empleado
UNION ALL
SELECT 'inspeccion'::text AS tabla, COUNT(*)::bigint AS antes FROM inspeccion
UNION ALL
SELECT 'mecanico'::text AS tabla, COUNT(*)::bigint AS antes FROM mecanico
UNION ALL
SELECT 'modelo'::text AS tabla, COUNT(*)::bigint AS antes FROM modelo
UNION ALL
SELECT 'pago_semanal'::text AS tabla, COUNT(*)::bigint AS antes FROM pago_semanal
UNION ALL
SELECT 'refaccion'::text AS tabla, COUNT(*)::bigint AS antes FROM refaccion
UNION ALL
SELECT 'reparacion'::text AS tabla, COUNT(*)::bigint AS antes FROM reparacion
UNION ALL
SELECT 'revision'::text AS tabla, COUNT(*)::bigint AS antes FROM revision
UNION ALL
SELECT 'vehiculo'::text AS tabla, COUNT(*)::bigint AS antes FROM vehiculo;
