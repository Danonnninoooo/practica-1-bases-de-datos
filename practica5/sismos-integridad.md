# Integridad referencial del almacén Sismos — ejercicio 2.5

Fuente: [DDL del almacén PostgreSQL](https://github.com/Danonnninoooo/Seismic-Data-Visualization-System/blob/main/sql/00-datawarehouse_tables.sql). Esta revisión corresponde al almacén PHP/PostgreSQL del primer fork, no a SQLite del observatorio R3.

La tabla de hechos fact_impacto_sismos_imputed contiene referencias a dim_sismos (id_sismo), dim_zonas (id_zonas), dim_economia (id_economia) y dim_tiempo (id_tiempo). Un renglón representa una observación de impacto/riesgo asociada a esas dimensiones, con medidas de población afectada, impacto económico y riesgo. El DDL no declara PK ni UNIQUE en hechos; la unicidad de la combinación de cuatro claves es una hipótesis que se comprueba, no una garantía. Las referencias de hechos admiten NULL según el DDL. Una FK con NULL no constituye por sí sola una violación de integridad, pero puede dejar incompleta una observación analítica.

El esquema declara las cuatro FK sin acciones explícitas (NO ACTION por defecto). El script [05-integridad-sismos.sql](sql/05-integridad-sismos.sql) verifica la instalación, huérfanos, nulos y duplicados de claves; distingue combinaciones repetidas de filas exactamente iguales. Las medidas nulas se informan sin asumir que sean infracciones.

Un almacén puede omitir FK para acelerar cargas masivas o manejar dimensiones tardías; el costo es el riesgo de hechos sin correspondencia y resultados incorrectos en reuniones. Si las cuatro FK están instaladas y validadas no es necesario agregarlas en copia. Si falta alguna, deberá probarse en una copia aislada. Resultados de ejecución pendientes.
