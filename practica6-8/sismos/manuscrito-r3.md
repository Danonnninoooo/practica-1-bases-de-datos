# Análisis del manuscrito R3 y propuestas de mejora

## Identificación y versión

Villa Vargas, J. M., & Hurtado Avilés, G. (2026). *A browser-based seismic data observatory for detecting and comparing earthquake sequences across North American catalogues* (Revisión R3) [Manuscrito no publicado]. Escuela Superior de Cómputo, Instituto Politécnico Nacional. https://github.com/gabrielhuav/Seismic_Data_Geosciences/blob/main/paper/manuscript/out/Seismic_CG_manuscript_R3.pdf

- [PDF R3 solicitado por el docente](https://github.com/gabrielhuav/Seismic_Data_Geosciences/blob/1bfc0e69f7ffa26df5e843d69995e0e07901d7f3/paper/manuscript/out/Seismic_CG_manuscript_R3.pdf)
- [Texto fuente de R3, mismo commit del 18 de noviembre de 2026](https://github.com/gabrielhuav/Seismic_Data_Geosciences/blob/1bfc0e69f7ffa26df5e843d69995e0e07901d7f3/paper/manuscript/manuscript.md).
- [Observatorio](https://gabrielhuav.github.io/Seismic_Data_Geosciences/). El repositorio ya contiene R4; este análisis se limita a R3, como indica la consigna. No se confirmó un DOI propio del manuscrito R3 ni su publicación en revista. No confundir con DOI de otros artículos o archivos de reproducción.

## Problema, datos y método

El problema es que la agrupación de sismos en familias depende de las mediciones, la cobertura de cada catálogo y los parámetros del algoritmo. Dos agencias pueden asociar un mismo candidato a eventos antecedentes diferentes. R3 contrasta SSN y ComCat para México, utiliza Alaska para comparar métodos y Canadá para descripción. En el recorte mexicano 2016–2025, con magnitud reportada de al menos 3.5, emplea 170 880 registros SSN y 3 945 ComCat. Empareja por proximidad temporal y espacial y aplica una búsqueda de antecedentes mediante un árbol KD, contrastada con enumeración exhaustiva. Examina sensibilidad de parámetros y catálogos sintéticos de estructura conocida. (Resumen y sección 2.)

## Resultado principal

El ensayo nativo de un hilo sobre 170 880 observaciones obtuvo una mediana de 5.92 s con el índice frente a 524.04 s de la búsqueda exhaustiva, conservando los mismos resultados (88.46 veces). A magnitud reportada mínima 4.5, 772 de 889 pares candidatos coincidieron en rol de familia para el peso de referencia, pero el índice de Jaccard de representantes fue aproximadamente 0.41. Coincidencia no equivale a verdad física ni pronóstico. Son resultados de los autores; el equipo no reprodujo este benchmark. (Resumen, secciones 3 y 6.)

## Avance frente al primer parcial

El artículo anterior de divulgación presentaba mapas, filtros y reportes con datos mexicanos del SSN e información INEGI, mediante PHP, PostgreSQL y Docker. La revisión R3 amplía el estudio hacia la comparación entre catálogos y métodos de agrupación, con evidencia reproducible y cálculo en el navegador. El nuevo observatorio integra consultas SQLite locales y vistas interactivas. Las consultas de la versión anterior que ejecutamos se conservan como antecedente; no sustituyen el montaje de la versión R3.

Referencia del antecedente: Villa Vargas, J. M., Hurtado Avilés, G., & Climent Hernández, J. A. (2026). Cuando México tiembla: la historia contada por los datos. *AZCATL Revista de Divulgación en Ciencias, Ingeniería e Innovación, 4*(6), 28–33. https://doi.org/10.24275/AZC2026E1004

## Propuestas del equipo (no implementadas)

### 1. Validación de identidades entre catálogos

- Limitación: las parejas son candidatas, no identidades adjudicadas; R3 reconoce que no puede estimar el error de asociación con el material disponible (secciones 2.1 y 5).
- Cambio: añadir una tabla de correspondencias revisadas con ambos IDs, diferencia de tiempo y ubicación, evidencia, decisión (confirmada/rechazada/indeterminada), versión del catálogo y fecha de revisión. Seleccionar una muestra estratificada por distancia, desfase y región; contrastar con boletines de las agencias y revisión especializada independiente.
- Comprobación: medir precisión y recuperación sobre un conjunto adjudicado que incluya correspondencias no seleccionadas por el algoritmo; informar casos indeterminados por separado y repetir las comparaciones de roles sobre los casos confirmados. Comparar con el método actual sin afirmar que aumentó el rendimiento antes de medirlo.

### 2. Auditoría de cobertura y metadatos de magnitud

- Limitación: cobertura desigual y tipos de magnitud ausentes en SSN; el manuscrito no establece una escala común ni completitud a partir de los ajustes estadísticos (secciones 2.2 y 5).
- Cambio: incorporar un perfil de calidad por fuente, periodo, región y tipo de magnitud, con proporción desconocida y procedencia documentada. Añadir filtros de soporte compartido y comparación por tipo conocido, sin imputar automáticamente los tipos faltantes. Mostrar claramente los registros excluidos y conservar el dato original.
- Comprobación: congelar los mismos catálogos y parámetros; comparar el escenario base con estratos de soporte y magnitud comparable, reportando tamaños de muestra, acuerdo de roles, Jaccard y estabilidad en ventanas temporales. Evaluar que los totales del perfil reconcilien con el catálogo y que las exportaciones reproduzcan la selección. No interpretar los resultados como riesgo o causalidad.

## Preparación para la exposición (2 minutos)

45 s: problema, datos y método. 30 s: resultado principal y avance respecto al prototipo. 45 s: las dos mejoras y cómo probarlas. El artículo científico y las propuestas se distinguen de nuestras ejecuciones de SQL/RelaX. Se debe reconocer el apoyo de herramientas de IA conforme a las indicaciones académicas y declarar las aportaciones reales de cada integrante.
