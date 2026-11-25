# Claves foráneas y acciones referenciales — Práctica 5 (2.1 y 2.2)

Base: practica45, PostgreSQL 16. Fuente: [esquema de práctica 3](../practica3/sql/esquema.sql) y [migración 001](../practica4/migraciones/001-dominios.sql), [002](../practica4/migraciones/002-motores-mx.sql). Las migraciones no cambian las acciones referenciales. Todas las columnas de FK son NOT NULL: cada fila hija requiere su padre. Eso no obliga a cada padre a tener hijos.

| Restricción | Hija (columnas) | Padre (columnas) | Relación EER | ¿Nulo? | ON DELETE | Justificación |
|---|---|---|---|---|---|---|
| fk_telefono_cliente | cliente_telefono(cod_cliente) | cliente(cod_cliente) | Cliente y teléfonos multivaluados | No | CASCADE | El teléfono asociado no tiene sentido sin el cliente. |
| fk_vehiculo_modelo | vehiculo(id_modelo) | modelo(id_modelo) | Modelo de cada vehículo | No | RESTRICT | No dejar unidades sin modelo. |
| fk_mecanico_empleado | mecanico(cod_empleado,tipo) | empleado(cod_empleado,tipo) | Especialización mecánico | No | CASCADE | El subtipo depende de la identidad del empleado; otras FK pueden impedir el borrado. |
| fk_admin_empleado | administrativo(cod_empleado,tipo) | empleado(cod_empleado,tipo) | Especialización administrativo | No | CASCADE | El subtipo no sobrevive al empleado. |
| fk_contrato_cliente | contrato(cod_cliente) | cliente(cod_cliente) | Cliente celebra contratos | No | RESTRICT | Conservar historial de rentas. |
| fk_contrato_vehiculo | contrato(vin) | vehiculo(vin) | Vehículo de cada contrato | No | RESTRICT | Conservar el historial de unidades rentadas. |
| fk_pago_contrato | pago_semanal(id_contrato) | contrato(id_contrato) | Pago, entidad débil | No | CASCADE | El pago depende del contrato; en producción preferir conservar contratos. |
| fk_revision_vehiculo | revision(vin) | vehiculo(vin) | Revisión de vehículo | No | RESTRICT | No perder trazabilidad de las revisiones. |
| fk_revision_mecanico | revision(cod_empleado) | mecanico(cod_empleado) | Mecánico realiza revisión | No | RESTRICT | Conservar responsable técnico. |
| fk_inspeccion_revision | inspeccion(folio) | revision(folio) | Inspección, entidad débil | No | CASCADE | No existe una inspección independiente de su revisión. |
| fk_rep_mecanico | reparacion(cod_empleado) | mecanico(cod_empleado) | Reparación ternaria | No | RESTRICT | Conservar responsable de la reparación. |
| fk_rep_vehiculo | reparacion(vin) | vehiculo(vin) | Reparación ternaria | No | RESTRICT | Conservar historial de mantenimiento. |
| fk_rep_refaccion | reparacion(cod_refaccion) | refaccion(cod_refaccion) | Reparación ternaria | No | RESTRICT | Conservar identidad de la pieza utilizada. |

Todas tienen ON UPDATE CASCADE para que una corrección autorizada de una clave padre conserve la referencia de sus hijos; las claves de identidad se mantienen estables en la operación habitual. No usamos SET NULL ni SET DEFAULT porque las referencias son obligatorias y no hay padres ficticios por omisión. La disyunción de los subtipos se protege con discriminador y FK compuesta; las FK por sí solas no garantizan que todo empleado tenga un subtipo.

## Pruebas

[SQL de pruebas](sql/01-pruebas-referenciales.sql): inventario, CASCADE, RESTRICT, UPDATE CASCADE, intento de FK inexistente, orden padre-hijo y reversión de cambios. Se usan filas de la carga comprobada y una clave temporal negativa. Se ejecuta dentro de BEGIN/ROLLBACK; no se emplean secuencias para las inserciones de prueba. Los resultados aún deben obtenerse en el gestor y documentarse en pruebas-referenciales.md. Faltan las comprobaciones exhaustivas de ambas bases (huérfanos, duplicados y nulos), el resto de DML y el trabajo individual.
