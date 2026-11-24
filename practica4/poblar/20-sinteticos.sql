-- 20-sinteticos.sql
-- Datos FICTICIOS de demostración: no representan personas, coches ni operaciones reales.
-- Numeraciones reservadas para el ejercicio: 900001 (clientes), 910001 (empleados),
-- 920001 (contratos), 930001 (revisiones), 940001 (refacciones).
-- La ejecución es repetible: se usan identificadores fijos y ON CONFLICT DO NOTHING.
-- Ejecutar después de 10-modelo.sql, dentro de la transacción de poblar.sh.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM modelo) THEN
    RAISE EXCEPTION 'No hay modelos disponibles: cargue primero los datos NHTSA';
  END IF;
END $$;

-- 240 CLIENTES ficticios. Las CURP son identificadores DEMO, no CURP reales verificadas.
INSERT INTO cliente
  (cod_cliente, nombre, ap_paterno, ap_materno, curp, correo, calle, colonia, cp, municipio, cuenta_banco)
SELECT
  900000 + i,
  'Cliente ' || lpad(i::text, 3, '0'),
  'Prueba', 'Sintetico',
  'DEMO' || lpad(i::text, 6, '0') || CASE WHEN i % 2 = 0 THEN 'M' ELSE 'H' END
     || 'PRUEB' || (i % 10)::text || '0',
  'cliente' || lpad(i::text, 3, '0') || '@ejemplo.test',
  'Calle Demostracion ' || i,
  'Colonia Prueba', '55000', 'Ecatepec de Morelos', NULL
FROM generate_series(1, 240) AS g(i)
ON CONFLICT DO NOTHING;

-- 240 TELEFONOS de prueba, con diez dígitos.
INSERT INTO cliente_telefono (cod_cliente, telefono)
SELECT 900000 + i, '55' || lpad(i::text, 8, '0')
FROM generate_series(1, 240) AS g(i)
ON CONFLICT DO NOTHING;

-- 440 EMPLEADOS: 220 mecánicos y 220 administrativos.
INSERT INTO empleado (cod_empleado, nombre, ap_paterno, fecha_ingreso, tipo)
SELECT 910000 + i,
       'Empleado de prueba ' || lpad(i::text, 3, '0'),
       'Sintetico', DATE '2024-01-01' + (i % 180),
       CASE WHEN i <= 220 THEN 'MECANICO' ELSE 'ADMINISTRATIVO' END
FROM generate_series(1, 440) AS g(i)
ON CONFLICT DO NOTHING;

INSERT INTO mecanico (cod_empleado, tipo, especialidad, certificacion)
SELECT 910000 + i, 'MECANICO',
       CASE WHEN i % 2 = 0 THEN 'Suspension' ELSE 'Motor' END,
       NULL
FROM generate_series(1, 220) AS g(i)
ON CONFLICT DO NOTHING;

INSERT INTO administrativo (cod_empleado, tipo, area, turno)
SELECT 910000 + i, 'ADMINISTRATIVO', 'Operaciones',
       CASE WHEN i % 2 = 0 THEN 'MATUTINO' ELSE 'VESPERTINO' END
FROM generate_series(221, 440) AS g(i)
ON CONFLICT DO NOTHING;

-- 240 VEHICULOS. VIN con prefijo TEST: sintéticos, no VIN reales.
-- Se distribuyen entre los modelos existentes, sin suponer IDs SERIAL consecutivos.
WITH m AS (
  SELECT id_modelo, row_number() OVER (ORDER BY id_modelo) AS rn
  FROM modelo
), n AS (SELECT count(*) AS total FROM m)
INSERT INTO vehiculo (vin, color, anio, id_modelo)
SELECT 'TEST' || lpad(g.i::text, 13, '0'),
       CASE g.i % 4 WHEN 0 THEN 'Blanco' WHEN 1 THEN 'Gris'
                    WHEN 2 THEN 'Negro' ELSE 'Azul' END,
       (2018 + (g.i % 7))::smallint, m.id_modelo
FROM generate_series(1, 240) AS g(i)
CROSS JOIN n
JOIN m ON m.rn = 1 + ((g.i - 1) % n.total)
ON CONFLICT DO NOTHING;

-- 240 CONTRATOS, uno por cliente/vehículo. Parte cerrados y parte vigentes.
INSERT INTO contrato
  (id_contrato, cod_cliente, vin, fecha_inicio, pago_semanal, estado, fecha_cierre)
SELECT 920000 + i, 900000 + i, 'TEST' || lpad(i::text, 13, '0'),
       DATE '2025-01-01' + (i % 90),
       (2300 + (i % 5) * 50)::numeric(8,2),
       CASE WHEN i % 5 = 0 THEN 'CERRADO' ELSE 'VIGENTE' END,
       CASE WHEN i % 5 = 0 THEN DATE '2025-01-01' + (i % 90) + 28 ELSE NULL END
FROM generate_series(1, 240) AS g(i)
ON CONFLICT DO NOTHING;

-- 4 PAGOS por contrato: 960 pagos.
INSERT INTO pago_semanal (id_contrato, num_semana, monto, fecha)
SELECT c.id_contrato, s.num_semana, c.pago_semanal,
       c.fecha_inicio + (s.num_semana - 1) * 7
FROM contrato c
CROSS JOIN generate_series(1, 4) AS s(num_semana)
WHERE c.id_contrato BETWEEN 920001 AND 920240
ON CONFLICT DO NOTHING;

-- 240 REVISIONES con mecánicos existentes. La observación acompaña el indicio.
INSERT INTO revision
  (folio, vin, cod_empleado, fecha, calificacion, indicio_reparacion_externa, observaciones)
SELECT 930000 + i, 'TEST' || lpad(i::text, 13, '0'),
       910000 + 1 + ((i - 1) % 220),
       DATE '2025-04-01' + (i % 60),
       (10 + (i % 11))::smallint,
       (i % 13 = 0),
       CASE WHEN i % 13 = 0 THEN 'Indicio detectado en revision ficticia'
            ELSE 'Revision periodica de demostracion' END
FROM generate_series(1, 240) AS g(i)
ON CONFLICT DO NOTHING;

-- 720 INSPECCIONES: 3 por cada revisión.
INSERT INTO inspeccion (folio, tipo, resultado, detalle)
SELECT 930000 + g.i, t.tipo,
       (10 + (g.i % 11))::smallint, 'Evaluacion sintetica'
FROM generate_series(1, 240) AS g(i)
CROSS JOIN (VALUES ('VISUAL'), ('MECANICA'), ('FUERZA')) AS t(tipo)
ON CONFLICT DO NOTHING;

-- 240 REFACCIONES con nombres únicos.
INSERT INTO refaccion (cod_refaccion, nombre, costo)
SELECT 940000 + i, 'Refaccion de prueba ' || lpad(i::text, 3, '0'),
       (120 + (i % 30) * 15)::numeric(8,2)
FROM generate_series(1, 240) AS g(i)
ON CONFLICT DO NOTHING;

-- 240 REPARACIONES; cada una referencia mecánico, vehículo y refacción.
INSERT INTO reparacion (cod_empleado, vin, cod_refaccion, fecha, cantidad, costo)
SELECT 910000 + 1 + ((i - 1) % 220),
       'TEST' || lpad(i::text, 13, '0'),
       940000 + i,
       DATE '2025-05-01' + (i % 60),
       (1 + (i % 3))::smallint,
       (120 + (i % 30) * 15) * (1 + (i % 3))
FROM generate_series(1, 240) AS g(i)
ON CONFLICT DO NOTHING;
