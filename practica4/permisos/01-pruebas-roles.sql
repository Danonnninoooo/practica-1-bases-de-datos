\pset pager off
\set ON_ERROR_STOP on
\echo === PRACTICA 4: PRUEBAS DE PERMISOS ===
BEGIN;
\echo === 01 USUARIO DE APLICACION ===
SET LOCAL ROLE usuario_app_renta;
SELECT current_user AS usuario, count(*) AS modelos FROM modelo;
INSERT INTO modelo(id_modelo,marca,nombre,litros_motor)
VALUES(-980001,'Prueba permisos','Temporal',1.6)
RETURNING id_modelo,marca,nombre;
UPDATE modelo SET litros_motor=2.0 WHERE id_modelo=-980001 RETURNING litros_motor;
DELETE FROM modelo WHERE id_modelo=-980001 RETURNING id_modelo;
DO $$
BEGIN
  BEGIN
    EXECUTE 'CREATE TABLE public.prueba_permiso_980001 (id int)';
    RAISE EXCEPTION 'El usuario app pudo crear una tabla permanente';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'RECHAZO ESPERADO: SQLSTATE % | %',SQLSTATE,SQLERRM;
  END;
END $$;
RESET ROLE;
\echo === 02 USUARIO DE CONSULTA ===
SET LOCAL ROLE usuario_consulta_renta;
SELECT current_user AS usuario,count(*) AS modelos FROM modelo;
DO $$
BEGIN
  BEGIN
    UPDATE modelo SET nombre=nombre WHERE id_modelo=-980001;
    RAISE EXCEPTION 'Consulta pudo ejecutar UPDATE';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'RECHAZO ESPERADO: SQLSTATE % | %',SQLSTATE,SQLERRM;
  END;
END $$;
RESET ROLE;
\echo === 03 USUARIO DE ADMINISTRACION ===
SET LOCAL ROLE usuario_admin_renta;
SELECT current_user AS usuario;
CREATE TABLE public.prueba_permiso_980001(id int PRIMARY KEY);
INSERT INTO public.prueba_permiso_980001 VALUES(1);
SELECT * FROM public.prueba_permiso_980001;
DROP TABLE public.prueba_permiso_980001;
DO $$
BEGIN
  BEGIN
    EXECUTE 'ALTER TABLE public.modelo ADD COLUMN prueba_permiso_980001 int';
    RAISE EXCEPTION 'Admin pudo alterar una tabla ajena';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'RECHAZO ESPERADO: SQLSTATE % | %',SQLSTATE,SQLERRM;
  END;
END $$;
RESET ROLE;
\echo === 04 MATRIZ DE PERMISOS EFECTIVOS: TABLAS ===
SELECT t.tablename AS tabla,r.rol AS usuario,
  concat_ws('/',CASE WHEN has_table_privilege(r.rol,format('public.%I',t.tablename),'SELECT') THEN 'S' END,
  CASE WHEN has_table_privilege(r.rol,format('public.%I',t.tablename),'INSERT') THEN 'I' END,
  CASE WHEN has_table_privilege(r.rol,format('public.%I',t.tablename),'UPDATE') THEN 'U' END,
  CASE WHEN has_table_privilege(r.rol,format('public.%I',t.tablename),'DELETE') THEN 'D' END,
  CASE WHEN has_table_privilege(r.rol,format('public.%I',t.tablename),'TRUNCATE') THEN 'T' END,
  CASE WHEN has_table_privilege(r.rol,format('public.%I',t.tablename),'REFERENCES') THEN 'R' END,
  CASE WHEN has_table_privilege(r.rol,format('public.%I',t.tablename),'TRIGGER') THEN 'G' END) AS permisos
FROM pg_tables t CROSS JOIN (VALUES ('usuario_app_renta'),('usuario_consulta_renta'),('usuario_admin_renta')) r(rol)
WHERE t.schemaname='public' ORDER BY t.tablename,r.rol;
ROLLBACK;
\echo === FIN: NO QUEDAN CAMBIOS ===
