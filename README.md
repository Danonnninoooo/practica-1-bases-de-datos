# Bases de Datos: Renta semanal de vehículos

Instituto Politécnico Nacional, Escuela Superior de Cómputo
Ingeniería en Sistemas Computacionales, Plan 2020 | Grupo 3CV4
Profesor: Gabriel Hurtado Avilés

## Enlaces principales

| Elemento | Dirección |
|---|---|
| Landing page (GitHub Pages) | [COMPLETAR cuando exista] |
| Proyecto asignado: Sismos (fork) | [COMPLETAR] |
| Versión publicada de Sismos | [COMPLETAR] |
| Commit con el que se levantó Sismos | [COMPLETAR] |
| Presentación (PDF) | [COMPLETAR: exposicion/presentacion.pdf] |

## Integrantes

| Integrante | Usuario GitHub | Participación |
|---|---|---|
| Daniel Patiño Farias | Danonnninoooo | Modelo EER, esquema.sql, pruebas de restricciones, diagrama relacional, diccionario de datos, transformación, proyecto asignado (Sismos) |
| Arath Sebastian Sanchez Valenzuela | Zuzuuuu2729 | Revisión y fusión de Pull Requests [COMPLETAR si hizo algo más] |
| Alejandro Rivas Ramirez | [sin usuario en el repositorio] | [COMPLETAR] |

## Proyecto propio

Sistema de renta semanal de autos compactos (March, Versa) con revisión semanal para detectar reparaciones hechas fuera de la empresa.

## Gestor utilizado

PostgreSQL 16 en contenedor Docker, configurado en [entorno/compose.yaml](entorno/compose.yaml).

## Práctica 3: índice

- [esquema.sql](practica3/sql/esquema.sql)
- [pruebas-de-restricciones.sql](practica3/sql/pruebas-de-restricciones.sql)
- [Diagrama relacional](practica3/proyecto-propio/diagrama-relacional.png)
- [Diccionario de datos](practica3/proyecto-propio/diccionario-de-datos.pdf)
- [Inventario, transformación y preservación del significado](practica3/proyecto-propio/Transformacion.pdf)
- [Evidencias](practica3/evidencias)
- Ejercicios 7 y 8 (esquema de Sismos y cambio individual): [COMPLETAR o indicar "pendiente"]

## Cambios al modelo respecto a la Práctica 1

- Se eliminó EMPRESA (una sola fila, sin sucursales).
- La relación renta pasó a ser la entidad CONTRATO para conservar historial.
- Los subtipos Visual, Mecánica y Fuerza pasaron a la entidad débil INSPECCION.
- Marca, nombre y litros del motor pasaron a MODELO.
- Se agregó la jerarquía EMPLEADO (mecánico / administrativo) y la ternaria reparación.

## Issues de propuestas de mejora

[COMPLETAR: enlaces a los issues]

## Uso de inteligencia artificial generativa

Se utilizó Claude (Anthropic) como apoyo para: proponer y revisar el modelo EER, redactar el borrador de esquema.sql y del diccionario de datos, y guiar el uso de Git y Docker. Las decisiones de diseño fueron revisadas y ejecutadas por el equipo.

## Bibliografía

Kossmann, J., Papenbrock, T., & Naumann, F. (2022). Data dependencies for query optimization: A survey. *The VLDB Journal, 31*, 1-22. https://doi.org/10.1007/s00778-021-00676-3

Lan, H., Bao, Z., & Peng, Y. (2021). A survey on advancing the DBMS query optimizer: Cardinality estimation, cost model, and plan enumeration. *Data Science and Engineering, 6*, 86-101. https://doi.org/10.1007/s41019-020-00149-7

Perera, R. M., Oetomo, B., Rubinstein, B. I. P., & Borovica-Gajic, R. (2021). DBA bandits: Self-driving index tuning under ad-hoc, analytical workloads with safety guarantees. *2021 IEEE 37th International Conference on Data Engineering (ICDE)*, 600-611. https://doi.org/10.1109/ICDE51399.2021.00058