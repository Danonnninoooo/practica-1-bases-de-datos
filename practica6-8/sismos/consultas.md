# Sismos — tres consultas del backend y árboles de operadores

Fuente del esquema: [sql/00-datawarehouse_tables.sql](https://github.com/Danonnninoooo/Seismic-Data-Visualization-System/blob/main/sql/00-datawarehouse_tables.sql). PostgreSQL 17, base datawarehouse, cuatro dimensiones y una tabla de hechos. Proyecto asignado: [fork](https://github.com/Danonnninoooo/Seismic-Data-Visualization-System).

Estas consultas se adaptaron del código del fork; no son consultas inventadas sin relación con la aplicación. Se ejecutan en modo de solo lectura. El archivo [consultas.sql](consultas.sql) incluye el inventario y las tres consultas. Los resultados SQL se comprobaron en el contenedor del estudiante el 24 de noviembre de 2026.

## 1. Zonas pobladas

Fuente: [src/sismo.php, líneas 86–92](https://github.com/Danonnninoooo/Seismic-Data-Visualization-System/blob/main/src/sismo.php#L86-L92).

Pregunta: ¿qué entidades tienen más de 50 000 habitantes, y cuál es su población total?

Álgebra relacional: `π pobtot, nom_ent (σ pobtot > 50000 (dim_zonas))`.

```text
π pobtot, nom_ent       [proyección: operador principal]
        |
σ pobtot > 50000        [selección]
        |
dim_zonas
```

SQL:

```sql
SELECT DISTINCT pobtot,nom_ent
FROM dim_zonas WHERE pobtot > 50000 ORDER BY nom_ent,pobtot;
```

DISTINCT reproduce la semántica de conjuntos; ORDER BY solo facilita la lectura.

## 2. Sismos de magnitud 6 o superior durante 2017

Fuente: [src/datos_sismicos.php, líneas 120–150](https://github.com/Danonnninoooo/Seismic-Data-Visualization-System/blob/main/src/datos_sismicos.php#L120-L150). Se fijan los filtros de fecha y magnitud y se proyectan cuatro atributos, sin alterar las relaciones del backend. La reunión usa las llaves foráneas de la tabla de hechos, no presupone que id_sismo e id_tiempo sean iguales.

Pregunta: ¿qué eventos de magnitud 6 o superior se registraron en 2017, en qué fecha y con qué profundidad?

Expresión (notación matemática, no necesariamente sintaxis literal de RelaX):

`π id_sismo, magnitud, fecha, profundidad (σ magnitud >= 6 AND fecha >= 2017-01-01 AND fecha <= 2017-12-31 ((dim_sismos ⋈ fact_impacto_sismos_imputed) ⋈ dim_tiempo))`.

Las reuniones naturales son equivalentes a las condiciones de igualdad de las llaves en el esquema consultado. El operador principal del árbol es la proyección, y la reunión es la operación central de integración.

```text
π id_sismo, magnitud, fecha, profundidad
                    |
σ magnitud >= 6 y fecha dentro de 2017
                    |
          ⋈ por id_tiempo
          /              \
    ⋈ por id_sismo       dim_tiempo
    /          \
dim_sismos    fact_impacto_sismos_imputed
```

```sql
SELECT DISTINCT s.id_sismo,s.magnitud,t.fecha,s.profundidad
FROM dim_sismos s
JOIN fact_impacto_sismos_imputed f ON s.id_sismo=f.id_sismo
JOIN dim_tiempo t ON f.id_tiempo=t.id_tiempo
WHERE s.magnitud >= 6
  AND t.fecha BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
ORDER BY t.fecha,s.id_sismo,s.magnitud,s.profundidad;
```

DISTINCT elimina posibles repeticiones de la proyección. No se interpreta la magnitud como una medición de daños.

## 3. Producción económica por entidad

Fuente: [src/aeconomica.php, líneas 59–64](https://github.com/Danonnninoooo/Seismic-Data-Visualization-System/blob/main/src/aeconomica.php#L59-L64).

Pregunta: ¿qué suma de producción bruta total reporta la dimensión económica por entidad?

Álgebra relacional extendida: `γ nombre_entidad; sum(produccion_bruta_total)->total_produccion (σ nombre_entidad IS NOT NULL (dim_economia))`.

```text
γ nombre_entidad; SUM(produccion_bruta_total)
                   |
σ nombre_entidad IS NOT NULL
                   |
dim_economia
```

Operador principal: agrupación. No confundir producción económica con pérdidas sísmicas. Los valores son los del conjunto original, sin convertir unidades no documentadas.

```sql
SELECT nombre_entidad,SUM(produccion_bruta_total) AS total_produccion
FROM dim_economia WHERE nombre_entidad IS NOT NULL
GROUP BY nombre_entidad ORDER BY nombre_entidad;
```

Para la comparación con RelaX se comprobarán los valores nulos y la precisión numérica. Si se usa un subconjunto exportado, se documentará su alcance y se ejecutará el SQL sobre el mismo subconjunto.

## Ejecución y evidencias

Desde CMD, en la raíz del repositorio principal:

```cmd
docker exec -i seismic-data-visualization-system-db-1 psql -U postgres -d datawarehouse -X -v ON_ERROR_STOP=1 -P pager=off < practica6-8\sismos\consultas.sql > practica6-8\sismos\resultados-sql.txt 2>&1
```

El nombre del contenedor corresponde al montaje observado anteriormente. Si cambia, consultar docker ps. Se mantienen separados los contenedores de Semanal Autos y Sismos. Pendiente verificar montaje de la web, exportación a RelaX y versión publicada.

## Resultados SQL observados — 24 de noviembre de 2026

PostgreSQL 17.11, base datawarehouse; COMMIT final sin errores.

| Tabla | Filas |
|---|---:|
| dim_economia | 32 |
| dim_zonas | 32 |
| dim_sismos | 319592 |
| dim_tiempo | 319592 |
| fact_impacto_sismos_imputed | 196576 |

Consultas 01, 02 y 03: 32, 2 y 32 filas, respectivamente. La consulta 02 devolvió (94787, 7.1, 2017-09-19, 51.2) y (95584, 6.1, 2017-09-23, 10). No se afirma que estos sean todos los eventos del SSN: el resultado se restringe a los pares asociados por la tabla de hechos del almacén. La dimensión económica reportó cero nombres nulos y cero valores de producción nulos.

Evidencias locales por adjuntar: `evidencias/22-sismos-inventario-consultas.png`, `evidencias/23-sismos-resultados-sql.png` y `resultados-sql.txt`.

## Comparación con RelaX

El [exportador](exportar-relax.sql) conserva las 32 filas de cada dimensión de zonas y economía (proyectando los atributos necesarios e incluyendo sus claves). Para sismos se exportan todos los pares distintos sismo-tiempo que cumplen la consulta 02, hasta 20 pares de 2017 con magnitud menor que 6 y hasta 5 pares de otros años con magnitud mayor o igual que 6. Se exportan sus dimensiones referenciadas. Esta muestra incluye el resultado completo de la consulta 02 en el momento de exportación y controles negativos para ambos filtros, pero no representa todo el almacén; los nodos intermedios del árbol pueden tener otras cardinalidades.

La fecha se exporta como texto ISO y anio como año numérico calculado a partir de fecha. El filtro anio=2017 equivale al intervalo de fechas SQL. Las claves de economía y zonas se conservan para no colapsar filas en el grupo. La selección de nombres no nulos de la consulta 03 se puede omitir en RelaX porque la ejecución comprobó cero nombres nulos; si cambian los datos, revisar esa equivalencia. Las sumas de punto flotante deben compararse con tolerancia numérica.

En CMD:

```cmd
docker exec -i seismic-data-visualization-system-db-1 psql -U postgres -d datawarehouse -X -qAt -v ON_ERROR_STOP=1 < practica6-8\sismos\exportar-relax.sql > practica6-8\sismos\grupo-relax.txt
```

Expresiones para el grupo Sismos (pendientes de ejecutar):

```text
π pobtot, nom_ent (σ pobtot > 50000 (dim_zonas))
π id_sismo, magnitud, fecha, profundidad (σ magnitud >= 6 ∧ anio = 2017 ((dim_sismos ⋈ fact_impacto_sismos_imputed) ⋈ dim_tiempo))
γ nombre_entidad; sum(produccion_bruta_total)->total_produccion (dim_economia)
```

Se esperan 32, 2 y 32 filas. Ejecutar cada expresión por separado y comparar con el SQL.
