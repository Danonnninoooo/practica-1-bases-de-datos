# Roles y permisos — renta semanal de vehículos

## 1. Propósito de cada rol

| Rol | Usuario de inicio de sesión | Uso |
|---|---|---|
| `rol_app_renta` | `usuario_app_renta` | Carga masiva y operaciones de la aplicación; lectura/escritura sobre las tablas de renta. No puede crear tablas permanentes. |
| `rol_consulta_renta` | `usuario_consulta_renta` | Consultar registros sin cambiarlos; solo `SELECT`. |
| `rol_admin_renta` | `usuario_admin_renta` | Administración de datos, secuencias y creación de objetos nuevos en el esquema público. No es un superusuario; alterar objetos preexistentes requiere ser su propietario. |

**Implementación:** `practica4/permisos/00-crear-roles.sql`; crea roles y usuarios si no existen y aplica los `GRANT` sin incluir contraseñas.

**Antes de ejecutar la carga**, desde CMD situado en la raíz del repositorio, inicializar los permisos con:

```cmd
docker exec -i pg-curso psql -U postgres -d practica45 -X -v ON_ERROR_STOP=1 < practica4\permisos\00-crear-roles.sql
```

La conexión usada por el script de carga es el socket PostgreSQL **dentro** del contenedor Docker; el usuario predeterminado es `usuario_app_renta`, no `postgres`.

**Contraseñas:** No se almacenan en Git. Para permitir conexiones por red del backend, debe asignarse una contraseña al usuario de aplicación con `\password usuario_app_renta` desde una sesión interactiva de `psql` como administrador. Nunca copiar esa contraseña a un archivo versionado ni a una captura.

## 2. Matriz de permisos

Todos los permisos son sobre `public`. I = INSERT; S = SELECT; U = UPDATE; D = DELETE.

| Tablas | App | Consulta | Administración |
|---|---|---|---|
| cliente, cliente_telefono | S/I/U/D | S | S/I/U/D |
| modelo, vehiculo | S/I/U/D | S | S/I/U/D |
| empleado, mecanico, administrativo | S/I/U/D | S | S/I/U/D |
| contrato, pago_semanal | S/I/U/D | S | S/I/U/D |
| revision, inspeccion | S/I/U/D | S | S/I/U/D |
| refaccion, reparacion | S/I/U/D | S | S/I/U/D |

- `rol_app_renta` también tiene `USAGE`/`SELECT` sobre secuencias y `TEMP` sobre la base, necesarios para claves `SERIAL` y tablas temporales de carga.
- `rol_consulta_renta` no tiene `INSERT`, `UPDATE` ni `DELETE`.
- `rol_admin_renta` tiene además `CREATE` en el esquema público y permisos de secuencias.

La aplicación y el cargador comparten el rol de aplicación durante esta práctica porque el cargador usa todas las tablas. Al crear un servicio web real conviene separar un usuario con permisos mínimos solo sobre las tablas que utiliza ese servicio.

## 3. Pruebas pendientes de ejecutar (no inventar resultados)

**Consulta permitida:**

```cmd
docker exec pg-curso psql -U usuario_consulta_renta -d practica45 -c "SELECT COUNT(*) FROM cliente;"
```

**Escritura prohibida para consulta** (se espera error de permiso sobre la tabla):

```cmd
docker exec pg-curso psql -U usuario_consulta_renta -d practica45 -c "INSERT INTO modelo (marca, nombre, litros_motor) VALUES ('Prueba','Bloqueado',1.6);"
```

**Retiro temporal de permiso** (tomar evidencia del error y después restaurar):

```cmd
docker exec pg-curso psql -U postgres -d practica45 -c "REVOKE SELECT ON public.modelo FROM rol_consulta_renta;"
docker exec pg-curso psql -U usuario_consulta_renta -d practica45 -c "SELECT COUNT(*) FROM modelo;"
docker exec pg-curso psql -U postgres -d practica45 -c "GRANT SELECT ON public.modelo TO rol_consulta_renta;"
```

**Permisos del rol de aplicación:** documentar también una lectura y una inserción permitidas, pero utilizar transacciones con `ROLLBACK` para no dejar datos de prueba extra.

**Evidencias por completar:** pegar las salidas reales de cada prueba (permitida, negada, y `REVOKE`) y el mensaje exacto del gestor. No afirmar que estas pruebas ya se realizaron.
