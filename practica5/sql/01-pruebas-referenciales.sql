\pset pager off
\echo === PRACTICA 5: INVENTARIO Y ACCIONES REFERENCIALES ===
BEGIN;
SELECT conname AS fk, conrelid::regclass AS hija, confrelid::regclass AS padre,
       pg_get_constraintdef(oid) AS definicion
FROM pg_constraint WHERE contype='f' AND connamespace='public'::regnamespace
ORDER BY conname;

\echo === 01 DELETE CASCADE: REVISION E INSPECCION ===
DO $$
DECLARE k integer; a integer; b integer; ar integer; br integer;
BEGIN
  SELECT i.folio INTO STRICT k FROM inspeccion i ORDER BY i.folio LIMIT 1;
  SELECT count(*) INTO a FROM inspeccion;
  SELECT count(*) INTO ar FROM revision;
  RAISE NOTICE 'ANTES: revision %, inspeccion %, folio elegido %',ar,a,k;
  DELETE FROM revision WHERE folio=k;
  SELECT count(*) INTO b FROM inspeccion;
  SELECT count(*) INTO br FROM revision;
  RAISE NOTICE 'DESPUES: revision %, inspeccion %, hijas eliminadas %',br,b,a-b;
  IF br<>ar-1 OR b>=a OR EXISTS(SELECT 1 FROM inspeccion WHERE folio=k) THEN
    RAISE EXCEPTION 'CASCADE no cumple lo esperado';
  END IF;
END $$;

\echo === 02 DELETE RESTRICT: MODELO CON VEHICULOS ===
DO $$
DECLARE k integer; a integer; b integer; c text; ar integer; br integer;
BEGIN
  SELECT id_modelo INTO STRICT k FROM vehiculo ORDER BY vin LIMIT 1;
  SELECT count(*) INTO a FROM modelo;
  SELECT count(*) INTO ar FROM vehiculo;
  RAISE NOTICE 'ANTES: modelo %, vehiculo %, modelo elegido %',a,ar,k;
  BEGIN
    DELETE FROM modelo WHERE id_modelo=k;
    RAISE EXCEPTION 'RESTRICT no rechazo el borrado';
  EXCEPTION WHEN foreign_key_violation THEN
    GET STACKED DIAGNOSTICS c=CONSTRAINT_NAME;
    IF c<>'fk_vehiculo_modelo' THEN RAISE; END IF;
    RAISE NOTICE 'RECHAZO ESPERADO: SQLSTATE % | % | %',SQLSTATE,c,SQLERRM;
  END;
  SELECT count(*) INTO b FROM modelo;
  SELECT count(*) INTO br FROM vehiculo;
  RAISE NOTICE 'DESPUES: modelo %, vehiculo %',b,br;
  IF a<>b OR ar<>br THEN RAISE EXCEPTION 'Conteos cambiaron'; END IF;
END $$;

\echo === 03 UPDATE CASCADE: CAMBIO DE FOLIO ===
DO $$
DECLARE k integer; a integer; b integer; total_a integer; total_b integer;
BEGIN
  IF EXISTS(SELECT 1 FROM revision WHERE folio=-900001) THEN RAISE EXCEPTION 'Clave de prueba ocupada'; END IF;
  SELECT i.folio INTO STRICT k FROM inspeccion i ORDER BY i.folio LIMIT 1;
  SELECT count(*) INTO a FROM inspeccion WHERE folio=k;
  SELECT count(*) INTO total_a FROM inspeccion;
  RAISE NOTICE 'ANTES: folio %, hijas %, total inspecciones %',k,a,total_a;
  UPDATE revision SET folio=-900001 WHERE folio=k;
  SELECT count(*) INTO b FROM inspeccion WHERE folio=-900001;
  SELECT count(*) INTO total_b FROM inspeccion;
  RAISE NOTICE 'DESPUES: folio -900001, hijas %, total inspecciones %',b,total_b;
  IF a<>b OR total_a<>total_b OR EXISTS(SELECT 1 FROM inspeccion WHERE folio=k) THEN
    RAISE EXCEPTION 'UPDATE CASCADE no cumple lo esperado';
  END IF;
END $$;

\echo === 04 FK INEXISTENTE Y ORDEN DE CARGA ===
DO $$
DECLARE c text; a integer; b integer; cl integer; v char(17);
BEGIN
  IF EXISTS(SELECT 1 FROM contrato WHERE id_contrato=-900001) THEN RAISE EXCEPTION 'Clave de prueba ocupada'; END IF;
  SELECT cod_cliente,vin INTO STRICT cl,v FROM contrato ORDER BY id_contrato LIMIT 1;
  SELECT count(*) INTO a FROM pago_semanal;
  RAISE NOTICE 'ANTES: pagos %',a;
  BEGIN
    INSERT INTO pago_semanal(id_contrato,num_semana,monto,fecha) VALUES(-900001,1,2500,DATE '2026-01-08');
    RAISE EXCEPTION 'Se acepto una FK inexistente';
  EXCEPTION WHEN foreign_key_violation THEN
    GET STACKED DIAGNOSTICS c=CONSTRAINT_NAME;
    IF c<>'fk_pago_contrato' THEN RAISE; END IF;
    RAISE NOTICE 'RECHAZO ESPERADO: SQLSTATE % | % | %',SQLSTATE,c,SQLERRM;
  END;
  SELECT count(*) INTO b FROM pago_semanal;
  IF a<>b THEN RAISE EXCEPTION 'Cambio inesperado'; END IF;
  INSERT INTO contrato(id_contrato,cod_cliente,vin,fecha_inicio,pago_semanal,estado,fecha_cierre)
    VALUES(-900001,cl,v,DATE '2026-01-01',2500,'CERRADO',DATE '2026-01-08');
  INSERT INTO pago_semanal(id_contrato,num_semana,monto,fecha) VALUES(-900001,1,2500,DATE '2026-01-08');
  SELECT count(*) INTO b FROM pago_semanal;
  RAISE NOTICE 'PADRE PRIMERO: contrato creado y pago aceptado; total pagos %',b;
  IF b<>a+1 THEN RAISE EXCEPTION 'Carga ordenada no cumple lo esperado'; END IF;
END $$;
ROLLBACK;
\echo === FIN: CAMBIOS REVERTIDOS ===
SELECT (SELECT count(*) FROM revision) AS revisiones,
       (SELECT count(*) FROM inspeccion) AS inspecciones,
       (SELECT count(*) FROM contrato) AS contratos,
       (SELECT count(*) FROM pago_semanal) AS pagos;
