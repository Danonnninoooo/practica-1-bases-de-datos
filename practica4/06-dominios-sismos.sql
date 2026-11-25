\pset pager off
\set ON_ERROR_STOP on
BEGIN;
\echo === PRACTICA 4: RESTRICCIONES DE DOMINIO EN SISMOS ===
SELECT current_database() AS base;
\echo === RESTRICCIONES EXISTENTES ===
SELECT conrelid::regclass AS tabla,contype,count(*) AS cantidad
FROM pg_constraint WHERE connamespace='public'::regnamespace GROUP BY 1,2 ORDER BY 1,2;
SELECT table_name,count(*) FILTER (WHERE is_nullable='NO') AS obligatorias,
 count(*) FILTER (WHERE is_nullable='YES') AS admiten_nulos
FROM information_schema.columns WHERE table_schema='public'
AND table_name IN ('dim_sismos','dim_tiempo','dim_zonas','dim_economia','fact_impacto_sismos_imputed')
GROUP BY table_name ORDER BY table_name;
\echo === COPIAS TEMPORALES DE DIMENSIONES ===
CREATE TEMP TABLE sismos_copia AS SELECT * FROM public.dim_sismos;
CREATE TEMP TABLE tiempo_copia AS SELECT * FROM public.dim_tiempo;
\echo === PROPUESTAS Y DIAGNOSTICO SOBRE DATOS EXISTENTES ===
SELECT count(*) AS filas,
 count(*) FILTER (WHERE latitud NOT BETWEEN -90 AND 90) AS latitudes_fuera,
 count(*) FILTER (WHERE longitud NOT BETWEEN -180 AND 180) AS longitudes_fuera,
 count(*) FILTER (WHERE latitud IS NULL) AS latitudes_nulas,
 count(*) FILTER (WHERE longitud IS NULL) AS longitudes_nulas
FROM sismos_copia;
SELECT count(*) AS filas,count(*) FILTER (WHERE mes NOT BETWEEN 1 AND 12) AS meses_fuera,
 count(*) FILTER (WHERE mes IS NULL) AS meses_nulos FROM tiempo_copia;
ALTER TABLE sismos_copia ADD CONSTRAINT ck_latitud_propuesta CHECK (latitud BETWEEN -90 AND 90) NOT VALID;
ALTER TABLE sismos_copia ADD CONSTRAINT ck_longitud_propuesta CHECK (longitud BETWEEN -180 AND 180) NOT VALID;
ALTER TABLE tiempo_copia ADD CONSTRAINT ck_mes_propuesta CHECK (mes BETWEEN 1 AND 12) NOT VALID;
DO $$
DECLARE r record; c text;
BEGIN
  FOR r IN SELECT * FROM (VALUES ('sismos_copia','ck_latitud_propuesta'),
    ('sismos_copia','ck_longitud_propuesta'),('tiempo_copia','ck_mes_propuesta')) t(tabla,regla)
  LOOP
    BEGIN
      EXECUTE format('ALTER TABLE %I VALIDATE CONSTRAINT %I',r.tabla,r.regla);
      RAISE NOTICE 'DATOS EXISTENTES CUMPLEN: %',r.regla;
    EXCEPTION WHEN check_violation THEN
      RAISE NOTICE 'DATOS EXISTENTES NO CUMPLEN: % | %',r.regla,SQLERRM;
    END;
  END LOOP;
  FOR r IN SELECT * FROM (VALUES
    ('INSERT INTO sismos_copia(latitud) VALUES (91)','ck_latitud_propuesta'),
    ('INSERT INTO sismos_copia(longitud) VALUES (-181)','ck_longitud_propuesta'),
    ('INSERT INTO tiempo_copia(mes) VALUES (13)','ck_mes_propuesta')) t(sentencia,regla)
  LOOP
    BEGIN
      EXECUTE r.sentencia;
      RAISE EXCEPTION 'Dato invalido aceptado: %',r.regla;
    EXCEPTION WHEN check_violation THEN
      GET STACKED DIAGNOSTICS c=CONSTRAINT_NAME;
      IF c<>r.regla THEN RAISE; END IF;
      RAISE NOTICE 'RECHAZO ESPERADO: SQLSTATE % | % | %',SQLSTATE,c,SQLERRM;
    END;
  END LOOP;
END $$;
SELECT conname,convalidated FROM pg_constraint
WHERE conrelid IN ('pg_temp.sismos_copia'::regclass,'pg_temp.tiempo_copia'::regclass)
ORDER BY conname;
ROLLBACK;
\echo === FIN: TABLAS ORIGINALES INTACTAS ===
