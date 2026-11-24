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

Consulta 01 observada el 24 de noviembre de 2026: 10 filas de 2017, 11 ms mostrados por la interfaz (no constituye un benchmark). Pendiente: adjuntar evidencia 30, ejecutar las consultas 02 y 03, comparar sus resultados, exportar una proyección de la misma selección a RelaX y publicar el fork propio. Los 10 registros no equivalen necesariamente a diez eventos físicos distintos; el almacén anterior también utilizaba otra cobertura y un JOIN con una tabla de hechos. Los resultados dependerán de los filtros de la instantánea, no del total inicial de registros. Las evidencias del sistema anterior PHP/PostgreSQL se conservan en consultas.md; no son evidencias del nuevo SQLite.

Evidencias de montaje por adjuntar: 27-sismos-version-publicada.png, 28-sismos-fork-actualizado.png y 29-sismos-observatorio-local.png.
