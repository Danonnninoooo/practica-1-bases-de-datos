-- Exporta un grupo compacto de RelaX; no modifica el almacén.
-- Conserva TODOS los pares que cumplen la consulta 02 y agrega controles.
BEGIN READ ONLY;
WITH pares AS (
 SELECT DISTINCT f.id_sismo,f.id_tiempo
 FROM fact_impacto_sismos_imputed f
 JOIN dim_sismos s ON s.id_sismo=f.id_sismo
 JOIN dim_tiempo t ON t.id_tiempo=f.id_tiempo
 WHERE s.magnitud >= 6 AND t.fecha BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
), controles_magnitud AS (
 SELECT DISTINCT f.id_sismo,f.id_tiempo
 FROM fact_impacto_sismos_imputed f
 JOIN dim_sismos s ON s.id_sismo=f.id_sismo
 JOIN dim_tiempo t ON t.id_tiempo=f.id_tiempo
 WHERE s.magnitud < 6 AND s.magnitud IS NOT NULL AND s.profundidad IS NOT NULL
 AND t.fecha BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
 ORDER BY f.id_sismo,f.id_tiempo LIMIT 20
), controles_fecha AS (
 SELECT DISTINCT f.id_sismo,f.id_tiempo
 FROM fact_impacto_sismos_imputed f
 JOIN dim_sismos s ON s.id_sismo=f.id_sismo
 JOIN dim_tiempo t ON t.id_tiempo=f.id_tiempo
 WHERE s.magnitud >= 6 AND s.profundidad IS NOT NULL
 AND t.fecha NOT BETWEEN DATE '2017-01-01' AND DATE '2017-12-31'
 ORDER BY f.id_sismo,f.id_tiempo LIMIT 5
), muestra AS (
 SELECT * FROM pares UNION SELECT * FROM controles_magnitud UNION SELECT * FROM controles_fecha
)
SELECT 'group:Sismos - Segundo parcial' || chr(10) ||
'description:Dimensiones completas de zonas y economia; muestra de pares sismo-tiempo con todos los casos de la consulta 02 y controles.' || chr(10) ||
'dim_zonas = {' || chr(10) || 'id_zonas:number, pobtot:number, nom_ent:string' || chr(10) ||
COALESCE((SELECT string_agg(format('%s, %s, %L',id_zonas,pobtot,nom_ent),chr(10) ORDER BY id_zonas) FROM dim_zonas),'') || chr(10) || '}' || chr(10) ||
'dim_economia = {' || chr(10) || 'id_economia:number, nombre_entidad:string, produccion_bruta_total:number' || chr(10) ||
COALESCE((SELECT string_agg(format('%s, %L, %s',id_economia,nombre_entidad,produccion_bruta_total),chr(10) ORDER BY id_economia) FROM dim_economia),'') || chr(10) || '}' || chr(10) ||
'dim_sismos = {' || chr(10) || 'id_sismo:number, magnitud:number, profundidad:number' || chr(10) ||
COALESCE((SELECT string_agg(format('%s, %s, %s',s.id_sismo,s.magnitud,s.profundidad),chr(10) ORDER BY s.id_sismo) FROM dim_sismos s WHERE EXISTS (SELECT 1 FROM muestra m WHERE m.id_sismo=s.id_sismo)),'') || chr(10) || '}' || chr(10) ||
'dim_tiempo = {' || chr(10) || 'id_tiempo:number, fecha:string, anio:number' || chr(10) ||
COALESCE((SELECT string_agg(format('%s, %L, %s',t.id_tiempo,to_char(t.fecha,'YYYY-MM-DD'),extract(year FROM t.fecha)::int),chr(10) ORDER BY t.id_tiempo) FROM dim_tiempo t WHERE EXISTS (SELECT 1 FROM muestra m WHERE m.id_tiempo=t.id_tiempo)),'') || chr(10) || '}' || chr(10) ||
'fact_impacto_sismos_imputed = {' || chr(10) || 'id_sismo:number, id_tiempo:number' || chr(10) ||
COALESCE((SELECT string_agg(format('%s, %s',id_sismo,id_tiempo),chr(10) ORDER BY id_sismo,id_tiempo) FROM muestra),'') || chr(10) || '}';
COMMIT;
