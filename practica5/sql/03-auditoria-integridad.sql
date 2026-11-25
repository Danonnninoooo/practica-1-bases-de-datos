\pset pager off
\echo === AUDITORIA DE RESTRICCIONES DECLARADAS (SOLO LECTURA DE DATOS) ===
BEGIN;
SELECT current_database() AS base;
CREATE TEMP TABLE auditoria (
  clase text, objeto text, infracciones bigint
);
DO $$
DECLARE r record; condicion text; union_fk text; columnas text; filtro text; n bigint;
BEGIN
  -- FK simples o compuestas con MATCH SIMPLE (las del proyecto propio).
  FOR r IN SELECT c.*, n.nspname FROM pg_constraint c
    JOIN pg_namespace n ON n.oid=c.connamespace
    WHERE c.contype='f' AND n.nspname='public'
  LOOP
    IF r.confmatchtype <> 's' THEN RAISE EXCEPTION 'MATCH no contemplado: %',r.conname; END IF;
    SELECT string_agg(format('h.%I IS NOT NULL',a.attname),' AND ' ORDER BY k.ord),
           string_agg(format('p.%I = h.%I',b.attname,a.attname),' AND ' ORDER BY k.ord)
      INTO condicion,union_fk
    FROM unnest(r.conkey,r.confkey) WITH ORDINALITY AS k(h,p,ord)
    JOIN pg_attribute a ON a.attrelid=r.conrelid AND a.attnum=k.h
    JOIN pg_attribute b ON b.attrelid=r.confrelid AND b.attnum=k.p;
    EXECUTE format('SELECT count(*) FROM %s h WHERE %s AND NOT EXISTS (SELECT 1 FROM %s p WHERE %s)',
      r.conrelid::regclass,condicion,r.confrelid::regclass,union_fk) INTO n;
    INSERT INTO auditoria VALUES ('FK',r.conname,n);
  END LOOP;
  -- Incluye PK, UNIQUE simples y compuestas e indices unicos parciales.
  FOR r IN SELECT i.*, ic.relname AS nombre FROM pg_index i
    JOIN pg_class t ON t.oid=i.indrelid
    JOIN pg_namespace s ON s.oid=t.relnamespace
    JOIN pg_class ic ON ic.oid=i.indexrelid
    WHERE s.nspname='public' AND i.indisunique AND i.indisvalid
  LOOP
    IF r.indexprs IS NOT NULL THEN RAISE EXCEPTION 'Indice de expresion no contemplado: %',r.nombre; END IF;
    SELECT string_agg(format('%I',a.attname),', ' ORDER BY k.ord),
           string_agg(format('%I IS NOT NULL',a.attname),' AND ' ORDER BY k.ord)
      INTO columnas,condicion
    FROM unnest(r.indkey::smallint[]) WITH ORDINALITY AS k(attnum,ord)
    JOIN pg_attribute a ON a.attrelid=r.indrelid AND a.attnum=k.attnum
    WHERE k.ord<=r.indnkeyatts;
    filtro:=coalesce(pg_get_expr(r.indpred,r.indrelid),'TRUE');
    IF NOT r.indnullsnotdistinct THEN filtro:='('||filtro||') AND '||condicion; END IF;
    EXECUTE format('SELECT count(*) FROM (SELECT %s FROM %s WHERE %s GROUP BY %s HAVING count(*)>1) d',
      columnas,r.indrelid::regclass,filtro,columnas) INTO n;
    INSERT INTO auditoria VALUES ('UNIQUE/PK',r.nombre,n);
  END LOOP;
  FOR r IN SELECT c.oid AS tabla,a.attname FROM pg_attribute a
    JOIN pg_class c ON c.oid=a.attrelid
    JOIN pg_namespace s ON s.oid=c.relnamespace
    WHERE s.nspname='public' AND c.relkind IN ('r','p') AND a.attnum>0 AND NOT a.attisdropped AND a.attnotnull
  LOOP
    EXECUTE format('SELECT count(*) FROM %s WHERE %I IS NULL',r.tabla::regclass,r.attname) INTO n;
    INSERT INTO auditoria VALUES ('NOT NULL',r.tabla::regclass::text||'.'||r.attname,n);
  END LOOP;
END $$;
\echo === COBERTURA: NUMERO DE COMPROBACIONES POR CLASE ===
SELECT clase,count(*) AS comprobaciones,sum(infracciones) AS infracciones
FROM auditoria GROUP BY clase ORDER BY clase;
\echo === EXCEPCIONES: DEBE DEVOLVER CERO FILAS ===
SELECT * FROM auditoria WHERE infracciones<>0 ORDER BY clase,objeto;
\echo === SIN CAMBIOS PERMANENTES ===
ROLLBACK;
