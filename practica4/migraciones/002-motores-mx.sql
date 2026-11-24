-- Permite cilindradas documentadas mayores a 6.0 y desconocidas.
-- Ejecutar como administrador antes de poblar.sh.
BEGIN;
ALTER TABLE modelo DROP CONSTRAINT IF EXISTS ck_modelo_litros;
ALTER TABLE modelo ALTER COLUMN litros_motor DROP NOT NULL;
ALTER TABLE modelo ADD CONSTRAINT ck_modelo_litros CHECK (litros_motor BETWEEN 0.6 AND 7.0);
ALTER TABLE modelo DROP CONSTRAINT IF EXISTS uq_modelo;
ALTER TABLE modelo ADD CONSTRAINT uq_modelo UNIQUE NULLS NOT DISTINCT (marca,nombre,litros_motor);
COMMIT;
