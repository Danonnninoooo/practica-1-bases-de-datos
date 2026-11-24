# Normalización — Semanal Autos (prácticas integradas 6, 7 y 8)

## Alcance

Este análisis parte del esquema de la práctica 3 y de las migraciones 001 y 002 de la práctica 4. Presenta la decisión de normalización para la exposición del segundo parcial. Se sigue el alcance indicado en el documento del segundo parcial.

## 1. Relación inicial y reglas de negocio

Una alternativa no normalizada en cuanto a dependencias sería almacenar todos los datos del modelo junto con cada vehículo:

`VEHICULO_AMPLIADO(vin, color, anio, id_modelo, marca, nombre, litros_motor)`.

Un VIN identifica una unidad física; un modelo puede corresponder a muchos vehículos. El esquema declara UNIQUE NULLS NOT DISTINCT(marca, nombre, litros_motor). Marca y nombre son obligatorios; litros_motor puede ser NULL si no se confirmó una referencia mexicana. Para el análisis formal clásico se considera el subconjunto de modelos con cilindrada conocida, donde los tres atributos tienen valores definidos.

Dependencias funcionales relevantes (F):

- vin → color, anio, id_modelo
- id_modelo → marca, nombre, litros_motor
- (marca, nombre, litros_motor) → id_modelo

No se supone que la marca y el nombre solos determinen los litros. Tampoco se supone que un modelo determine un VIN.

## 2. Claves candidatas

El cierre de vin bajo F es el conjunto completo de atributos: por la primera dependencia obtiene los datos del vehículo y, mediante id_modelo, los del modelo. Como vin no aparece en el lado derecho de ninguna dependencia no trivial de F, toda superclave debe incluirlo. Por tanto, la única clave candidata de VEHICULO_AMPLIADO bajo F es {vin}.

## 3. Primera, segunda y tercera formas normales

- **1FN:** cada atributo del esquema propuesto contiene un valor atómico de su dominio, no listas ni grupos repetidos; un vehículo ocupa un renglón.
- **2FN:** la clave candidata tiene un solo atributo; no existen dependencias parciales respecto a una parte propia de la clave.
- **3FN:** no se cumple en la relación ampliada: id_modelo determina marca, nombre y litros_motor sin ser superclave, y esos atributos no son primos (no forman parte de una clave candidata de la relación ampliada). Hay dependencia transitiva vin → id_modelo → datos del modelo. Se repetiría la información de cada modelo en todos sus vehículos.

Se descompone en las tablas que ya existen:

| Relación | Atributos | Claves candidatas |
|---|---|---|
| vehiculo | vin, color, anio, id_modelo | {vin} |
| modelo | id_modelo, marca, nombre, litros_motor | {id_modelo}; {marca, nombre, litros_motor} solo en el subconjunto con cilindrada conocida |

vehiculo.id_modelo es una clave foránea no nula que referencia modelo.id_modelo. Se puede insertar un modelo sin vehículos, modificar su descripción en un solo renglón y evitar perder el modelo al eliminar su último vehículo.

## 4. Comprobación de FNBC

La forma normal de Boyce-Codd exige que, para cada dependencia funcional no trivial X → Y, X sea superclave.

- En vehiculo, vin es clave y determina color, anio e id_modelo.
- En modelo, id_modelo es la clave primaria. En el subconjunto con cilindrada conocida, (marca, nombre, litros_motor) es también una clave candidata; ambas determinan los restantes atributos. En SQL el UNIQUE NULLS NOT DISTINCT impide duplicados con NULL, pero no convierte una columna anulable en clave candidata clásica.

Bajo las dependencias declaradas, ambas relaciones cumplen FNBC y, por consiguiente, 3FN en el análisis relacional clásico de datos completos. La conclusión se limita a estas dos tablas; no es una afirmación global sobre las trece tablas.

La intersección es {id_modelo}, que determina todos los atributos de modelo. Por el criterio de descomposición binaria, la reunión no pierde información ni genera combinaciones espurias de una instancia válida de la relación ampliada. Las dependencias de F quedan preservadas en las relaciones separadas.

## 5. Demostración SQL

La reunión recupera la información de cada vehículo con su modelo:

```sql
SELECT v.vin, v.color, v.anio, m.marca, m.nombre, m.litros_motor
FROM vehiculo AS v
JOIN modelo AS m ON v.id_modelo = m.id_modelo
ORDER BY v.vin
LIMIT 10;
```

La comprobación de cardinalidad compara el número de vehículos con el número de filas de la reunión completa:

```sql
SELECT
  (SELECT COUNT(*) FROM vehiculo) AS vehiculos,
  (SELECT COUNT(*) FROM vehiculo v JOIN modelo m
    ON v.id_modelo = m.id_modelo) AS filas_reunion;
```

Se esperan 240 y 240 según la carga comprobada de la práctica 4. Falta ejecutar estas consultas y guardar sus resultados; la cifra no se presenta como una ejecución de este archivo.

## 6. Decisión para la exposición

Explicar la diferencia entre un vehículo individual identificado por VIN y el catálogo de modelos compartido, mostrar las dependencias, justificar la separación y demostrar la recuperación de los datos con JOIN. Es un ejemplo del propio proyecto, no una modificación del esquema físico.
