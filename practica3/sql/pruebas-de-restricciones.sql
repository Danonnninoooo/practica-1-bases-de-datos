-- Datos válidos mínimos
INSERT INTO modelo (marca, nombre, litros_motor) VALUES ('Nissan', 'March', 1.6);
INSERT INTO vehiculo (vin, color, anio, id_modelo) VALUES ('3N1CK3CD5ZL000001', 'Blanco', 2022, 1);
INSERT INTO cliente (nombre, ap_paterno, curp, correo, calle, colonia, cp, municipio)
VALUES ('Juan', 'Perez', 'PEXJ900101HDFRRN01', 'juan@mail.com', 'Reforma 1', 'Centro', '55000', 'Ecatepec');
INSERT INTO contrato (cod_cliente, vin, pago_semanal) VALUES (1, '3N1CK3CD5ZL000001', 2300);

-- PRUEBA 1: viola UNIQUE parcial (un vehículo no puede tener 2 contratos VIGENTES)
INSERT INTO cliente (nombre, ap_paterno, curp, correo, calle, colonia, cp, municipio)
VALUES ('Ana', 'Lopez', 'LOXA950202MDFPNN02', 'ana@mail.com', 'Hidalgo 5', 'Centro', '55000', 'Ecatepec');
INSERT INTO contrato (cod_cliente, vin, pago_semanal) VALUES (2, '3N1CK3CD5ZL000001', 2300);

-- PRUEBA 2: viola CHECK (calificación debe estar entre 1 y 20)
INSERT INTO empleado (nombre, ap_paterno, tipo) VALUES ('Luis', 'Ramos', 'MECANICO');
INSERT INTO mecanico (cod_empleado, especialidad) VALUES (1, 'Suspension');
INSERT INTO revision (vin, cod_empleado, calificacion) VALUES ('3N1CK3CD5ZL000001', 1, 25);

-- PRUEBA 3: viola FOREIGN KEY (el VIN no existe)
INSERT INTO contrato (cod_cliente, vin, pago_semanal) VALUES (2, 'VINNOEXISTE000000', 2300);