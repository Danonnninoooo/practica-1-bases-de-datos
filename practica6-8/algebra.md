# Álgebra relacional — Semanal Autos (prácticas 6, 7 y 8)

## Alcance y datos

Se cubren las familias de operadores solicitadas por el documento del segundo parcial. El grupo de RelaX se genera a partir de la base real de demostración mediante [exportar-relax.sql](exportar-relax.sql). Contiene proyecciones de las tablas, sin datos personales. Se omite litros_motor en el grupo para que los cinco valores desconocidos no afecten la comparación clásica de conjuntos; el catálogo completo permanece en PostgreSQL.

Las relaciones usadas son vehiculo(vin,color,anio,id_modelo), modelo(id_modelo,marca,nombre), contrato(id_contrato,estado), pago_semanal(id_contrato,num_semana) y semanas(num_semana), esta última una relación auxiliar con 1,2,3,4. No altera el esquema físico.

## Ejercicios

### 01. Selección

**Pregunta:** Vehículos blancos.

**RelaX:**

```text
σ color = 'Blanco' (vehiculo)
```

**PostgreSQL:**

```sql
SELECT vin,color,anio,id_modelo FROM vehiculo WHERE color='Blanco';
```

### 02. Proyección

**Pregunta:** Marcas distintas del catálogo.

**RelaX:**

```text
π marca (modelo)
```

**PostgreSQL:**

```sql
SELECT DISTINCT marca FROM modelo;
```

### 03. Unión

**Pregunta:** VIN de vehículos blancos o del año 2020.

**RelaX:**

```text
(π vin (σ color = 'Blanco' (vehiculo))) ∪ (π vin (σ anio = 2020 (vehiculo)))
```

**PostgreSQL:**

```sql
SELECT vin FROM vehiculo WHERE color='Blanco' UNION SELECT vin FROM vehiculo WHERE anio=2020;
```

### 04. Intersección

**Pregunta:** VIN de vehículos blancos y del año 2020.

**RelaX:**

```text
(π vin (σ color = 'Blanco' (vehiculo))) ∩ (π vin (σ anio = 2020 (vehiculo)))
```

**PostgreSQL:**

```sql
SELECT vin FROM vehiculo WHERE color='Blanco' INTERSECT SELECT vin FROM vehiculo WHERE anio=2020;
```

### 05. Diferencia

**Pregunta:** VIN de vehículos blancos que no son del año 2020.

**RelaX:**

```text
(π vin (σ color = 'Blanco' (vehiculo))) - (π vin (σ anio = 2020 (vehiculo)))
```

**PostgreSQL:**

```sql
SELECT vin FROM vehiculo WHERE color='Blanco' EXCEPT SELECT vin FROM vehiculo WHERE anio=2020;
```

### 06. Producto cartesiano

**Pregunta:** Combinaciones de estados de contrato y cuatro semanas de referencia (no representa pagos reales).

**RelaX:**

```text
(π estado (contrato)) × semanas
```

**PostgreSQL:**

```sql
SELECT DISTINCT c.estado,s.num_semana FROM contrato c CROSS JOIN (VALUES (1),(2),(3),(4)) AS s(num_semana);
```

### 07. Reunión natural y selección

**Pregunta:** Marca y modelo del vehículo de prueba TEST0000000000001. Las relaciones exportadas comparten únicamente id_modelo.

**RelaX:**

```text
π vin, marca, nombre (σ vin = 'TEST0000000000001' (vehiculo ⋈ modelo))
```

**PostgreSQL:**

```sql
SELECT v.vin,m.marca,m.nombre FROM vehiculo v JOIN modelo m ON v.id_modelo=m.id_modelo WHERE v.vin='TEST0000000000001';
```

### 08. Agrupación

**Pregunta:** Cantidad de vehículos por color.

**RelaX:**

```text
γ color; count(*)->cantidad (vehiculo)
```

**PostgreSQL:**

```sql
SELECT color,COUNT(*) AS cantidad FROM vehiculo GROUP BY color;
```

### 09. División

**Pregunta:** Contratos que tienen pagos registrados en todas las semanas 1 a 4. No implica que se hayan cubierto todos los pagos futuros.

**RelaX:**

```text
(π id_contrato,num_semana (pago_semanal)) ÷ semanas
```

**PostgreSQL:**

```sql
SELECT DISTINCT p.id_contrato FROM pago_semanal p WHERE NOT EXISTS (SELECT 1 FROM (VALUES (1),(2),(3),(4)) AS s(num_semana) WHERE NOT EXISTS (SELECT 1 FROM pago_semanal q WHERE q.id_contrato=p.id_contrato AND q.num_semana=s.num_semana));
```

## Ejecución y comparación

1. En CMD, desde la raíz del repositorio, exportar los resultados SQL completos:

```cmd
docker exec -i pg-curso psql -U usuario_consulta_renta -d practica45 -X -v ON_ERROR_STOP=1 -P pager=off < practica6-8\consultas.sql > practica6-8\resultados-sql.txt 2>&1
```

2. Generar el grupo de RelaX (no contiene datos de clientes):

```cmd
docker exec -i pg-curso psql -U usuario_consulta_renta -d practica45 -X -qAt -v ON_ERROR_STOP=1 < practica6-8\exportar-relax.sql > practica6-8\grupo-relax.txt
```

3. Abrir https://dbis-uibk.github.io/relax/ y entrar en Group Editor. Copiar el contenido de grupo-relax.txt, pulsar Preview y después usar el grupo en el editor (los nombres de botones pueden variar según la versión).
4. En la pestaña de álgebra relacional, pegar una expresión de arriba y ejecutarla. Comparar conjuntos de resultados con resultados-sql.txt (el orden no forma parte del álgebra relacional). La consulta 07 es la elegida para la exposición, porque reúne vehículo y modelo y devuelve una fila identificable. Guardar capturas de SQL y RelaX.

### Cardinalidades previstas antes de la ejecución

Con la carga observada: 01 = 60; 02 = 8; 03 = 86; 04 = 9; 05 = 51; 06 = 8; 07 = 1; 08 = 4 (60 por color); 09 = 240. Estos son cálculos sobre el generador y la carga previa, no evidencias de ejecución. Si cambia la base, deben recalcularse. La salida final del archivo SQL imprime las cardinalidades observadas.

Referencia de sintaxis: [ayuda de RelaX](https://relax.labs.schubotz.org/relax/help) y [documentación del proyecto](https://github.com/dbis-uibk/relax). Las expresiones todavía deben probarse en el editor.

## Ejecución SQL observada — 24 de noviembre de 2026

La captura de la ejecución en PostgreSQL 16 muestra el resumen de cardinalidades 01=60, 02=8, 03=86, 04=9, 05=51, 06=8, 07=1, 08=4 y 09=240, seguido de COMMIT. Las nueve consultas terminaron. El archivo [resultados-sql.txt](resultados-sql.txt), el [grupo de RelaX](grupo-relax.txt) y las once capturas se subieron en el commit `4d51d56`. Las capturas permiten comprobar las cardinalidades y, para el ejercicio 07, la totalidad de su única fila.

## Comparación observada de SQL y RelaX

| Ejercicio | SQL | RelaX | Evidencia |
|---|---:|---:|---|
| 01 Selección | 60 | 60 | [Captura](evidencias/12-relax-seleccion.png) |
| 02 Proyección | 8 | 8 | [Captura](evidencias/16-relax-proyeccion.png) |
| 03 Unión | 86 | 86 | [Captura](evidencias/17-relax-union.png) |
| 04 Intersección | 9 | 9 | [Captura](evidencias/18-relax-interseccion.png) |
| 05 Diferencia | 51 | 51 | [Captura](evidencias/15-relax-diferencia.png) |
| 06 Producto | 8 | 8 | [Captura](evidencias/19-relax-producto-cartesiano.png) |
| 07 Reunión | 1 | 1 | [RelaX](evidencias/13-relax-join.png) · [SQL](evidencias/14-comparacion-sql-relax.png) |
| 08 Agrupación | 4 | 4 | [Captura](evidencias/20-relax-agrupacion.png) |
| 09 División | 240 | 240 | [Captura](evidencias/21-relax-division.png) |

El ejercicio 07 produce el VIN TEST0000000000001, Chevrolet, Aveo en ambos sistemas. Su árbol une 240 vehículos y 73 modelos por id_modelo (240 filas), selecciona un VIN (1 fila) y proyecta tres atributos (1 fila). La agrupación también muestra cuatro colores con 60 vehículos cada uno. Las capturas de consultas extensas muestran cardinalidades iguales, no una comparación automatizada de cada tupla. En la diferencia se corrigió el signo a guion ASCII (-).
