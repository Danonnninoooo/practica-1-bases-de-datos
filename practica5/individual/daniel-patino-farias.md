# Ejercicio 2.6 — Refacción y reparación

**Borrador de aportación individual para Daniel Patiño Farias.** Revisar, explicar con palabras propias y firmar antes de entregar. Se preparó con asistencia de ChatGPT; la ejecución fue realizada por el estudiante.

Relación elegida: reparacion.cod_refaccion → refaccion.cod_refaccion, restricción fk_rep_refaccion. La pieza de prueba 940001 estaba referenciada por una reparación. El experimento se ejecutó en la copia practica45_dml mediante [04-prueba-individual.sql](sql/04-prueba-individual.sql).

| Situación | Refacciones | Reparaciones |
|---|---:|---:|
| Inicial | 240 | 240 |
| DELETE con RESTRICT | 240 | 240 |
| DELETE tras cambiar a CASCADE | 239 | 239 |
| ROLLBACK final | 240 | 240 |

RESTRICT rechazó el borrado con SQLSTATE 23503. CASCADE eliminó la pieza y la reparación dependiente, dejando cero reparaciones de esa pieza. Las otras 239 reparaciones se conservaron. ROLLBACK restauró tanto las filas como la restricción original ON UPDATE CASCADE ON DELETE RESTRICT.

Para Semanal Autos conviene RESTRICT: retirar una refacción del catálogo no debe borrar el historial del mantenimiento. En una ampliación se podría incorporar un indicador de disponibilidad para retirar del catálogo sin perder trazabilidad.

Evidencia [40](evidencias/40-prueba-individual-restrict-cascade.png), observada localmente, pendiente de subir. No representa trabajo individual de los demás integrantes.

Firma del estudiante: pendiente.
