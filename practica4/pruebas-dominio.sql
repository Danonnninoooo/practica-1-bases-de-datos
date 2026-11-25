-- Práctica 4, ejercicio 1.5: pruebas de restricciones de dominio.
-- Requiere la carga sintética previa (IDs 900001, 910221, 920001, etc.).
-- Ejecutar como postgres; los errores de integridad se comprueban y capturan.
-- TODAS las operaciones se envuelven en una transacción que termina en ROLLBACK:
-- ningún cambio de esta batería de pruebas queda guardado.
\pset pager off
\echo === INICIO PRUEBAS DE DOMINIO (NINGUN CAMBIO PERMANENTE) ===
BEGIN;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM cliente WHERE cod_cliente = 900001)
     OR NOT EXISTS (SELECT 1 FROM contrato WHERE id_contrato = 920001)
     OR NOT EXISTS (SELECT 1 FROM revision WHERE folio = 930013)
  THEN
    RAISE EXCEPTION 'Faltan los datos sintéticos. Ejecute primero practica4/poblar/poblar.sh';
  END IF;
END;
$$;

-- Ejecuta una instrucción y EXIGE que el motor la rechace con el SQLSTATE esperado.
-- El bloque EXCEPTION funciona como subtransacción: revierte el intento fallido.
CREATE FUNCTION pg_temp.esperar_rechazo(
  caso TEXT,
  sentencia TEXT,
  codigo_esperado TEXT
) RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
  codigo_obtenido TEXT;
  texto_error TEXT;
  restriccion TEXT;
BEGIN
  BEGIN
    EXECUTE sentencia;
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS
      codigo_obtenido = RETURNED_SQLSTATE,
      texto_error = MESSAGE_TEXT,
      restriccion = CONSTRAINT_NAME;
    IF codigo_obtenido <> codigo_esperado THEN
      RAISE EXCEPTION '%: error inesperado SQLSTATE %, esperado %. Mensaje: %',
        caso, codigo_obtenido, codigo_esperado, texto_error;
    END IF;
    RAISE NOTICE 'CORRECTO: % | SQLSTATE=% | CONSTRAINT=% | MENSAJE=%',
      caso, codigo_obtenido, NULLIF(restriccion,''), texto_error;
    RETURN;
  END;
  RAISE EXCEPTION 'FALLO: %: PostgreSQL aceptó la operación que debía rechazar', caso;
END;
$$;

-- 1. NOT NULL: nombre obligatorio
SELECT pg_temp.esperar_rechazo(
  '01 NOT NULL cliente.nombre',
  'UPDATE cliente SET nombre = NULL WHERE cod_cliente = 900001',
  '23502'
);

-- 2. UNIQUE simple: no duplicar correo
SELECT pg_temp.esperar_rechazo(
  '02 UNIQUE cliente.correo',
  'UPDATE cliente SET correo = ''cliente002@ejemplo.test'' WHERE cod_cliente = 900001',
  '23505'
);

-- 3. UNIQUE compuesta: (cod_cliente, telefono)
SELECT pg_temp.esperar_rechazo(
  '03 UNIQUE compuesto cliente_telefono',
  'INSERT INTO cliente_telefono (cod_cliente, telefono) SELECT cod_cliente, telefono FROM cliente_telefono WHERE cod_cliente = 900001',
  '23505'
);

-- 4. CHECK de rango: año debe estar entre 2000 y 2100
SELECT pg_temp.esperar_rechazo(
  '04 CHECK rango vehiculo.anio',
  'UPDATE vehiculo SET anio = 1999 WHERE vin = ''TEST0000000000001''',
  '23514'
);

-- 5. CHECK de formato: CP de 5 dígitos
SELECT pg_temp.esperar_rechazo(
  '05 CHECK formato cliente.cp',
  'UPDATE cliente SET cp = ''ABCDE'' WHERE cod_cliente = 900001',
  '23514'
);

-- 6. CHECK de lista: turno administrativo permitido
SELECT pg_temp.esperar_rechazo(
  '06 CHECK lista administrativo.turno',
  'UPDATE administrativo SET turno = ''NOCHE'' WHERE cod_empleado = 910221',
  '23514'
);

-- 7. CHECK entre columnas: cierre no anterior al inicio (contrato cerrado)
SELECT pg_temp.esperar_rechazo(
  '07 CHECK entre columnas contrato.fechas',
  'UPDATE contrato SET fecha_cierre = DATE ''2023-01-01'' WHERE id_contrato = 920005',
  '23514'
);

-- 8. CHECK entre columnas: CERRADO requiere fecha_cierre
SELECT pg_temp.esperar_rechazo(
  '08 CHECK contrato.estado y fecha_cierre',
  'UPDATE contrato SET estado = ''CERRADO'' WHERE id_contrato = 920001',
  '23514'
);

-- 9. CREATE DOMAIN: calificación de 1 a 20
SELECT pg_temp.esperar_rechazo(
  '09 DOMAIN d_calificacion',
  'UPDATE revision SET calificacion = 21 WHERE folio = 930001',
  '23514'
);

-- 10. CHECK entre columnas: si hay indicio externo, exige observaciones
SELECT pg_temp.esperar_rechazo(
  '10 CHECK revision.indicio_reparacion_externa',
  'UPDATE revision SET observaciones = NULL WHERE folio = 930013',
  '23514'
);

-- Adicional: integridad referencial, FK de contrato hacia cliente
SELECT pg_temp.esperar_rechazo(
  '11 FK contrato.cod_cliente',
  'UPDATE contrato SET cod_cliente = 999999999 WHERE id_contrato = 920001',
  '23503'
);

-- Prueba de DEFAULT: omitir fecha_ingreso debe almacenar CURRENT_DATE.
-- Este INSERT queda revertido con el ROLLBACK final.
DO $$
DECLARE fecha DATE;
BEGIN
  INSERT INTO empleado (cod_empleado, nombre, ap_paterno, tipo)
  VALUES (990001, 'Empleado prueba DEFAULT', 'Sintetico', 'MECANICO')
  RETURNING fecha_ingreso INTO fecha;
  IF fecha IS DISTINCT FROM CURRENT_DATE THEN
    RAISE EXCEPTION 'DEFAULT fecha_ingreso inesperado: %', fecha;
  END IF;
  RAISE NOTICE 'CORRECTO: 12 DEFAULT empleado.fecha_ingreso = %', fecha;
END;
$$;

ROLLBACK;
\echo === FIN: 11 RECHAZOS ESPERADOS + 1 DEFAULT EXITOSO; CAMBIOS REVERTIDOS ===
