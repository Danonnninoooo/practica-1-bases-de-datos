-- 001-dominios.sql | Restricciones de dominio | PostgreSQL 16
BEGIN;

-- DOMINIOS reutilizables (se repiten en varias tablas)
-- Regla: toda calificación del vehículo va de 1 a 20.
CREATE DOMAIN d_calificacion AS SMALLINT
  CONSTRAINT ck_d_calificacion CHECK (VALUE BETWEEN 1 AND 20);
-- Regla: ningún pago ni monto de renta puede ser cero o negativo.
CREATE DOMAIN d_monto AS NUMERIC(8,2)
  CONSTRAINT ck_d_monto CHECK (VALUE > 0);
-- Regla: un teléfono es de 10 dígitos (México).
CREATE DOMAIN d_telefono_mx AS VARCHAR(15)
  CONSTRAINT ck_d_telefono CHECK (VALUE ~ '^[0-9]{10}$');

-- Calificaciones: la vista depende de la columna, así que se recrea.
DROP VIEW v_vehiculo_condicion;
ALTER TABLE revision   DROP CONSTRAINT ck_revision_calif;
ALTER TABLE inspeccion DROP CONSTRAINT ck_inspeccion_res;
ALTER TABLE revision   ALTER COLUMN calificacion TYPE d_calificacion;
ALTER TABLE inspeccion ALTER COLUMN resultado    TYPE d_calificacion;
CREATE VIEW v_vehiculo_condicion AS
SELECT v.vin,
       (SELECT r.calificacion FROM revision r
         WHERE r.vin = v.vin ORDER BY r.fecha DESC LIMIT 1) AS condicion_actual
FROM vehiculo v;

-- Montos
ALTER TABLE contrato     DROP CONSTRAINT ck_contrato_pago;
ALTER TABLE pago_semanal DROP CONSTRAINT ck_pago_monto;
ALTER TABLE contrato     ALTER COLUMN pago_semanal TYPE d_monto;
ALTER TABLE pago_semanal ALTER COLUMN monto        TYPE d_monto;

-- Teléfono
ALTER TABLE cliente_telefono ALTER COLUMN telefono TYPE d_telefono_mx;

-- CLIENTE
ALTER TABLE cliente
  -- Regla: la CURP tiene 18 caracteres con el formato oficial.
  ADD CONSTRAINT ck_cliente_curp CHECK (curp ~ '^[A-Z]{4}[0-9]{6}[HM][A-Z]{5}[A-Z0-9][0-9]$'),
  -- Regla: un correo tiene arroba y dominio.
  ADD CONSTRAINT ck_cliente_correo CHECK (correo ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
  -- Regla: la cuenta de cobro es una CLABE de 18 dígitos (si se registra).
  ADD CONSTRAINT ck_cliente_cuenta CHECK (cuenta_banco IS NULL OR cuenta_banco ~ '^[0-9]{18}$');

-- VEHICULO
ALTER TABLE vehiculo
  -- Regla: el VIN tiene 17 caracteres y no usa las letras I, O ni Q.
  ADD CONSTRAINT ck_vehiculo_vin CHECK (vin ~ '^[A-HJ-NPR-Z0-9]{17}$'),
  -- Regla: el color no puede ir vacío.
  ADD CONSTRAINT ck_vehiculo_color CHECK (length(trim(color)) > 0);

-- MODELO
ALTER TABLE modelo DROP CONSTRAINT ck_modelo_litros;
-- Regla: un motor de auto compacto va de 0.6 a 6.0 litros.
ALTER TABLE modelo ADD CONSTRAINT ck_modelo_litros CHECK (litros_motor BETWEEN 0.6 AND 6.0);

-- REFACCION
-- Regla: no hay dos refacciones con el mismo nombre.
ALTER TABLE refaccion ADD CONSTRAINT uq_refaccion_nombre UNIQUE (nombre);

-- CONTRATO: fecha de cierre (CHECK entre columnas)
ALTER TABLE contrato ADD COLUMN fecha_cierre DATE;
ALTER TABLE contrato
  -- Regla: un contrato no se cierra antes de empezar.
  ADD CONSTRAINT ck_contrato_fechas CHECK (fecha_cierre IS NULL OR fecha_cierre >= fecha_inicio),
  -- Regla: un contrato CERRADO tiene fecha de cierre, y uno VIGENTE no.
  ADD CONSTRAINT ck_contrato_cierre CHECK ((estado = 'CERRADO') = (fecha_cierre IS NOT NULL));

-- REVISION (CHECK entre columnas)
-- Regla: si se sospecha una reparación externa, debe quedar documentada.
ALTER TABLE revision
  ADD CONSTRAINT ck_revision_externa CHECK (NOT indicio_reparacion_externa OR observaciones IS NOT NULL);

COMMIT;