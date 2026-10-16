# Bases de Datos: Renta semanal de vehículos

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

