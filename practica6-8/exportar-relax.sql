-- Exportación de proyecciones, sin información personal.
-- Ejecutar con psql -qAt para obtener exclusivamente el texto del grupo.
BEGIN READ ONLY;
SELECT 'group:Semanal Autos' || chr(10) ||
'description:Proyecciones de la base practica45 para algebra relacional' || chr(10) ||
'modelo = {' || chr(10) || 'id_modelo:number, marca:string, nombre:string' || chr(10) ||
COALESCE((SELECT string_agg(format('%s, %L, %L',id_modelo,marca,nombre),chr(10) ORDER BY id_modelo) FROM modelo),'') || chr(10) || '}' || chr(10) ||
'vehiculo = {' || chr(10) || 'vin:string, color:string, anio:number, id_modelo:number' || chr(10) ||
COALESCE((SELECT string_agg(format('%L, %L, %s, %s',trim(vin),color,anio,id_modelo),chr(10) ORDER BY vin) FROM vehiculo),'') || chr(10) || '}' || chr(10) ||
'contrato = {' || chr(10) || 'id_contrato:number, estado:string' || chr(10) ||
COALESCE((SELECT string_agg(format('%s, %L',id_contrato,estado),chr(10) ORDER BY id_contrato) FROM contrato),'') || chr(10) || '}' || chr(10) ||
'pago_semanal = {' || chr(10) || 'id_contrato:number, num_semana:number' || chr(10) ||
COALESCE((SELECT string_agg(format('%s, %s',id_contrato,num_semana),chr(10) ORDER BY id_contrato,num_semana) FROM pago_semanal),'') || chr(10) || '}' || chr(10) ||
'semanas = {' || chr(10) || 'num_semana:number' || chr(10) || '1' || chr(10) || '2' || chr(10) || '3' || chr(10) || '4' || chr(10) || '}';
COMMIT;
