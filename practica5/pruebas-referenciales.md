# Pruebas referenciales — Práctica 5, ejercicio 2.3

Ejecución observada el 24/11/2026 en practica45 (PostgreSQL 16), mediante [01-pruebas-referenciales.sql](sql/01-pruebas-referenciales.sql). Los datos de contratos, vehículos, pagos y revisiones son sintéticos de demostración. Se verificaron 13 claves foráneas. Los cambios fueron revertidos por ROLLBACK.

| Operación | Antes | Después dentro de la transacción | Regla |
|---|---|---|---|
| DELETE de revision folio 930001 | 240 revisiones, 720 inspecciones | 239 revisiones, 717 inspecciones | ON DELETE CASCADE: se eliminan las tres inspecciones dependientes. |
| DELETE de modelo id 1 | 73 modelos, 240 vehículos | 73 modelos, 240 vehículos | ON DELETE RESTRICT: no se puede eliminar el modelo usado. SQLSTATE 23503, fk_vehiculo_modelo. |
| UPDATE de revision folio 930002 a -900001 | 3 inspecciones asociadas; 717 totales | 3 inspecciones con nueva clave; 717 totales | ON UPDATE CASCADE: se mantiene la referencia. Las 717 corresponden al estado transitorio tras la primera prueba. |
| INSERT de pago con contrato inexistente -900001 | 960 pagos | Rechazado, SQLSTATE 23503, fk_pago_contrato | La clave padre debe existir. |
| INSERT primero del contrato y después del pago | 960 pagos | 961 pagos | La carga respeta el orden de dependencias. |

Mensajes observados del gestor:
- update or delete on table "modelo" violates foreign key constraint "fk_vehiculo_modelo" on table "vehiculo"
- insert or update on table "pago_semanal" violates foreign key constraint "fk_pago_contrato" on table "pago_semanal"

Después de ROLLBACK: 240 revisiones, 720 inspecciones, 240 contratos y 960 pagos. La evidencia 37 se guardará en [evidencias](evidencias/). Falta comprobar huérfanos, duplicados y nulos de ambas bases.
