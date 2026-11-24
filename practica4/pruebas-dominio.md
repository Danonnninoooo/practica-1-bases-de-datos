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

## Salida del gestor (por completar después de ejecutarlo)

Los mensajes **reales** de PostgreSQL aparecerán como:

```text
NOTICE: CORRECTO: [caso] | SQLSTATE=[codigo] | CONSTRAINT=[nombre] | MENSAJE=[texto de PostgreSQL]
```

**No afirmar aún que estas pruebas se ejecutaron.** Después de comprobar la salida, capturar en `practica4/evidencias/06-pruebas-dominio.png` (si no caben todos los casos, guardar varias capturas correlativas o registrar la salida de terminal). Documentar cualquier discrepancia entre los errores esperados y observados y corregir la prueba o la migración según corresponda.

### Códigos SQLSTATE usados

- `23502`: violación de NOT NULL.
- `23505`: violación de UNIQUE.
- `23514`: violación de CHECK o CREATE DOMAIN.
- `23503`: violación de clave foránea.

La prueba `DEFAULT` no debe generar error; sirve para demostrar el valor inicial natural, como solicita la rúbrica.
