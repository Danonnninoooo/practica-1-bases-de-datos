\pset pager off
\set ON_ERROR_STOP on
SELECT current_database()='practica45_dml' AS es_copia \gset
\if :es_copia
\else
  \echo ERROR: usar exclusivamente practica45_dml
  \quit
\endif
\echo === EJERCICIO INDIVIDUAL: REFACCION Y REPARACION ===
BEGIN;
SELECT cod_refaccion AS pieza FROM reparacion ORDER BY cod_refaccion LIMIT 1 \gset
SELECT count(*) AS refacciones_antes FROM refaccion;
SELECT count(*) AS reparaciones_antes FROM reparacion;
SELECT count(*) AS reparaciones_de_la_pieza FROM reparacion WHERE cod_refaccion=:pieza;
\echo === RESTRICT ORIGINAL ===
SAVEPOINT antes_borrado;
\set ON_ERROR_STOP off
DELETE FROM refaccion WHERE cod_refaccion=:pieza;
\set codigo :SQLSTATE
\set ON_ERROR_STOP on
ROLLBACK TO SAVEPOINT antes_borrado;
SELECT :'codigo' AS sqlstate_esperado_23503;
SELECT count(*) AS refacciones_restrict FROM refaccion;
SELECT count(*) AS reparaciones_restrict FROM reparacion;
\echo === CAMBIO A CASCADE EN LA COPIA ===
ALTER TABLE reparacion DROP CONSTRAINT fk_rep_refaccion;
ALTER TABLE reparacion ADD CONSTRAINT fk_rep_refaccion
FOREIGN KEY (cod_refaccion) REFERENCES refaccion(cod_refaccion)
ON DELETE CASCADE ON UPDATE CASCADE;
DELETE FROM refaccion WHERE cod_refaccion=:pieza RETURNING cod_refaccion,nombre;
SELECT count(*) AS refacciones_cascade FROM refaccion;
SELECT count(*) AS reparaciones_cascade FROM reparacion;
SELECT count(*) AS reparaciones_de_la_pieza_restantes FROM reparacion WHERE cod_refaccion=:pieza;
ROLLBACK;
\echo === RESTAURACION ===
SELECT count(*) AS refacciones_restauradas FROM refaccion;
SELECT count(*) AS reparaciones_restauradas FROM reparacion;
SELECT pg_get_constraintdef(oid) AS accion_restaurada FROM pg_constraint
WHERE conname='fk_rep_refaccion' AND conrelid='public.reparacion'::regclass;
