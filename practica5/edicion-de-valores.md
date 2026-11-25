# Edición de valores y transacciones — ejercicio 2.4

[Script SQL](sql/02-edicion-valores.sql). Se ejecutó sobre la copia `practica45_dml` de Semanal Autos. La base original no se usa para las modificaciones. Datos sintéticos de demostración.

| Operación | Situación de negocio | Resultado observado |
|---|---|---|
| INSERT SELECT | Registrar un contrato de prueba y su pago a partir de datos existentes | INSERT 0 1 en cada tabla. |
| ON CONFLICT DO NOTHING | Evitar duplicar una semana de pago | INSERT 0 0; un solo pago inicial. |
| UPDATE FROM | Actualizar el pago de prueba al importe del contrato | Contrato -910001, semana 1, 2500.00. Ejemplo de ajuste de un pago de prueba, no de modificación indiscriminada de pagos históricos. |
| UPDATE CASE | Clasificar revisiones por condición | Folio 930010, 20, Condicion aceptable; folio 930011, 10, Requiere seguimiento. |
| DELETE con subconsulta | Retirar el pago de prueba de un contrato cerrado | DELETE 1, contrato -910001 semana 1. |
| Cierre lógico | Conservar historial al cerrar una renta | Contrato 920001, CERRADO, fecha 2026-11-25 según CURRENT_DATE del servidor; conserva cuatro pagos. |

Las operaciones del primer bloque se revierten al final con ROLLBACK. El borrado físico pierde la fila; al borrar físicamente un contrato también se pierden sus pagos por CASCADE. Cerrar el contrato conserva el historial y permite liberar la unidad conforme al estado VIGENTE. El cierre lógico es específico de este dominio, no un borrado físico.

## Transacción exitosa

Contrato de prueba -910002 y primer pago se insertan en la misma transacción. Monto original 2350.00. SAVEPOINT antes_ajuste; ajuste a 3000.00; ROLLBACK TO SAVEPOINT restaura 2350.00. El script ejecuta COMMIT; las capturas no muestran esa línea, pero el bloque posterior parte de 241 contratos y 961 pagos (uno adicional de cada tabla) y la limpieza elimina exactamente un contrato confirmado, -910002, con cero pagos dependientes restantes.

## Transacción fallida

Se intenta crear el contrato -910003 y un pago de -100. El dominio rechaza el pago:
```text
ERROR: value for domain d_monto violates check constraint "ck_d_monto"
SQLSTATE 23514
```
ROLLBACK revierte todo: 241 contratos y 961 pagos antes y después; cero filas del contrato fallido y cero pagos del contrato fallido. La limpieza posterior elimina el contrato confirmado de prueba y sus pagos por CASCADE, únicamente en la copia.

## Evidencias
- [Parte 1](evidencias/38-dml-transacciones-parte1.png).
- [Parte 2](evidencias/38-dml-transacciones-parte2.png).

Capturas observadas; archivos de evidencia pendientes de subir. Los conteos finales completos se verifican por separado.
