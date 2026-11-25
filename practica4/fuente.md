# Fuente de datos — renta semanal de vehículos

## 1. Origen y búsqueda

**Datos realmente utilizados:** catálogo de marcas y modelos de vehículos de la API vPIC de la National Highway Traffic Safety Administration (NHTSA), organismo del Departamento de Transporte de Estados Unidos.

- API: https://vpic.nhtsa.dot.gov/api/
- Endpoint: `https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/{marca}?format=json`
- Ocho solicitudes descargadas: Chevrolet, Honda, Hyundai, Kia, Mazda, Nissan, Toyota y Volkswagen.
- Archivos originales preservados sin modificar: `practica4/datos/vpic_*.json`.

**Referencia APA 7 (provisional, revisar fecha exacta de extracción):**

National Highway Traffic Safety Administration. (s. f.). *Vehicle Product Information Catalog (vPIC): API for vehicle models* [Conjunto de datos]. U.S. Department of Transportation. https://vpic.nhtsa.dot.gov/api/

**Licencia y condiciones de reutilización:** PENDIENTE DE VERIFICAR en la documentación oficial de vPIC. No se afirma una licencia específica sin una fuente comprobada. Antes de la entrega definitiva, registrar el texto/URL del aviso y qué permite hacer con los datos.

### Bitácora de búsqueda (completar con evidencia real)

| Lugar | Consulta o criterio | Resultado y decisión |
|---|---|---|
| NHTSA vPIC API | `GetModelsForMake/{marca}?format=json` | Se descargaron ocho catálogos con marcas/modelos y se conservaron los originales; fuente utilizada. |
| datos.gob.mx | **Pendiente de documentar búsqueda real** | No afirmar resultados sin registrar URL, fecha y filtros. |
| Portal de Datos Abiertos de CDMX | **Pendiente de documentar búsqueda real** | No afirmar resultados sin registrar URL, fecha y filtros. |
| INEGI / DENUE | **Pendiente de documentar búsqueda real** | Evaluar qué datos sirven para el caso y registrar evidencia. |

La base de renta semanal de vehículos de este proyecto es un caso de estudio. Los datos de clientes, personal, contratos, pagos, revisiones y reparaciones representan operaciones internas y, en el caso de datos personales, no deben publicarse sin anonimizar. La solución propuesta es generar registros **sintéticos** mediante un script, después de cerrar y justificar la búsqueda de conjuntos publicados.

## 2. Formato, tamaño y campos

La información de vPIC está en JSON, un archivo por marca, sin credenciales. Cada archivo contiene las propiedades superiores `Count`, `Message`, `SearchCriteria` y `Results`. Cada registro de `Results` tiene `Make_ID`, `Make_Name`, `Model_ID` y `Model_Name`.

| Marca | Registros en archivo | Bytes |
|---|---:|---:|
| Chevrolet | 124 | 10,088 |
| Honda | 362 | 28,675 |
| Hyundai | 40 | 3,304 |
| Kia | 27 | 2,069 |
| Mazda | 28 | 2,145 |
| Nissan | 44 | 3,441 |
| Toyota | 58 | 4,560 |
| Volkswagen | 40 | 3,323 |
| **Total** | **723** | **57,605** |

*Conteos: comprobados leyendo los ocho JSON confirmados en GitHub. Tamaños: metadatos del repositorio.*

## 3. Correspondencia con el esquema

| Campo de la fuente | Destino | Transformación o razón para omitirlo |
|---|---|---|
| `Make_Name` | `modelo.marca` | Se recorta espacio y aplica formato de mayúscula inicial. |
| `Model_Name` | `modelo.nombre` | Se recorta espacio; solo se cargan modelos seleccionados. |
| `Make_ID` | No se utiliza | ID externo; `modelo.id_modelo` es una clave interna `SERIAL`. |
| `Model_ID` | No se utiliza | ID externo; la base usa su identificador interno. |
| `Count` | No se almacena | Metadato de la respuesta para verificación de cantidad. |
| `Message` | No se almacena | Metadato del resultado de API. |
| `SearchCriteria` | No se almacena | Describe el criterio de búsqueda, no una columna de modelo. |
| *No viene en vPIC* | `modelo.litros_motor` | Se consulta el [catálogo mexicano de motores](motores-mx.md); 68 valores de referencia y cinco desconocidos (NULL). |

## 4. Limpieza, problemas y decisiones

| Problema observado | Decisión |
|---|---|
| El catálogo incluye motocicletas, todoterreno y vehículos distintos de los autos de alquiler propuestos (en especial Honda). | Conservar todos los JSON crudos; filtrar por lista explícita de modelos elegidos en `10-modelo.sql`. |
| Algunos nombres no corresponden a los autos previstos o tienen denominaciones distintas. | Solo cargar coincidencias exactas sin distinguir mayúsculas/minúsculas. |
| El catálogo no informa la cilindrada. | La fórmula sintética de la primera carga fue sustituida por referencias mexicanas; se conserva el dato original de marca/modelo y el identificador. Consultar [motores-mx.md](motores-mx.md). |
| Son catálogos de NHTSA, no catálogos específicos de comercialización en México. | Documentar el recorte del caso y no afirmar que todos los modelos se ofrecen en México. |
| La fuente contiene más registros que la lista seleccionada. | De 723 registros, 73 coinciden con la lista del script y 650 no coinciden; comprobación sobre los JSON descargados. |

### Resultado del filtro actualmente versionado

| Marca | Registros aceptados |
|---|---:|
| Chevrolet | 12 |
| Honda | 9 |
| Hyundai | 8 |
| Kia | 12 |
| Mazda | 6 |
| Nissan | 9 |
| Toyota | 10 |
| Volkswagen | 7 |
| **Total** | **73** |

La primera carga y su repetición se comprobaron con las [evidencias](evidencias/). La migración 002 y la carga de corrección se comprobaron el 24 de noviembre de 2026: 62 cilindradas actualizadas, cero inserciones adicionales y 73 modelos conservados (68 con valor y 5 desconocidos). Ver [catálogo de motores](motores-mx.md).

## 5. Datos sintéticos y carga

**Plan de tablas con registros sintéticos:** `cliente`, `cliente_telefono`, `empleado`, `mecanico`, `administrativo`, `vehiculo`, `contrato`, `pago_semanal`, `revision`, `inspeccion`, `refaccion` y `reparacion`.

Se deberá declarar en el README qué tablas y campos son sintéticos; el script debe respetar claves únicas, relaciones entre tablas, restricciones de dominio y el criterio de al menos 200 renglones por **tabla principal** cuando corresponda según la rúbrica. La carga se entregará mediante un solo comando, con transacción, cuentas por tabla y prueba de idempotencia. Los rechazos y ajustes por restricciones requieren evidencia de ejecución.

### Pendientes antes de considerar terminado el ejercicio 1.3

1. Registrar fecha exacta de consulta de vPIC.
2. Verificar licencia/condiciones oficiales de la fuente.
3. Documentar consultas realmente realizadas en portales alternativos y por qué se optó por datos sintéticos.
4. Añadir las evidencias reales de la carga y limpieza y, cuando corresponda, las filas rechazadas por restricciones.
