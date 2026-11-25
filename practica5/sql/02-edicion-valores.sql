\pset pager off
\set ON_ERROR_STOP on
SELECT current_database() = 'practica45_dml' AS es_copia \gset
\if :es_copia
\else
  \echo ERROR: ejecutar exclusivamente en la copia practica45_dml
  \quit
\endif
\echo === 01 DML: INSERT SELECT, CONFLICT, UPDATE FROM, CASE, DELETE Y CIERRE LOGICO ===
BEGIN;
-- Se toma un cliente/vehiculo ya existente. Contrato cerrado para no duplicar vigentes.
INSERT INTO contrato(id_contrato,cod_cliente,vin,fecha_inicio,pago_semanal,estado,fecha_cierre)
SELECT -910001,cod_cliente,vin,fecha_inicio,pago_semanal,'CERRADO',fecha_inicio+28
FROM contrato WHERE id_contrato>0 ORDER BY id_contrato LIMIT 1;
INSERT INTO pago_semanal(id_contrato,num_semana,monto,fecha)
SELECT id_contrato,1,pago_semanal,fecha_inicio FROM contrato WHERE id_contrato=-910001;
INSERT INTO pago_semanal(id_contrato,num_semana,monto,fecha)
SELECT id_contrato,1,pago_semanal,fecha_inicio FROM contrato WHERE id_contrato=-910001
ON CONFLICT(id_contrato,num_semana) DO NOTHING;
SELECT 'pago inicial sin duplicados' AS prueba,count(*) FROM pago_semanal WHERE id_contrato=-910001;
UPDATE contrato SET pago_semanal=2500 WHERE id_contrato=-910001;
UPDATE pago_semanal p SET monto=c.pago_semanal FROM contrato c
WHERE p.id_contrato=c.id_contrato AND p.id_contrato=-910001
RETURNING p.id_contrato,p.num_semana,p.monto;
UPDATE revision SET observaciones=CASE WHEN calificacion<15 THEN 'Requiere seguimiento' ELSE 'Condicion aceptable' END
WHERE folio IN (SELECT folio FROM revision ORDER BY calificacion,folio LIMIT 1)
OR folio IN (SELECT folio FROM revision ORDER BY calificacion DESC,folio LIMIT 1)
RETURNING folio,calificacion,observaciones;
DELETE FROM pago_semanal WHERE id_contrato IN
(SELECT id_contrato FROM contrato WHERE id_contrato=-910001 AND estado='CERRADO')
RETURNING id_contrato,num_semana;
-- Borrado logico: cierre de un contrato vigente, conserva pagos e identidad.
UPDATE contrato SET estado='CERRADO',fecha_cierre=GREATEST(CURRENT_DATE,fecha_inicio)
WHERE id_contrato=(SELECT min(id_contrato) FROM contrato WHERE estado='VIGENTE')
RETURNING id_contrato,estado,fecha_cierre;
SELECT c.id_contrato,c.estado,count(p.num_semana) AS pagos_conservados
FROM contrato c LEFT JOIN pago_semanal p USING(id_contrato)
WHERE c.id_contrato=(SELECT min(id_contrato) FROM contrato WHERE id_contrato>0 AND estado='CERRADO' AND fecha_cierre=GREATEST(CURRENT_DATE,fecha_inicio))
GROUP BY c.id_contrato,c.estado;
ROLLBACK;
\echo === 02 TRANSACCION CON SAVEPOINT Y COMMIT ===
BEGIN;
INSERT INTO contrato(id_contrato,cod_cliente,vin,fecha_inicio,pago_semanal,estado,fecha_cierre)
SELECT -910002,cod_cliente,vin,fecha_inicio,pago_semanal,'CERRADO',fecha_inicio+28
FROM contrato WHERE id_contrato>0 ORDER BY id_contrato LIMIT 1;
INSERT INTO pago_semanal(id_contrato,num_semana,monto,fecha)
SELECT id_contrato,1,pago_semanal,fecha_inicio FROM contrato WHERE id_contrato=-910002;
SELECT monto AS monto_original FROM pago_semanal WHERE id_contrato=-910002;
SAVEPOINT antes_ajuste;
UPDATE pago_semanal SET monto=3000 WHERE id_contrato=-910002 RETURNING monto AS monto_ajustado;
ROLLBACK TO SAVEPOINT antes_ajuste;
SELECT monto AS monto_restaurado FROM pago_semanal WHERE id_contrato=-910002;
COMMIT;
SELECT c.id_contrato,c.estado,p.num_semana,p.monto
FROM contrato c JOIN pago_semanal p USING(id_contrato) WHERE c.id_contrato=-910002;
\echo === 03 TRANSACCION FALLIDA: DOMINIO DE MONTO ===
SELECT count(*) AS contratos_antes FROM contrato;
SELECT count(*) AS pagos_antes FROM pago_semanal;
BEGIN;
INSERT INTO contrato(id_contrato,cod_cliente,vin,fecha_inicio,pago_semanal,estado,fecha_cierre)
SELECT -910003,cod_cliente,vin,fecha_inicio,pago_semanal,'CERRADO',fecha_inicio+28
FROM contrato WHERE id_contrato>0 ORDER BY id_contrato LIMIT 1;
\set ON_ERROR_STOP off
INSERT INTO pago_semanal(id_contrato,num_semana,monto,fecha)
VALUES(-910003,1,-100,DATE '2025-01-01');
\set estado_error :SQLSTATE
\set ON_ERROR_STOP on
ROLLBACK;
SELECT :'estado_error' AS sqlstate_esperado_23514;
SELECT count(*) AS contratos_despues FROM contrato;
SELECT count(*) AS pagos_despues FROM pago_semanal;
SELECT count(*) AS contrato_fallido FROM contrato WHERE id_contrato=-910003;
SELECT count(*) AS pago_fallido FROM pago_semanal WHERE id_contrato=-910003;
\echo === 04 LIMPIEZA DEL CONTRATO DE PRUEBA CONFIRMADO (SOLO COPIA) ===
DELETE FROM contrato WHERE id_contrato=-910002 RETURNING id_contrato;
SELECT count(*) AS pagos_de_prueba_restantes FROM pago_semanal WHERE id_contrato=-910002;
\echo === FIN ===
