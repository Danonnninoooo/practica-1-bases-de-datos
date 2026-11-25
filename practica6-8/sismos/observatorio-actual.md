# Observatorio actualizado — segundo parcial

## Versiones y montaje

- [Fork propio](https://github.com/Danonnninoooo/Seismic_Data_Geosciences), derivado de [repositorio original](https://github.com/gabrielhuav/Seismic_Data_Geosciences).
- [Versión pública original](https://gabrielhuav.github.io/Seismic_Data_Geosciences/).
- Montaje local comprobado el 24 de noviembre de 2026: http://localhost:8787/; versión visible 2026.11.18.1, cuatro catálogos y 287936 registros fuente (no necesariamente eventos físicos distintos).
- Publicación del fork propio pendiente de verificación.

En CMD, desde una carpeta externa al repositorio de Semanal Autos:

```cmd
git clone --depth 1 --filter=blob:none --sparse https://github.com/Danonnninoooo/Seismic_Data_Geosciences.git
cd Seismic_Data_Geosciences
git sparse-checkout set system/dist
python --version
python -m http.server 8787 --bind 127.0.0.1 --directory system/dist
```

Mantener la terminal del servidor abierta. No se necesita PostgreSQL ni Docker para esta versión. Python sirve los archivos; sql.js ejecuta SQLite en memoria dentro del navegador. La aplicación verifica los catálogos empaquetados y no consulta datos sísmicos en vivo. El explorador SQL crea una instantánea de la selección activa, de solo lectura.

| Catálogo | Registros observados en inicio |
|---|---:|
| SSN México | 242288 |
| USGS México | 24994 |
| USGS Norteamérica | 14041 |
| NRCan Canadá | 6613 |

## Tres consultas de la versión actual

Base de las consultas: [ejemplos SQL del código del fork](https://github.com/Danonnninoooo/Seismic_Data_Geosciences/blob/main/system/dist/sql-panel.js#L92-L97) y [esquema de SQLite](https://github.com/Danonnninoooo/Seismic_Data_Geosciences/blob/main/system/dist/sql-explorer.js). Adaptamos las consultas de inspección, catálogo y años. Mantener activa la selección de los cuatro catálogos, sin agrupación de copias exactas y sin restricciones adicionales. La captura de la primera consulta muestra 10 filas y una selección amplia (el grupo guiado SSN muestra 242288 registros). Para evitar cambiar la instantánea y para que el tercer ejercicio sea reproducible, los filtros de años y magnitud de ese ejercicio se incluyen en su SQL. Los ejercicios 01 y 02 ya filtran explícitamente por 2017 y magnitud mínima 6. La selección exacta se puede confirmar mediante la exportación JSON de evidencia.

### 1. Selección y proyección

¿Qué registros de magnitud reportada >= 6 en 2017 pertenecen a la selección?

```sql
SELECT DISTINCT record_key, year, mag
FROM records
WHERE year = 2017 AND mag >= 6
ORDER BY record_key;
```

Álgebra: π record_key, year, mag (σ year=2017 ∧ mag>=6 (records)).

Árbol de abajo hacia arriba: records → selección σ → proyección π (operador principal). ORDER BY únicamente facilita la lectura.

### 2. Reunión

¿A qué catálogo y etiqueta corresponden esos registros?

```sql
SELECT DISTINCT r.record_key, c.label
FROM records r JOIN catalogs c ON r.catalogue_id=c.catalogue_id
WHERE r.year=2017 AND r.mag>=6
ORDER BY r.record_key;
```

Álgebra: π record_key, label (σ year=2017 ∧ mag>=6 (R ⋈ C)), con R=π record_key,catalogue_id,year,mag (records) y C=π catalogue_id,label (catalogs). Las proyecciones hacen que la única columna común sea catalogue_id. Árbol: records y catalogs → proyecciones → reunión ⋈ → selección σ → proyección π (raíz). La reunión es el operador de integración. La FK de records apunta al catálogo, no identifica un sismo físico único.

### 3. Agrupación

¿Cuántos registros fuente de magnitud reportada entre 5.9 y 10 contiene la selección por año entre 2017 y 2025?

```sql
SELECT year, COUNT(*) AS cantidad
FROM records
WHERE year BETWEEN 2017 AND 2025 AND mag BETWEEN 5.9 AND 10
GROUP BY year
ORDER BY year;
```

Álgebra extendida: γ year; count(*)->cantidad (σ year>=2017 ∧ year<=2025 ∧ mag>=5.9 ∧ mag<=10 (records)). Árbol: records → selección σ → agrupación γ (operador principal). No se interpreta como tasa sísmica ni como conteo de eventos físicos únicos.

## Evidencias y límites

Consulta 01 observada el 24 de noviembre de 2026: 10 filas de 2017, 11 ms mostrados por la interfaz (no constituye un benchmark). Consultas 02 y 03 observadas: 10 filas (10 ms) y 9 filas (225 ms), respectivamente. Las evidencias 27–35 y los archivos de exportación quedaron subidos en el commit `ee7eeed`; la comparación con RelaX se verificó. Pendiente publicar el fork propio. Los 10 registros no equivalen necesariamente a diez eventos físicos distintos; el almacén anterior también utilizaba otra cobertura y un JOIN con una tabla de hechos. Los resultados dependerán de los filtros de la instantánea, no del total inicial de registros. Las evidencias del sistema anterior PHP/PostgreSQL se conservan en consultas.md; no son evidencias del nuevo SQLite.

Evidencias de montaje adjuntas en evidencias/: 27-sismos-version-publicada.png, 28-sismos-fork-actualizado.png y 29-sismos-observatorio-local.png.


## Resultados SQLite observados

| Consulta | Filas | Tiempo mostrado |
|---|---:|---:|
| 01 Selección/proyección | 10 | 11 ms |
| 02 Reunión | 10 | 10 ms |
| 03 Agrupación | 9 | 225 ms |

La reunión muestra dos filas de NRCan, cuatro de SSN y cuatro de USGS México. La agrupación devuelve los pares año/cantidad (2017,11), (2018,14), (2019,10), (2020,28), (2021,20), (2022,25), (2023,17), (2024,23), (2025,21): 169 registros fuente en total. Los tiempos son observaciones de interfaz, no un ensayo de rendimiento.

## Exportación y comparación con RelaX

Sin cambiar la selección, ejecutar una cuarta consulta de solo lectura para conservar todas las filas que satisfacen al menos uno de los filtros de los tres ejercicios. Se incluye row_no para conservar la identidad de cada fila en la agrupación y se toma la etiqueta de su catálogo. No se exporta el almacén entero.

```sql
SELECT r.row_no, r.record_key, r.catalogue_id, r.year, r.mag, c.label
FROM records r
LEFT JOIN catalogs c ON r.catalogue_id = c.catalogue_id
WHERE (r.year = 2017 AND r.mag >= 6)
   OR (r.year BETWEEN 2017 AND 2025 AND r.mag BETWEEN 5.9 AND 10)
ORDER BY r.row_no;
```

Descargar CSV como `practica6-8/sismos/sqlite-relax.csv`. Desde CMD en la raíz del repositorio ejecutar `python practica6-8\sismos\csv-a-relax.py`. El conversor verifica las cardinalidades y las nueve cantidades anuales contra las capturas SQL. Luego abrir `grupo-relax-actual.txt` e importarlo en el editor de grupos de RelaX. Las relaciones son proyecciones y restricciones del conjunto original; sus cardinalidades intermedias no son las del observatorio completo. No se incorporan controles negativos adicionales. El grupo de catálogos incluye solamente los referenciados por las filas exportadas.

Expresiones ejecutadas en RelaX:

```text
π record_key, year, mag (σ year = 2017 ∧ mag >= 6 (records))
π record_key, label (σ year = 2017 ∧ mag >= 6 (records ⋈ catalogs))
γ year; count(*)->cantidad (σ year >= 2017 ∧ year <= 2025 ∧ mag >= 5.9 ∧ mag <= 10 (records))
```

La única columna compartida por records y catalogs en este grupo es catalogue_id; su reunión natural corresponde al JOIN explícito. Se esperan 10, 10 y 9 filas. El grupo no debe sustituir el conjunto completo para otras consultas.

## Comparación comprobada — 24 de noviembre de 2026

El conversor Python validó 10 filas para selección, 10 para reunión y las nueve cantidades anuales; generó un grupo de 169 registros y cuatro catálogos. Archivos: [CSV](sqlite-relax.csv), [grupo RelaX](grupo-relax-actual.txt).

| Consulta | SQLite | RelaX | Evidencias |
|---|---:|---:|---|
| Selección y proyección | 10 | 10 | [SQLite](evidencias/30-sismos-sqlite-seleccion.png) · [RelaX](evidencias/33-sismos-actual-relax-seleccion.png) |
| Reunión | 10 | 10 | [SQLite](evidencias/31-sismos-sqlite-join.png) · [RelaX](evidencias/34-sismos-actual-relax-join.png) |
| Agrupación | 9 | 9 | [SQLite](evidencias/32-sismos-sqlite-agrupacion.png) · [RelaX](evidencias/35-sismos-actual-relax-agrupacion.png) |

Las capturas muestran cardinalidades iguales y coincidencia de los valores visibles; no muestran todas las tuplas de RelaX. Los árboles usan el grupo reducido: 169 filas de records, cuatro de catalogs y 169 tras su reunión. La selección reduce a diez y la agrupación a nueve. No se comparan los tiempos de ejecución como benchmark.

Montaje: [versión original](evidencias/27-sismos-version-publicada.png), [fork](evidencias/28-sismos-fork-actualizado.png), [local](evidencias/29-sismos-observatorio-local.png). La publicación propia requiere habilitar GitHub Actions y seleccionar GitHub Actions como origen en Settings > Pages; ejecutar el flujo existente Publish seismic explorer. No se modificó ese flujo ni el código original del observatorio.
