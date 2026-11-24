# Pruebas de restricciones de dominio — práctica 4, ejercicio 1.5

**Base:** `practica45`, PostgreSQL 16. **Archivo ejecutable:** [pruebas-dominio.sql](pruebas-dominio.sql).

## Propósito

Demostrar que los atributos solo admiten valores válidos según las reglas del negocio. Esta batería contiene **11 operaciones que PostgreSQL debe rechazar** y **una prueba de DEFAULT que debe ser aceptada**. Todos los intentos están dentro de una transacción terminada en `ROLLBACK`; los rechazos se capturan con bloques PL/pgSQL `EXCEPTION` y se muestran mediante `NOTICE`. No se alteran permanentemente los datos.

**Requisitos previos:** esquema/migración 001 aplicados y carga sintética ejecutada. En CMD, desde la raíz del repositorio:

```cmd
docker exec -i pg-curso psql -U postgres -d practica45 -X -v ON_ERROR_STOP=1 < practica4\pruebas-dominio.sql
```

## Casos y reglas del dominio

| Caso | Operación intentada (resumen) | Resultado esperado | Regla protegida |
|---|---|---|---|
| 01 — NOT NULL | Cambiar `cliente.nombre` a `NULL` | Rechazo `23502` | Todo cliente debe tener nombre |
| 02 — UNIQUE simple | Copiar el correo de otro cliente | Rechazo `23505` | Cada correo identifica a un único cliente |
| 03 — UNIQUE compuesta | Repetir `(cod_cliente, telefono)` | Rechazo `23505` | Un mismo teléfono no se repite para el mismo cliente |
| 04 — CHECK rango | Cambiar `vehiculo.anio` a 1999 | Rechazo `23514` | Año entre 2000 y 2100 |
| 05 — CHECK formato | Cambiar `cliente.cp` a `ABCDE` | Rechazo `23514` | CP consta de cinco dígitos |
| 06 — CHECK lista | Cambiar turno administrativo a `NOCHE` | Rechazo `23514` | Solo `MATUTINO` o `VESPERTINO` |
| 07 — CHECK entre columnas | Cerrar contrato con fecha anterior al inicio | Rechazo `23514` | Cierre no anterior al inicio |
| 08 — CHECK entre columnas | Marcar `CERRADO` sin `fecha_cierre` | Rechazo `23514` | Estado y fecha deben ser coherentes |
| 09 — CREATE DOMAIN | Calificar revisión con 21 | Rechazo `23514` | `d_calificacion`: de 1 a 20 |
| 10 — CHECK entre columnas | Borrar observaciones cuando hay indicio externo | Rechazo `23514` | Un indicio debe documentarse |
| 11 — FK (adicional) | Apuntar contrato a cliente inexistente | Rechazo `23503` | Todo contrato pertenece a un cliente real de la BD |
| 12 — DEFAULT | Crear empleado omitiendo `fecha_ingreso` | Éxito con `CURRENT_DATE` | Registro recibe fecha actual por omisión |

## Resultado observado en PostgreSQL 16 — 24 de noviembre de 2026

Ejecución realizada en la base `practica45` con el comando documentado arriba. Las **dos capturas aportadas de la terminal** muestran los doce mensajes `NOTICE: CORRECTO` y la transacción concluida con `ROLLBACK`.

| Caso | SQLSTATE observado | Restricción o resultado observado | Resultado |
|---|---|---|---|
| 01 | 23502 | `cliente.nombre` impide `NULL` | Rechazado como se esperaba |
| 02 | 23505 | `uq_cliente_correo` | Rechazado como se esperaba |
| 03 | 23505 | `pk_cliente_telefono` (unicidad compuesta) | Rechazado como se esperaba |
| 04 | 23514 | `ck_vehiculo_anio` | Rechazado como se esperaba |
| 05 | 23514 | `ck_cliente_cp` | Rechazado como se esperaba |
| 06 | 23514 | `ck_admin_turno` | Rechazado como se esperaba |
| 07 | 23514 | `ck_contrato_fechas` | Rechazado como se esperaba |
| 08 | 23514 | `ck_contrato_cierre` | Rechazado como se esperaba |
| 09 | 23514 | `ck_d_calificacion` | Rechazado como se esperaba |
| 10 | 23514 | `ck_revision_externa` | Rechazado como se esperaba |
| 11 | 23503 | `fk_contrato_cliente` | Rechazado como se esperaba |
| 12 | Sin error | `empleado.fecha_ingreso = 2026-11-24`, valor `CURRENT_DATE` | DEFAULT correcto |

Salida final observada:

```text
ROLLBACK
=== FIN: 11 RECHAZOS ESPERADOS + 1 DEFAULT EXITOSO; CAMBIOS REVERTIDOS ===
```

Esta salida verifica el comportamiento observado de las restricciones probadas. La función de prueba captura cada error dentro de una subtransacción, y el `ROLLBACK` final revierte el `INSERT` de comprobación del DEFAULT. No demuestra por sí sola que todos los registros existentes cumplan todas las reglas ni completa las pruebas de integridad referencial de la práctica 5.

**Evidencias a adjuntar al repositorio:**

- `practica4/evidencias/06-pruebas-dominio-parte1.png`
- `practica4/evidencias/06-pruebas-dominio-parte2.png`

Los nombres corresponden a las capturas aportadas de la ejecución; **las imágenes deben guardarse y subirse por separado** para que aparezcan en GitHub.

### Códigos SQLSTATE usados

- `23502`: violación de NOT NULL.
- `23505`: violación de UNIQUE.
- `23514`: violación de CHECK o CREATE DOMAIN.
- `23503`: violación de clave foránea.

La prueba `DEFAULT` no debe generar error; sirve para demostrar el valor inicial natural, como solicita la rúbrica.
