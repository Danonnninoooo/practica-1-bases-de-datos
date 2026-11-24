# Dominios y tipos de datos — renta semanal de vehículos

**Base:** `practica3/sql/esquema.sql`, modificada por `practica4/migraciones/001-dominios.sql` y `practica4/migraciones/002-motores-mx.sql` (PostgreSQL 16).

Un **dominio** delimita los valores admitidos por un atributo. `NOT NULL`, `UNIQUE`, `CHECK`, llaves primarias y foráneas preservan reglas del negocio. La tabla siguiente refleja los tipos después de las migraciones 001 y 002; `SERIAL` representa un entero autogenerado mediante secuencia.

| Tabla | Columna(s) | Tipo, tamaño o precisión | Justificación |
|---|---|---|---|
| cliente | cod_cliente | SERIAL / INTEGER | Identificador interno de cliente. |
| cliente | nombre, ap_paterno, ap_materno | VARCHAR(60), VARCHAR(40), VARCHAR(40) | Longitudes variables; el segundo apellido puede faltar. |
| cliente | curp | CHAR(18) | Identificación de longitud fija; UNIQUE y CHECK de formato. |
| cliente | correo | VARCHAR(100) | Contacto electrónico; UNIQUE y CHECK de formato básico. |
| cliente | calle, colonia, cp, municipio | VARCHAR(80), VARCHAR(60), CHAR(5), VARCHAR(60) | Dirección; CP como texto conserva ceros iniciales. |
| cliente | cuenta_banco | VARCHAR(20) | CLABE opcional; CHECK exige 18 dígitos si existe. |
| cliente_telefono | cod_cliente, telefono | INTEGER, d_telefono_mx | Identifica al cliente y valida teléfono nacional de 10 dígitos. |
| modelo | id_modelo, marca, nombre | SERIAL, VARCHAR(30), VARCHAR(30) | Identificador y denominaciones de vehículo. |
| modelo | litros_motor | NUMERIC(2,1) | Cilindrada con una cifra decimal; CHECK entre 0.6 y 7.0; NULL si no se confirmó. |
| vehiculo | vin, color, anio, id_modelo | CHAR(17), VARCHAR(20), SMALLINT, INTEGER | VIN fijo y único; color, año y referencia a modelo. |
| empleado | cod_empleado, nombre, ap_paterno | SERIAL, VARCHAR(60), VARCHAR(40) | Identificador y nombre del trabajador. |
| empleado | fecha_ingreso, tipo | DATE, VARCHAR(15) | Fecha de alta y discriminador MECANICO/ADMINISTRATIVO. |
| mecanico | cod_empleado, tipo, especialidad, certificacion | INTEGER, VARCHAR(15), VARCHAR(40), VARCHAR(60) | Subtipo de empleado; certificación opcional. |
| administrativo | cod_empleado, tipo, area, turno | INTEGER, VARCHAR(15), VARCHAR(40), VARCHAR(10) | Subtipo y turno MATUTINO/VESPERTINO. |
| contrato | id_contrato, cod_cliente, vin | SERIAL, INTEGER, CHAR(17) | Contrato ligado a cliente y vehículo existentes. |
| contrato | fecha_inicio, pago_semanal | DATE, d_monto | Inicio y pago monetario exacto y positivo. |
| contrato | estado, fecha_cierre | VARCHAR(10), DATE | Vigencia/cierre; fecha de cierre solo para CERRADO. |
| pago_semanal | id_contrato, num_semana | INTEGER, SMALLINT | Identificación compuesta del pago dentro de un contrato. |
| pago_semanal | monto, fecha | d_monto, DATE | Cobro positivo y fecha del pago. |
| revision | folio, vin, cod_empleado, fecha | SERIAL, CHAR(17), INTEGER, DATE | Revisión ligada a vehículo y mecánico; única por VIN y fecha. |
| revision | calificacion | d_calificacion | Condición del vehículo de 1 a 20. |
| revision | indicio_reparacion_externa, observaciones | BOOLEAN, TEXT | Indicio verdadero/falso y explicación libre. |
| inspeccion | folio, tipo | INTEGER, VARCHAR(10) | Inspección dependiente de revisión; tipo VISUAL/MECANICA/FUERZA. |
| inspeccion | resultado, detalle | d_calificacion, TEXT | Calificación de 1 a 20 y observaciones. |
| refaccion | cod_refaccion, nombre, costo | SERIAL, VARCHAR(60), NUMERIC(8,2) | Pieza identificada por código; nombre único y costo no negativo. |
| reparacion | cod_empleado, vin, cod_refaccion, fecha | INTEGER, CHAR(17), INTEGER, DATE | Clave compuesta de reparación: mecánico, vehículo, pieza y día. |
| reparacion | cantidad, costo | SMALLINT, NUMERIC(8,2) | Cantidad positiva y costo no negativo. |

## Dominios reutilizables (CREATE DOMAIN)

| Dominio | Tipo base | Condición | Columnas |
|---|---|---|---|
| `d_calificacion` | SMALLINT | 1 a 20 | `revision.calificacion`, `inspeccion.resultado` |
| `d_monto` | NUMERIC(8,2) | Mayor que 0 | `contrato.pago_semanal`, `pago_semanal.monto` |
| `d_telefono_mx` | VARCHAR(15) | Expresión regular de 10 dígitos | `cliente_telefono.telefono` |

**Ventajas:** la misma restricción es reutilizable y consistente en varias columnas. Los montos usan `NUMERIC` en vez de `REAL`/`DOUBLE PRECISION` para representar centavos de modo exacto. Las fechas usan `DATE`, no cadenas.

## Restricciones de negocio destacadas

- CURP única y con formato básico, correo único y con formato básico, teléfono nacional de diez dígitos.
- VIN de 17 caracteres sin I, O ni Q, año del vehículo entre 2000 y 2100.
- Un contrato `VIGENTE` por cliente y uno por vehículo (índices únicos parciales).
- `CERRADO` implica fecha de cierre y `VIGENTE` no admite esa fecha; cierre no anterior al inicio.
- Cada vehículo tiene a lo sumo una revisión por fecha; toda revisión referencia un mecánico.
- Las inspecciones pertenecen a una revisión; las reparaciones referencian mecánico, vehículo y refacción.
- Si existe indicio de reparación externa, `observaciones` no puede ser nulo.

## Observaciones por verificar

1. Los `CHECK` de una columna permiten `NULL` salvo que también exista `NOT NULL`; los dominios tampoco añaden `NOT NULL` automáticamente.
2. La jerarquía `empleado`–`mecanico`/`administrativo` impide que un subtipo tenga el discriminador incorrecto, pero **no garantiza por sí sola** que todo empleado tenga exactamente una fila en alguno de los subtipos (totalidad).
3. `ck_revision_externa` exige observaciones no nulas pero permite texto vacío; si se quiere impedir esto, debe añadirse otra migración justificada.
4. La validación de CURP comprueba patrón, no autenticidad oficial. La de correo es simplificada.
5. `NUMERIC(2,1)` admite hasta 9.9, pero el `CHECK` limita la cilindrada a 7.0. La migración 002 permite NULL y mantiene la unicidad de (marca, nombre, litros_motor) con UNIQUE NULLS NOT DISTINCT; consultar [motores-mx.md](motores-mx.md).

La migración 001 reportada anteriormente como ejecutada debe comprobarse también al reconstruir la base limpia. Este documento no sustituye las pruebas exigidas en `pruebas-dominio.md`.
