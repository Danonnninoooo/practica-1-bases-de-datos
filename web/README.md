# Aplicación web de Semanal Autos — segundo parcial

Esta carpeta implementa el formulario de la portada original (`index.html`) y su conexión **local** con PostgreSQL 16. La aplicación usa Python/Flask y se ejecuta en Docker; **no elimina ni recrea** el contenedor `pg-curso` ni el proyecto de Sismos.

## Antes de empezar

Debe estar funcionando `pg-curso` en el puerto **5432**, con la base `practica45`, las 13 tablas y los roles creados en la Práctica 4. En particular, existe `usuario_app_renta`.

**Importante:** no utilices una CURP, teléfono o correo auténticos para la demostración. El formulario incluye un botón para rellenar datos ficticios.

## Instrucciones paso a paso para Windows (CMD)

Desde la carpeta principal de tu repositorio, en la rama `rescate-practicas-4-5`:

### 1. Establece una contraseña propia para el usuario de la aplicación

```cmd
docker exec -it pg-curso psql -U postgres -d practica45
```

Dentro de PostgreSQL (donde aparece `practica45=#`), escribe:

```text
\password usuario_app_renta
```

La terminal solicitará la contraseña **dos veces sin mostrarla**. Elige una contraseña nueva y diferente de la contraseña del administrador. Cuando termine, sal con:

```text
\q
```

**No envíes tu contraseña al chat ni subas capturas que la contengan.**

### 2. Crea el archivo local de configuración

En CMD, desde la raíz del repositorio:

```cmd
copy web\.env.example web\.env
notepad web\.env
```

Sustituye `REEMPLAZAR_POR_TU_CONTRASENA` por la contraseña que acabas de asignar a `usuario_app_renta`. Para una contraseña alfanumérica puedes usar comillas simples: `DB_PASSWORD='TU_CONTRASENA'` (sustituye el marcador). Guarda y cierra Bloc de notas. En CMD ejecuta `set "DB_PASSWORD="` para evitar que una variable previa de esa sesión prevalezca sobre el archivo.

El archivo `web/.env` está excluido por `.gitignore`; **no se sube a GitHub**.

### 3. Arranca solamente la aplicación web

```cmd
docker compose --env-file web/.env -f web/compose.yaml up --build -d
```

Esto crea el contenedor `semanal-autos-web` y lo publica únicamente en `127.0.0.1:8081`. La conexión a PostgreSQL viaja desde el contenedor web a `host.docker.internal:5432` (Docker Desktop para Windows).

### 4. Comprueba la conexión

Abre en el navegador:

- http://localhost:8081/api/health — debe devolver JSON con `"estado":"ok"`.
- http://localhost:8081/ — debe mostrar la página Semanal Autos con el formulario.

Pulsa **Rellenar datos ficticios** y después **Registrar en PostgreSQL**. Debe mostrar el código de cliente generado.

### 5. Demuestra la persistencia ante el profesor

El formulario muestra una consulta SQL con el código real del nuevo cliente. Sustituye `CODIGO` por ese número y ejecuta en CMD:

```cmd
docker exec pg-curso psql -U usuario_consulta_renta -d practica45 -c "SELECT cod_cliente, nombre, ap_paterno, correo FROM cliente WHERE cod_cliente = CODIGO;"
```

La fila resultante debe coincidir con los valores capturados.

**Evidencia:** una captura del formulario con el registro confirmado y otra del `SELECT` donde se ve el mismo código y datos. Guardarlas en `web/evidencias/` cuando la prueba funcione.

## Resultado comprobado — 24 de noviembre de 2026

El formulario mostró `Registro guardado en PostgreSQL` con `cod_cliente = 1`. La verificación independiente desde CMD con `usuario_consulta_renta` confirmó la fila en `cliente` y su teléfono en `cliente_telefono`:

```cmd
docker exec pg-curso psql -U usuario_consulta_renta -d practica45 -c "SELECT * FROM cliente WHERE cod_cliente = 1;"
docker exec pg-curso psql -U usuario_consulta_renta -d practica45 -c "SELECT * FROM cliente_telefono WHERE cod_cliente = 1;"
```

Los datos ficticios observados (nombre, apellidos, correo, CURP de prueba, teléfono y dirección) coinciden con el formulario. `cuenta_banco` quedó nulo porque es opcional. También se observó el rechazo de una CURP con formato inválido antes de registrar la fila válida.

**Incidencia resuelta:** el backend inicialmente devolvía un error de conexión. Una prueba interactiva confirmó que la contraseña introducida manualmente sí autenticaba en PostgreSQL pero no coincidía con la variable `DB_PASSWORD` del contenedor. Se volvió a escribir `web/.env` con la contraseña correcta entre comillas simples, se limpió la variable de la sesión CMD con `set "DB_PASSWORD="` y se recreó solo el contenedor web. Después se comprobó la conexión y el registro. No se almacenan contraseñas en este informe.

Evidencias de la ejecución aportadas por el estudiante (pendientes de subir como archivos): `web/evidencias/07-registro-web.png` y `web/evidencias/08-verificacion-sql.png`.

## Cómo funciona

```text
Navegador (localhost:8081)
        |
        | POST /api/clientes (JSON)
        v
Flask / Python — validaciones y sentencias parametrizadas
        |
        | BEGIN ... INSERT cliente ... INSERT cliente_telefono ... COMMIT
        v
PostgreSQL 16 / practica45
```

Si falla cualquiera de los dos INSERT, la transacción completa se revierte. El servidor usa `usuario_app_renta`, no `postgres`. El navegador nunca recibe las credenciales.

También existe `GET /api/clientes/<codigo>` para comprobar la fila a través del backend. **Esta versión está prevista exclusivamente para una demostración local**: todavía no implementa autenticación ni medidas necesarias para tratar datos personales en Internet. No debe exponerse a la red pública.

## Nota sobre GitHub Pages

GitHub Pages solo publica archivos estáticos: no ejecuta Flask ni se conecta a PostgreSQL. La página publicada conserva el diseño y muestra el formulario, pero el registro solo funciona en la instancia local `http://localhost:8081`. El PDF del segundo parcial permite incluir **instrucciones para ejecutarla localmente**. Si después se necesita un registro público, el backend tendrá que desplegarse en un servidor con HTTPS, autenticación y medidas de privacidad.

## Solución de problemas

- Si `/api/health` responde `estado:error`, confirmar que `pg-curso` está en `docker ps`, que el puerto 5432 está publicado y que `DB_PASSWORD` coincide con la contraseña asignada a `usuario_app_renta`.
- Si no abre `localhost:8081`, ejecutar `docker logs semanal-autos-web --tail 40` para ver el error.
- Si `docker compose` indica puerto 8081 ocupado, no borres contenedores; primero revisa qué programa usa ese puerto.
- Si aparece "ya existe un cliente", usa nuevamente **Rellenar datos ficticios** para obtener otros identificadores y vuelve a intentarlo.
- Para detener SOLO esta web: `docker compose --env-file web/.env -f web/compose.yaml down`. No usar `down -v` sobre la base: podría eliminar un volumen de datos de otro compose.
