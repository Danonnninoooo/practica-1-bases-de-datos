# Diccionario de datos - Renta semanal de vehículos (PostgreSQL 16)

| Tabla | Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|---|
| cliente | cod_cliente | SERIAL | PK | Identificador del cliente |
| cliente | nombre | VARCHAR(60) | NOT NULL | Nombre(s) (componente del atributo compuesto nombre) |
| cliente | ap_paterno | VARCHAR(40) | NOT NULL | Apellido paterno |
| cliente | ap_materno | VARCHAR(40) | NULL | Apellido materno |
| cliente | curp | CHAR(18) | NOT NULL, UNIQUE | CURP del cliente |
| cliente | correo | VARCHAR(100) | NOT NULL, UNIQUE | Correo electrónico |
| cliente | calle | VARCHAR(80) | NOT NULL | Calle y número (dirección compuesta) |
| cliente | colonia | VARCHAR(60) | NOT NULL | Colonia |
| cliente | cp | CHAR(5) | NOT NULL, CHECK 5 dígitos | Código postal |
| cliente | municipio | VARCHAR(60) | NOT NULL | Municipio |
| cliente | cuenta_banco | VARCHAR(20) | NULL | Cuenta de la que se cobra la semana |
| cliente_telefono | cod_cliente | INT | PK, FK cliente, ON DELETE CASCADE | Cliente dueño del teléfono |
| cliente_telefono | telefono | VARCHAR(15) | PK | Teléfono (atributo multivaluado) |
| modelo | id_modelo | SERIAL | PK | Identificador del modelo |
| modelo | marca | VARCHAR(30) | NOT NULL, UNIQUE(marca,nombre,litros_motor) | Marca |
| modelo | nombre | VARCHAR(30) | NOT NULL | Nombre del modelo (March, Versa) |
| modelo | litros_motor | NUMERIC(2,1) | NOT NULL, CHECK > 0 | Capacidad del motor en litros |
| vehiculo | vin | CHAR(17) | PK | Número de identificación vehicular |
| vehiculo | color | VARCHAR(20) | NOT NULL | Color |
| vehiculo | anio | SMALLINT | NOT NULL, CHECK 2000-2100 | Año del vehículo |
| vehiculo | id_modelo | INT | NOT NULL, FK modelo, ON DELETE RESTRICT | Modelo al que pertenece |
| empleado | cod_empleado | SERIAL | PK | Identificador del empleado |
| empleado | nombre | VARCHAR(60) | NOT NULL | Nombre |
| empleado | ap_paterno | VARCHAR(40) | NOT NULL | Apellido paterno |
| empleado | fecha_ingreso | DATE | NOT NULL, DEFAULT hoy | Fecha de ingreso |
| empleado | tipo | VARCHAR(15) | NOT NULL, CHECK (MECANICO/ADMINISTRATIVO), UNIQUE(cod_empleado,tipo) | Discriminador de la jerarquía (disyunción) |
| mecanico | cod_empleado | INT | PK, FK empleado(cod_empleado,tipo), ON DELETE CASCADE | Subtipo mecánico |
| mecanico | tipo | VARCHAR(15) | NOT NULL, CHECK = 'MECANICO' | Fuerza el tipo correcto |
| mecanico | especialidad | VARCHAR(40) | NOT NULL | Especialidad |
| mecanico | certificacion | VARCHAR(60) | NULL | Certificación |
| administrativo | cod_empleado | INT | PK, FK empleado(cod_empleado,tipo), ON DELETE CASCADE | Subtipo administrativo |
| administrativo | tipo | VARCHAR(15) | NOT NULL, CHECK = 'ADMINISTRATIVO' | Fuerza el tipo correcto |
| administrativo | area | VARCHAR(40) | NOT NULL | Área |
| administrativo | turno | VARCHAR(10) | NOT NULL, CHECK (MATUTINO/VESPERTINO) | Turno |
| contrato | id_contrato | SERIAL | PK | Identificador del contrato |
| contrato | cod_cliente | INT | NOT NULL, FK cliente, ON DELETE RESTRICT | Cliente que renta |
| contrato | vin | CHAR(17) | NOT NULL, FK vehiculo, ON DELETE RESTRICT | Vehículo rentado |
| contrato | fecha_inicio | DATE | NOT NULL, DEFAULT hoy | Inicio de la renta |
| contrato | pago_semanal | NUMERIC(8,2) | NOT NULL, CHECK > 0 | Pago semanal acordado |
| contrato | estado | VARCHAR(10) | NOT NULL, DEFAULT 'VIGENTE', CHECK (VIGENTE/CERRADO) | Estado; índice único parcial: un VIGENTE por cliente y por vehículo |
| pago_semanal | id_contrato | INT | PK, FK contrato, ON DELETE CASCADE | Contrato propietario (entidad débil) |
| pago_semanal | num_semana | SMALLINT | PK, CHECK > 0 | Discriminador: número de semana |
| pago_semanal | monto | NUMERIC(8,2) | NOT NULL, CHECK > 0 | Monto pagado |
| pago_semanal | fecha | DATE | NOT NULL | Fecha del pago |
| revision | folio | SERIAL | PK | Folio de la revisión |
| revision | vin | CHAR(17) | NOT NULL, FK vehiculo, UNIQUE(vin,fecha) | Vehículo revisado |
| revision | cod_empleado | INT | NOT NULL, FK mecanico, ON DELETE RESTRICT | Mecánico que la realiza |
| revision | fecha | DATE | NOT NULL, DEFAULT hoy | Fecha |
| revision | calificacion | SMALLINT | NOT NULL, CHECK 1-20 | Calificación general |
| revision | indicio_reparacion_externa | BOOLEAN | NOT NULL, DEFAULT FALSE | Sospecha de reparación fuera de la empresa |
| revision | observaciones | TEXT | NULL | Notas |
| inspeccion | folio | INT | PK, FK revision, ON DELETE CASCADE | Revisión propietaria (entidad débil) |
| inspeccion | tipo | VARCHAR(10) | PK, CHECK (VISUAL/MECANICA/FUERZA) | Discriminador del tipo de inspección |
| inspeccion | resultado | SMALLINT | NOT NULL, CHECK 1-20 | Resultado |
| inspeccion | detalle | TEXT | NULL | Detalle |
| refaccion | cod_refaccion | SERIAL | PK | Identificador de la refacción |
| refaccion | nombre | VARCHAR(60) | NOT NULL | Nombre |
| refaccion | costo | NUMERIC(8,2) | NOT NULL, CHECK >= 0 | Costo unitario |
| reparacion | cod_empleado | INT | PK, FK mecanico | Mecánico (ternaria) |
| reparacion | vin | CHAR(17) | PK, FK vehiculo | Vehículo (ternaria) |
| reparacion | cod_refaccion | INT | PK, FK refaccion | Refacción (ternaria) |
| reparacion | fecha | DATE | PK | Fecha de la reparación |
| reparacion | cantidad | SMALLINT | NOT NULL, DEFAULT 1, CHECK > 0 | Piezas usadas |
| reparacion | costo | NUMERIC(8,2) | NOT NULL, CHECK >= 0 | Costo total |

# Diccionario de datos - Renta semanal de vehículos (PostgreSQL 16)

| Tabla | Columna | Tipo | Restricciones | Descripción |
|---|---|---|---|---|
| cliente | cod_cliente | SERIAL | PK | Identificador del cliente |
| cliente | nombre | VARCHAR(60) | NOT NULL | Nombre(s) (componente del atributo compuesto nombre) |
| cliente | ap_paterno | VARCHAR(40) | NOT NULL | Apellido paterno |
| cliente | ap_materno | VARCHAR(40) | NULL | Apellido materno |
| cliente | curp | CHAR(18) | NOT NULL, UNIQUE | CURP del cliente |
| cliente | correo | VARCHAR(100) | NOT NULL, UNIQUE | Correo electrónico |
| cliente | calle | VARCHAR(80) | NOT NULL | Calle y número (dirección compuesta) |
| cliente | colonia | VARCHAR(60) | NOT NULL | Colonia |
| cliente | cp | CHAR(5) | NOT NULL, CHECK 5 dígitos | Código postal |
| cliente | municipio | VARCHAR(60) | NOT NULL | Municipio |
| cliente | cuenta_banco | VARCHAR(20) | NULL | Cuenta de la que se cobra la semana |
| cliente_telefono | cod_cliente | INT | PK, FK cliente, ON DELETE CASCADE | Cliente dueño del teléfono |
| cliente_telefono | telefono | VARCHAR(15) | PK | Teléfono (atributo multivaluado) |
| modelo | id_modelo | SERIAL | PK | Identificador del modelo |
| modelo | marca | VARCHAR(30) | NOT NULL, UNIQUE(marca,nombre,litros_motor) | Marca |
| modelo | nombre | VARCHAR(30) | NOT NULL | Nombre del modelo (March, Versa) |
| modelo | litros_motor | NUMERIC(2,1) | NOT NULL, CHECK > 0 | Capacidad del motor en litros |
| vehiculo | vin | CHAR(17) | PK | Número de identificación vehicular |
| vehiculo | color | VARCHAR(20) | NOT NULL | Color |
| vehiculo | anio | SMALLINT | NOT NULL, CHECK 2000-2100 | Año del vehículo |
| vehiculo | id_modelo | INT | NOT NULL, FK modelo, ON DELETE RESTRICT | Modelo al que pertenece |
| empleado | cod_empleado | SERIAL | PK | Identificador del empleado |
| empleado | nombre | VARCHAR(60) | NOT NULL | Nombre |
| empleado | ap_paterno | VARCHAR(40) | NOT NULL | Apellido paterno |
| empleado | fecha_ingreso | DATE | NOT NULL, DEFAULT hoy | Fecha de ingreso |
| empleado | tipo | VARCHAR(15) | NOT NULL, CHECK (MECANICO/ADMINISTRATIVO), UNIQUE(cod_empleado,tipo) | Discriminador de la jerarquía (disyunción) |
| mecanico | cod_empleado | INT | PK, FK empleado(cod_empleado,tipo), ON DELETE CASCADE | Subtipo mecánico |
| mecanico | tipo | VARCHAR(15) | NOT NULL, CHECK = 'MECANICO' | Fuerza el tipo correcto |
| mecanico | especialidad | VARCHAR(40) | NOT NULL | Especialidad |
| mecanico | certificacion | VARCHAR(60) | NULL | Certificación |
| administrativo | cod_empleado | INT | PK, FK empleado(cod_empleado,tipo), ON DELETE CASCADE | Subtipo administrativo |
| administrativo | tipo | VARCHAR(15) | NOT NULL, CHECK = 'ADMINISTRATIVO' | Fuerza el tipo correcto |
| administrativo | area | VARCHAR(40) | NOT NULL | Área |
| administrativo | turno | VARCHAR(10) | NOT NULL, CHECK (MATUTINO/VESPERTINO) | Turno |
| contrato | id_contrato | SERIAL | PK | Identificador del contrato |
| contrato | cod_cliente | INT | NOT NULL, FK cliente, ON DELETE RESTRICT | Cliente que renta |
| contrato | vin | CHAR(17) | NOT NULL, FK vehiculo, ON DELETE RESTRICT | Vehículo rentado |
| contrato | fecha_inicio | DATE | NOT NULL, DEFAULT hoy | Inicio de la renta |
| contrato | pago_semanal | NUMERIC(8,2) | NOT NULL, CHECK > 0 | Pago semanal acordado |
| contrato | estado | VARCHAR(10) | NOT NULL, DEFAULT 'VIGENTE', CHECK (VIGENTE/CERRADO) | Estado; índice único parcial: un VIGENTE por cliente y por vehículo |
| pago_semanal | id_contrato | INT | PK, FK contrato, ON DELETE CASCADE | Contrato propietario (entidad débil) |
| pago_semanal | num_semana | SMALLINT | PK, CHECK > 0 | Discriminador: número de semana |
| pago_semanal | monto | NUMERIC(8,2) | NOT NULL, CHECK > 0 | Monto pagado |
| pago_semanal | fecha | DATE | NOT NULL | Fecha del pago |
| revision | folio | SERIAL | PK | Folio de la revisión |
| revision | vin | CHAR(17) | NOT NULL, FK vehiculo, UNIQUE(vin,fecha) | Vehículo revisado |
| revision | cod_empleado | INT | NOT NULL, FK mecanico, ON DELETE RESTRICT | Mecánico que la realiza |
| revision | fecha | DATE | NOT NULL, DEFAULT hoy | Fecha |
| revision | calificacion | SMALLINT | NOT NULL, CHECK 1-20 | Calificación general |
| revision | indicio_reparacion_externa | BOOLEAN | NOT NULL, DEFAULT FALSE | Sospecha de reparación fuera de la empresa |
| revision | observaciones | TEXT | NULL | Notas |
| inspeccion | folio | INT | PK, FK revision, ON DELETE CASCADE | Revisión propietaria (entidad débil) |
| inspeccion | tipo | VARCHAR(10) | PK, CHECK (VISUAL/MECANICA/FUERZA) | Discriminador del tipo de inspección |
| inspeccion | resultado | SMALLINT | NOT NULL, CHECK 1-20 | Resultado |
| inspeccion | detalle | TEXT | NULL | Detalle |
| refaccion | cod_refaccion | SERIAL | PK | Identificador de la refacción |
| refaccion | nombre | VARCHAR(60) | NOT NULL | Nombre |
| refaccion | costo | NUMERIC(8,2) | NOT NULL, CHECK >= 0 | Costo unitario |
| reparacion | cod_empleado | INT | PK, FK mecanico | Mecánico (ternaria) |
| reparacion | vin | CHAR(17) | PK, FK vehiculo | Vehículo (ternaria) |
| reparacion | cod_refaccion | INT | PK, FK refaccion | Refacción (ternaria) |
| reparacion | fecha | DATE | PK | Fecha de la reparación |
| reparacion | cantidad | SMALLINT | NOT NULL, DEFAULT 1, CHECK > 0 | Piezas usadas |
| reparacion | costo | NUMERIC(8,2) | NOT NULL, CHECK >= 0 | Costo total |

Nota: el atributo derivado condicion_actual no es columna; es la vista v_vehiculo_condicion.