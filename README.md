# Bases de Datos: Renta semanal de vehículos

## Segundo parcial: aplicación web de Semanal Autos (registro local verificado)

**Demostración local:** http://localhost:8081/ — requiere Docker y configuración indicada en [web/README.md](web/README.md). La página estática presentada en el primer parcial continúa en [GitHub Pages](https://danonnninoooo.github.io/practica-1-bases-de-datos/), pero **el envío a PostgreSQL solo está habilitado en el backend local**.

- [Código del backend Flask](web/app.py), [configuración Docker](web/compose.yaml) y [formulario en la portada](index.html).
- La aplicación usa el rol `usuario_app_renta` y ejecuta una transacción para insertar en `cliente` y `cliente_telefono`.
- **Estado:** registro de prueba desde el navegador y comprobación independiente mediante SELECT en `cliente` y `cliente_telefono` verificados el 24 de noviembre de 2026 (código 1). [Resultados e incidencia resuelta](web/README.md). Pendiente subir las dos capturas de la web.
- Todavía pendientes para la exposición: práctica integrada 6–8 (normalización, RelaX y SQL), consultas y árboles de Sismos, análisis del manuscrito y propuestas de mejora.

---

## Prácticas 4 y 5 — ejecución y estado (rama de trabajo)

> **Estado:** carga inicial y segunda ejecución sin duplicados verificadas; creación de roles, pruebas de lectura, UPDATE denegado, REVOKE/GRANT y 12 pruebas de dominio verificadas. [Evidencias](practica4/evidencias/). No se consideran terminadas las prácticas: quedan requisitos específicos pendientes.

### Datos sintéticos y fuente

Se conserva un catálogo real de **723 registros NHTSA** en ocho JSON; **73 modelos** coinciden con el filtro de vehículos y son cargados desde `practica4/datos/`. El campo `litros_motor` de esos modelos es **sintético**, no una especificación oficial de NHTSA. Los registros de clientes, teléfonos, personal, vehículos, contratos, pagos, revisiones, inspecciones, refacciones y reparaciones se generan sintéticamente; no corresponden a personas ni vehículos reales. La explicación y pendientes de verificación están en [fuente.md](practica4/fuente.md).

### Cargar la base (PostgreSQL 16 en Docker)

Prerequisitos: contenedor `pg-curso` iniciado, base `practica45`, esquema de `practica3/sql/esquema.sql` y migración `practica4/migraciones/001-dominios.sql` ya aplicados.

1. En **CMD** desde la raíz del repositorio, instalar roles y permisos (repetible):

   ```cmd
   docker exec -i pg-curso psql -U postgres -d practica45 -X -v ON_ERROR_STOP=1 < practica4\permisos\00-crear-roles.sql
   ```

2. En **Git Bash**, desde la raíz del repositorio, cargar todo **con un comando**:

   ```bash
   bash practica4/poblar/poblar.sh
   ```

3. Ejecutar de nuevo el mismo comando y conservar ambas salidas. La segunda ejecución debe mostrar **cero registros insertados** en todas las tablas.

El script usa el usuario `usuario_app_renta` (hereda `rol_app_renta`), no el superusuario; la ejecución usa conexión local dentro de Docker. La carga de JSON utiliza `COPY` a staging temporal y los sintéticos usan `INSERT ... SELECT` por lotes. `BEGIN/COMMIT` encapsula la operación; con `ON_ERROR_STOP=1` el error detiene `psql` y se revierte la transacción. No se incrustan contraseñas en los scripts nuevos. El `compose.yaml` heredado todavía contiene una credencial de desarrollo: **debe migrarse a configuración por variables de entorno y rotarse** antes de publicar o conectar un backend.

**Resultado observado en la primera carga sobre una base con solo 73 modelos:** 240 clientes y teléfonos; 440 empleados (220 mecánicos y 220 administrativos); 240 vehículos y contratos; 960 pagos; 240 revisiones; 720 inspecciones; 240 refacciones y 240 reparaciones. Total inicial: 4,313 filas en 13 tablas. La segunda carga insertó cero filas. El registro web posterior añadió un cliente y su teléfono.

### Entregables todavía pendientes

- Completar documentación de fuentes y verificar condiciones de reutilización; medición de tiempos de `COPY` frente a inserciones convencionales.
- Completar pruebas de permisos de aplicación y administración, documentación y pruebas de integridad referencial. Las 12 pruebas de dominio y las pruebas de lectura/REVOKE ya cuentan con evidencias.
- Práctica 5 (migración de referencias, ejercicios DML y transacciones, almacén de Sismos y aportación individual).
- Segundo parcial: adjuntar evidencias web, normalización y RelaX/SQL, consultas de Sismos, artículo y presentación.

---

Instituto Politécnico Nacional, Escuela Superior de Cómputo
Ingeniería en Sistemas Computacionales, Plan 2020 | Grupo 3CV4
Profesor: Gabriel Hurtado Avilés

## Enlaces principales (exposición del primer parcial)

| Elemento | Dirección |
|---|---|
| Landing page del proyecto propio (GitHub Pages) | https://danonnninoooo.github.io/practica-1-bases-de-datos/ |
| Proyecto asignado: Sismos (fork) | https://github.com/Danonnninoooo/Seismic-Data-Visualization-System |
| Commit con el que se puso en funcionamiento Sismos | 8569667cf4f46fab640dba3f82a7b324ca7efaf7 |
| Versión publicada de Sismos | [COMPLETAR] |
| Presentación (PDF) | [exposicion/presentacion.pdf](exposicion/exposicion/Presentación Propuesta Proyecto Corporativo Elegante Negro_compressed.pdf) |
| Fichas de los tres artículos | [exposicion/fichas-articulos.md](exposicion/fichas-articulos.md) |

## Integrantes

| Integrante | Usuario GitHub | Participación |
|---|---|---|
| Daniel Patiño Farias | Danonnninoooo | Proyecto propio (modelo EER, esquema.sql, pruebas de restricciones, diagramas, diccionario, transformación), landing page, proyecto asignado Sismos (fork, levantamiento, análisis del esquema), fichas de artículos |
| Arath Sebastian Sanchez Valenzuela | Zuzuuuu2729 | Presentación de la exposición, revisión y fusión de Pull Requests |
| Alejandro Rivas Ramirez | AlejandrRrz | ya aparecio |

## Proyecto propio

Sistema de renta semanal de autos compactos (March, Versa), con un pago semanal aproximado de $2,300 y una revisión cada ocho días para detectar reparaciones hechas fuera de la empresa.

Gestor: PostgreSQL 16 en contenedor Docker, configurado en [entorno/compose.yaml](entorno/compose.yaml).

### Modelo

- Modelo relacional: 13 tablas ejecutadas en PostgreSQL, con diagrama en [practica3/proyecto-propio/diagrama-relacional.png](practica3/proyecto-propio/diagrama-relacional.png).
- Entidades débiles: PAGO_SEMANAL (de CONTRATO) e INSPECCION (de REVISION).
- Jerarquía: EMPLEADO, con subtipos MECANICO y ADMINISTRATIVO (disjunta y total).
- Atributo multivaluado (teléfono), compuestos (nombre y dirección), derivados (condición actual y calificación previa) y una relación ternaria (reparación).

### Cambios respecto a la Práctica 1

- Se eliminó EMPRESA (una sola fila, sin sucursales).
- La relación renta pasó a ser la entidad CONTRATO para conservar historial.
- Los subtipos Visual, Mecánica y Fuerza pasaron a la entidad débil INSPECCION.
- Marca, nombre y litros del motor pasaron a MODELO.
- Se agregó la jerarquía EMPLEADO y la ternaria reparación.

## Práctica 3: índice

- [esquema.sql](practica3/sql/esquema.sql)
- [pruebas-de-restricciones.sql](practica3/sql/pruebas-de-restricciones.sql)
- [Diagrama relacional](practica3/proyecto-propio/diagrama-relacional.png)
- [Diccionario de datos](practica3/proyecto-propio/diccionario-de-datos.pdf)
- [Inventario, transformación y preservación del significado](practica3/proyecto-propio/Transformacion.pdf)
- [Evidencias](practica3/evidencias)
- Ejercicio 7 (esquema de Sismos): [COMPLETAR cuando se fusione practica3/proyecto-asignado]
- Ejercicio 8 (cambio individual): pendiente

## Artículos presentados

Fichas completas en [exposicion/fichas-articulos.md](exposicion/fichas-articulos.md).

1. Kossmann, J., Papenbrock, T., & Naumann, F. (2022). Data dependencies for query optimization: A survey. *The VLDB Journal, 31*, 1-22. https://doi.org/10.1007/s00778-021-00676-3
2. Lan, H., Bao, Z., & Peng, Y. (2021). A survey on advancing the DBMS query optimizer: Cardinality estimation, cost model, and plan enumeration. *Data Science and Engineering, 6*, 86-101. https://doi.org/10.1007/s41019-020-00149-7
3. Perera, R. M., Oetomo, B., Rubinstein, B. I. P., & Borovica-Gajic, R. (2021). DBA bandits: Self-driving index tuning under ad-hoc, analytical workloads with safety guarantees. *2021 IEEE 37th International Conference on Data Engineering (ICDE)*, 600-611. https://doi.org/10.1109/ICDE51399.2021.00058

## Proyecto asignado: Sismos

Sistema de visualización de datos sísmicos de México (PHP, PostgreSQL y Docker). Muestra en un mapa los sismos del Servicio Sismológico Nacional y los cruza con datos de población y economía del INEGI.

Artículo de referencia: Villa Vargas, J. M., Hurtado Avilés, G., & Climent Hernández, J. A. (2026). Cuando México tiembla: la historia contada por los datos. *AZCATL Revista de Divulgación de la Ciencia, la Ingeniería y la Innovación, 4*(6), 28-33. https://doi.org/10.24275/AZC2026E1004

## Issues de propuestas de mejora

[COMPLETAR: enlaces a los issues]

