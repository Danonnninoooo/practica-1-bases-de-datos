# Fichas de los artículos presentados

## Artículo 1

**Cita (APA 7):**
Kossmann, J., Papenbrock, T., & Naumann, F. (2022). Data dependencies for query optimization: A survey. *The VLDB Journal, 31*, 1-22. https://doi.org/10.1007/s00778-021-00676-3

**Problema:** los optimizadores de consultas podrían aprovechar información sobre los datos (dependencias funcionales, de unicidad, de orden y de inclusión), pero los sistemas actuales la usan poco.

**Propuesta:** una revisión y clasificación de unas 60 técnicas de optimización basadas en dependencias de datos.

**Resultado principal:** una clasificación organizada de esas técnicas y de cómo ayudan a generar planes de ejecución más eficientes; además, problemas abiertos sobre descubrir y mantener las dependencias cuando los datos cambian.

**Qué le aportó a nuestro proyecto:** las restricciones que declaramos (PK, UNIQUE, FK) no solo protegen los datos, también le dan información al optimizador. Por eso en el esquema declaramos los índices únicos parciales de contrato vigente y las claves foráneas.

## Artículo 2

**Cita (APA 7):**
Lan, H., Bao, Z., & Peng, Y. (2021). A survey on advancing the DBMS query optimizer: Cardinality estimation, cost model, and plan enumeration. *Data Science and Engineering, 6*, 86-101. https://doi.org/10.1007/s41019-020-00149-7

**Problema:** los optimizadores basados en costos eligen planes ineficientes por errores en tres piezas: estimar cuántas filas devuelve cada operación, el modelo de costos y el enorme espacio de planes posibles.

**Propuesta:** una revisión de las técnicas para mejorar esos tres componentes, con sus causas y líneas de investigación futura.

**Resultado principal:** la calidad del plan depende mucho de qué tan bien se estima la cardinalidad; si la estimación falla, el optimizador puede elegir un plan malo.

**Qué le aportó a nuestro proyecto:** entender que la forma de las tablas y de las consultas influye en el rendimiento cuando crece la información. Lo aplicamos al pensar la consulta de vehículos sin revisión en los últimos ocho días.

## Artículo 3

**Cita (APA 7):**
Perera, R. M., Oetomo, B., Rubinstein, B. I. P., & Borovica-Gajic, R. (2021). DBA bandits: Self-driving index tuning under ad-hoc, analytical workloads with safety guarantees. *2021 IEEE 37th International Conference on Data Engineering (ICDE)*, 600-611. https://doi.org/10.1109/ICDE51399.2021.00058

**Problema:** elegir y mantener índices suele depender de un administrador que identifica cargas de trabajo representativas, lo cual falla cuando las consultas cambian todo el tiempo.

**Propuesta:** "DBA bandits", un método de selección automática de índices con multi-armed bandits que aprende qué índices funcionan observando el rendimiento real.

**Resultado principal:** hasta 75 % de aceleración en cargas cambiantes y hasta 28 % en cargas estáticas frente a una herramienta comercial de ajuste.

**Qué le aportó a nuestro proyecto:** una decisión concreta: creamos el índice `ix_revision_vin_fecha` sobre `revision (vin, fecha DESC)` para acelerar el historial de revisiones por vehículo y la consulta de "última revisión".