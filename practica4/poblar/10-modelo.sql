-- 10-modelo.sql | Cruce NHTSA con cilindradas documentadas de México
-- Ejecutar después de 08-motores-mx.sql y de la migración 002.
CREATE TEMP TABLE vpic AS
SELECT initcap(trim(r->>'Make_Name')) AS marca, trim(r->>'Model_Name') AS nombre
FROM crudo_vpic c, jsonb_array_elements(c.linea::jsonb -> 'Results') AS r;

CREATE TEMP TABLE candidatos AS
SELECT DISTINCT v.marca, v.nombre, m.litros_motor
FROM vpic v
JOIN motores_mx m ON upper(v.marca)=upper(m.marca) AND upper(v.nombre)=upper(m.nombre);

-- El catálogo académico elige una versión por nombre. Si aparecen variantes
-- adicionales, se detiene la carga para no sobrescribir datos ambiguos.
DO $$
BEGIN
  IF (SELECT count(*) FROM candidatos) <> 73 THEN
    RAISE EXCEPTION 'Se esperaban 73 modelos de referencia; revisar fuentes';
  END IF;
  IF EXISTS (
    SELECT upper(m.marca), upper(m.nombre) FROM modelo m
    JOIN candidatos c ON upper(m.marca)=upper(c.marca) AND upper(m.nombre)=upper(c.nombre)
    GROUP BY upper(m.marca), upper(m.nombre) HAVING count(*) > 1
  ) THEN
    RAISE EXCEPTION 'Existen variantes múltiples; revisar antes de corregir cilindradas';
  END IF;
END $$;

-- Corrección en sitio: conserva id_modelo y todas las llaves foráneas.
WITH cambios AS (
 UPDATE modelo m SET litros_motor=c.litros_motor
 FROM candidatos c
 WHERE upper(m.marca)=upper(c.marca) AND upper(m.nombre)=upper(c.nombre)
   AND m.litros_motor IS DISTINCT FROM c.litros_motor
 RETURNING m.id_modelo
)
SELECT count(*) AS cilindradas_actualizadas FROM cambios;

WITH ins AS (
 INSERT INTO modelo(marca,nombre,litros_motor)
 SELECT c.marca,c.nombre,c.litros_motor FROM candidatos c
 WHERE NOT EXISTS (SELECT 1 FROM modelo m WHERE upper(m.marca)=upper(c.marca) AND upper(m.nombre)=upper(c.nombre))
 ORDER BY c.marca,c.nombre
 ON CONFLICT (marca,nombre,litros_motor) DO NOTHING
 RETURNING 1
)
SELECT 'modelo' AS tabla, (SELECT count(*) FROM vpic) AS leidos,
 (SELECT count(*) FROM vpic)-(SELECT count(*) FROM candidatos) AS descartados_por_filtro,
 (SELECT count(*) FROM ins) AS insertados,
 (SELECT count(*) FROM candidatos)-(SELECT count(*) FROM ins) AS ya_existian;

SELECT count(*) AS modelos, count(litros_motor) AS cilindradas_documentadas,
 count(*)-count(litros_motor) AS sin_confirmar FROM candidatos;

SELECT marca, count(*) AS aceptados, string_agg(nombre, ', ' ORDER BY nombre) AS modelos
FROM candidatos GROUP BY marca ORDER BY marca;
