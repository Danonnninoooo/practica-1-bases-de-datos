-- esquema.sql | Renta semanal de vehículos | PostgreSQL 16

-- REGLA 1, 2 y 3: entidades fuertes, compuestos descompuestos
CREATE TABLE cliente (
  cod_cliente   SERIAL,
  nombre        VARCHAR(60) NOT NULL,
  ap_paterno    VARCHAR(40) NOT NULL,
  ap_materno    VARCHAR(40),
  curp          CHAR(18)    NOT NULL,
  correo        VARCHAR(100) NOT NULL,
  calle         VARCHAR(80) NOT NULL,
  colonia       VARCHAR(60) NOT NULL,
  cp            CHAR(5)     NOT NULL,
  municipio     VARCHAR(60) NOT NULL,
  cuenta_banco  VARCHAR(20),
  CONSTRAINT pk_cliente PRIMARY KEY (cod_cliente),
  CONSTRAINT uq_cliente_curp UNIQUE (curp),
  CONSTRAINT uq_cliente_correo UNIQUE (correo),
  CONSTRAINT ck_cliente_cp CHECK (cp ~ '^[0-9]{5}$')
);

-- Regla 3: multivaluado -> tabla aparte
CREATE TABLE cliente_telefono (
  cod_cliente INT         NOT NULL,
  telefono    VARCHAR(15) NOT NULL,
  CONSTRAINT pk_cliente_telefono PRIMARY KEY (cod_cliente, telefono),
  CONSTRAINT fk_telefono_cliente FOREIGN KEY (cod_cliente)
    REFERENCES cliente (cod_cliente) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE modelo (
  id_modelo    SERIAL,
  marca        VARCHAR(30) NOT NULL,
  nombre       VARCHAR(30) NOT NULL,
  litros_motor NUMERIC(2,1) NOT NULL,
  CONSTRAINT pk_modelo PRIMARY KEY (id_modelo),
  CONSTRAINT uq_modelo UNIQUE (marca, nombre, litros_motor),
  CONSTRAINT ck_modelo_litros CHECK (litros_motor > 0)
);

-- Regla 4: 1:N modelo -> vehiculo (mínimo 1 en el lado muchos => NOT NULL)
CREATE TABLE vehiculo (
  vin       CHAR(17)    NOT NULL,
  color     VARCHAR(20) NOT NULL,
  anio      SMALLINT    NOT NULL,
  id_modelo INT         NOT NULL,
  CONSTRAINT pk_vehiculo PRIMARY KEY (vin),
  CONSTRAINT ck_vehiculo_anio CHECK (anio BETWEEN 2000 AND 2100),
  CONSTRAINT fk_vehiculo_modelo FOREIGN KEY (id_modelo)
    REFERENCES modelo (id_modelo) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Regla 9, estrategia A: supertipo + subtipos
CREATE TABLE empleado (
  cod_empleado  SERIAL,
  nombre        VARCHAR(60) NOT NULL,
  ap_paterno    VARCHAR(40) NOT NULL,
  fecha_ingreso DATE        NOT NULL DEFAULT CURRENT_DATE,
  tipo          VARCHAR(15) NOT NULL,   -- discriminador (garantiza disyunción)
  CONSTRAINT pk_empleado PRIMARY KEY (cod_empleado),
  CONSTRAINT ck_empleado_tipo CHECK (tipo IN ('MECANICO','ADMINISTRATIVO')),
  CONSTRAINT uq_empleado_tipo UNIQUE (cod_empleado, tipo)
);

CREATE TABLE mecanico (
  cod_empleado  INT         NOT NULL,
  tipo          VARCHAR(15) NOT NULL DEFAULT 'MECANICO',
  especialidad  VARCHAR(40) NOT NULL,
  certificacion VARCHAR(60),
  CONSTRAINT pk_mecanico PRIMARY KEY (cod_empleado),
  CONSTRAINT ck_mecanico_tipo CHECK (tipo = 'MECANICO'),
  CONSTRAINT fk_mecanico_empleado FOREIGN KEY (cod_empleado, tipo)
    REFERENCES empleado (cod_empleado, tipo) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE administrativo (
  cod_empleado INT         NOT NULL,
  tipo         VARCHAR(15) NOT NULL DEFAULT 'ADMINISTRATIVO',
  area         VARCHAR(40) NOT NULL,
  turno        VARCHAR(10) NOT NULL,
  CONSTRAINT pk_administrativo PRIMARY KEY (cod_empleado),
  CONSTRAINT ck_admin_tipo CHECK (tipo = 'ADMINISTRATIVO'),
  CONSTRAINT ck_admin_turno CHECK (turno IN ('MATUTINO','VESPERTINO')),
  CONSTRAINT fk_admin_empleado FOREIGN KEY (cod_empleado, tipo)
    REFERENCES empleado (cod_empleado, tipo) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Regla 4 (x2): contrato recibe las claves de cliente y vehiculo
CREATE TABLE contrato (
  id_contrato   SERIAL,
  cod_cliente   INT           NOT NULL,
  vin           CHAR(17)      NOT NULL,
  fecha_inicio  DATE          NOT NULL DEFAULT CURRENT_DATE,
  pago_semanal  NUMERIC(8,2)  NOT NULL,
  estado        VARCHAR(10)   NOT NULL DEFAULT 'VIGENTE',
  CONSTRAINT pk_contrato PRIMARY KEY (id_contrato),
  CONSTRAINT ck_contrato_pago CHECK (pago_semanal > 0),
  CONSTRAINT ck_contrato_estado CHECK (estado IN ('VIGENTE','CERRADO')),
  CONSTRAINT fk_contrato_cliente FOREIGN KEY (cod_cliente)
    REFERENCES cliente (cod_cliente) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_contrato_vehiculo FOREIGN KEY (vin)
    REFERENCES vehiculo (vin) ON DELETE RESTRICT ON UPDATE CASCADE
);
-- Regla de negocio: un solo contrato VIGENTE por cliente y por vehículo
CREATE UNIQUE INDEX uq_contrato_vigente_cliente ON contrato (cod_cliente) WHERE estado = 'VIGENTE';
CREATE UNIQUE INDEX uq_contrato_vigente_vehiculo ON contrato (vin) WHERE estado = 'VIGENTE';

-- Regla 8: entidad débil por identificación
CREATE TABLE pago_semanal (
  id_contrato INT          NOT NULL,
  num_semana  SMALLINT     NOT NULL,
  monto       NUMERIC(8,2) NOT NULL,
  fecha       DATE         NOT NULL,
  CONSTRAINT pk_pago_semanal PRIMARY KEY (id_contrato, num_semana),
  CONSTRAINT ck_pago_semana CHECK (num_semana > 0),
  CONSTRAINT ck_pago_monto CHECK (monto > 0),
  CONSTRAINT fk_pago_contrato FOREIGN KEY (id_contrato)
    REFERENCES contrato (id_contrato) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE revision (
  folio         SERIAL,
  vin           CHAR(17)    NOT NULL,
  cod_empleado  INT         NOT NULL,   -- mecánico que la realiza
  fecha         DATE        NOT NULL DEFAULT CURRENT_DATE,
  calificacion  SMALLINT    NOT NULL,
  indicio_reparacion_externa BOOLEAN NOT NULL DEFAULT FALSE,
  observaciones TEXT,
  CONSTRAINT pk_revision PRIMARY KEY (folio),
  CONSTRAINT ck_revision_calif CHECK (calificacion BETWEEN 1 AND 20),
  CONSTRAINT uq_revision_vin_fecha UNIQUE (vin, fecha),
  CONSTRAINT fk_revision_vehiculo FOREIGN KEY (vin)
    REFERENCES vehiculo (vin) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_revision_mecanico FOREIGN KEY (cod_empleado)
    REFERENCES mecanico (cod_empleado) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX ix_revision_vin_fecha ON revision (vin, fecha DESC);

-- Regla 8: otra entidad débil por identificación (discriminador = tipo)
CREATE TABLE inspeccion (
  folio     INT         NOT NULL,
  tipo      VARCHAR(10) NOT NULL,
  resultado SMALLINT    NOT NULL,
  detalle   TEXT,
  CONSTRAINT pk_inspeccion PRIMARY KEY (folio, tipo),
  CONSTRAINT ck_inspeccion_tipo CHECK (tipo IN ('VISUAL','MECANICA','FUERZA')),
  CONSTRAINT ck_inspeccion_res CHECK (resultado BETWEEN 1 AND 20),
  CONSTRAINT fk_inspeccion_revision FOREIGN KEY (folio)
    REFERENCES revision (folio) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE refaccion (
  cod_refaccion SERIAL,
  nombre        VARCHAR(60)  NOT NULL,
  costo         NUMERIC(8,2) NOT NULL,
  CONSTRAINT pk_refaccion PRIMARY KEY (cod_refaccion),
  CONSTRAINT ck_refaccion_costo CHECK (costo >= 0)
);

-- Regla 7: relación ternaria -> tabla propia con las 3 claves
CREATE TABLE reparacion (
  cod_empleado  INT          NOT NULL,
  vin           CHAR(17)     NOT NULL,
  cod_refaccion INT          NOT NULL,
  fecha         DATE         NOT NULL,
  cantidad      SMALLINT     NOT NULL DEFAULT 1,
  costo         NUMERIC(8,2) NOT NULL,
  CONSTRAINT pk_reparacion PRIMARY KEY (cod_empleado, vin, cod_refaccion, fecha),
  CONSTRAINT ck_reparacion_cant CHECK (cantidad > 0),
  CONSTRAINT ck_reparacion_costo CHECK (costo >= 0),
  CONSTRAINT fk_rep_mecanico FOREIGN KEY (cod_empleado)
    REFERENCES mecanico (cod_empleado) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_rep_vehiculo FOREIGN KEY (vin)
    REFERENCES vehiculo (vin) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_rep_refaccion FOREIGN KEY (cod_refaccion)
    REFERENCES refaccion (cod_refaccion) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Atributo derivado: condicion_actual se calcula, no se guarda
CREATE VIEW v_vehiculo_condicion AS
SELECT v.vin,
       (SELECT r.calificacion FROM revision r
         WHERE r.vin = v.vin ORDER BY r.fecha DESC LIMIT 1) AS condicion_actual
FROM vehiculo v;