# Auditoría de integridad del proyecto propio

Script: [03-auditoria-integridad.sql](sql/03-auditoria-integridad.sql). Ejecutado sobre practica45. Resultados observados el 24 de noviembre de 2026:

| Clase | Comprobaciones | Infracciones |
|---|---:|---:|
| FK declaradas | 13 | 0 |
| NOT NULL de columnas | 58 | 0 |
| UNIQUE / PK (incluidos índices únicos parciales) | 21 | 0 |

92 comprobaciones, ninguna infracción. La consulta de excepciones devolvió cero filas. El script usa una tabla temporal y termina con ROLLBACK. La auditoría se limita a las restricciones declaradas de esas clases; no demuestra todas las reglas de negocio ni evalúa todos los CHECK. Evidencia: [39](evidencias/39-auditoria-integridad.png), comprobada en captura local, pendiente de subir.
