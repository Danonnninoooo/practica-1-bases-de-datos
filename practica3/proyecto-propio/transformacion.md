# Transformación EER → relacional: renta semanal de vehículos

## 1. Inventario del modelo EER (Ejercicio 2)

**Entidades fuertes:** CLIENTE (cod_cliente), MODELO (id_modelo), VEHICULO (vin), EMPLEADO (cod_empleado), CONTRATO (id_contrato), REVISION (folio), REFACCION (cod_refaccion).

**Entidades débiles (dependencia de identificación):**
- PAGO_SEMANAL, propietaria CONTRATO, discriminador num_semana.
- INSPECCION, propietaria REVISION, discriminador tipo.

**Relaciones (mín,máx):**
| Relación | Cardinalidad |
|---|---|
| CLIENTE – firma – CONTRATO | (0,N) : (1,1) |
| VEHICULO – se asigna en – CONTRATO | (0,N) : (1,1) |
| VEHICULO – recibe – REVISION | (0,N) : (1,1) |
| MECANICO – realiza – REVISION | (0,N) : (1,1) |
| MODELO – es de – VEHICULO | (0,N) : (1,1) |
| CONTRATO – genera – PAGO_SEMANAL | (0,N) : (1,1), identificadora |
| REVISION – se compone de – INSPECCION | (3,3) : (1,1), identificadora |

**Jerarquía:** EMPLEADO → MECANICO (especialidad, certificacion) / ADMINISTRATIVO (area, turno). Disjunta y total.

**Atributos especiales:** compuestos: nombre y dirección de CLIENTE. Multivaluado: teléfono de CLIENTE. Derivados: calificacion_previa, condicion_actual.

**Relación ternaria:** MECANICO – VEHICULO – REFACCION (atributos: fecha, cantidad, costo).

**Preguntas previas:**
- Requieren tabla adicional: teléfono (multivaluado), reparacion (ternaria), mecanico y administrativo (jerarquía), pago_semanal e inspeccion (débiles).
- Se vuelven claves foráneas: id_modelo, cod_cliente y vin en contrato, vin y cod_empleado en revision, entre otras.
- Decisión en la jerarquía: elegir estrategia A, B o C (ver sección 4).

## 2. Reglas de transformación aplicadas (Ejercicios 3 y 4)

| Elemento del EER | Regla | Tabla resultante |
|---|---|---|
| Entidades fuertes | Regla 1 | cliente, modelo, vehiculo, empleado, contrato, revision, refaccion |
| Nombre y dirección compuestos | Regla 2 | columnas nombre, ap_paterno, ap_materno, calle, colonia, cp, municipio |
| Teléfono multivaluado | Regla 3 | cliente_telefono, PK (cod_cliente, telefono) |
| MODELO–VEHICULO 1:N | Regla 4 | vehiculo.id_modelo, NOT NULL (mín. 1) |
| CLIENTE–CONTRATO 1:N | Regla 4 | contrato.cod_cliente, NOT NULL |
| VEHICULO–CONTRATO 1:N | Regla 4 | contrato.vin, NOT NULL |
| VEHICULO–REVISION 1:N | Regla 4 | revision.vin, NOT NULL |
| MECANICO–REVISION 1:N | Regla 4 | revision.cod_empleado, NOT NULL |
| Ternaria | Regla 7 | reparacion, PK de 4 columnas (3 claves + fecha) |

**Regla de negocio "un cliente, un vehículo":** CLIENTE–VEHICULO es 1:1 en un instante, pero se modeló con CONTRATO para conservar historial. Se garantiza con dos índices únicos parciales sobre estado = 'VIGENTE'.

## 3. Entidades débiles (Ejercicio 5, Regla 8)

- **pago_semanal:** PK (id_contrato, num_semana); FK NOT NULL con ON DELETE CASCADE.
- **inspeccion:** PK (folio, tipo); FK NOT NULL con ON DELETE CASCADE; tipo restringido a VISUAL, MECANICA o FUERZA.

Si se borra el propietario, la entidad débil no tiene sentido, por eso CASCADE.

## 4. Jerarquía (Regla 9)

- **Clasificación:** disjunta y total.
- **Estrategia elegida: A** (tabla por supertipo y por subtipo).
- **Justificación:** los subtipos tienen atributos propios distintos (especialidad/certificación frente a área/turno), por lo que B generaría muchos nulos; C no aplica porque revision necesita apuntar a mecanico y empleado tiene atributos comunes. Con A, revision referencia solo a mecanico y no se pueden asignar revisiones a un administrativo.
- **Discriminador:** empleado.tipo con CHECK (MECANICO/ADMINISTRATIVO). Cada subtipo repite tipo con un CHECK fijo y una FK compuesta (cod_empleado, tipo), así un empleado no puede estar en los dos subtipos (disyunción).

## 5. Preservación del significado (Ejercicio 6.5)

**Nada se perdió:** las 7 entidades fuertes, las 2 débiles, la jerarquía, el multivaluado, los compuestos y la ternaria tienen tabla o columnas (13 tablas + 1 vista).

**Cardinalidades reflejadas:**
- Mínimo 1 → FK NOT NULL; mínimo 0 → admite nulos.
- Máximo 1 del contrato vigente → índices únicos parciales.
- Entidades débiles → PK compuesta + CASCADE.

**Atributos derivados:** condicion_actual es la vista v_vehiculo_condicion; calificacion_previa se obtiene con una consulta (no se almacena).

**Limitaciones declaradas:**
1. La cardinalidad (3,3) de REVISION–INSPECCION solo se garantiza en parte (PK (folio,tipo) y CHECK evitan duplicados y tipos inválidos), pero que existan siempre las tres requeriría un trigger o validar en la aplicación.
2. La totalidad de la jerarquía (todo empleado debe tener fila en un subtipo) tampoco se fuerza solo con DDL; requeriría un trigger con restricción diferida.

## 6. Cambios respecto a la Práctica 1 (por la rúbrica)
- Se eliminó EMPRESA (una sola fila, sin sucursales).
- La relación renta pasó a la entidad CONTRATO para conservar historial.
- Los subtipos Visual/Mecánica/Fuerza pasaron a la entidad débil INSPECCION.
- Marca, nombre y litros pasaron a MODELO.
- Se agregó la jerarquía EMPLEADO y la ternaria reparacion.