-- 00-crear-roles.sql
-- Ejecutar una sola vez como postgres en la base practica45.
-- Nunca se guardan contraseñas en este archivo.
-- Se crea el rol de carga/aplicación, el de consulta y el de administración.
-- El usuario de carga puede conectarse al socket LOCAL dentro del contenedor.
-- Para conexiones de la aplicación web habrá que asignar contraseña con \password.

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_app_renta') THEN
    CREATE ROLE rol_app_renta NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_consulta_renta') THEN
    CREATE ROLE rol_consulta_renta NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_admin_renta') THEN
    CREATE ROLE rol_admin_renta NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usuario_app_renta') THEN
    CREATE ROLE usuario_app_renta LOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usuario_consulta_renta') THEN
    CREATE ROLE usuario_consulta_renta LOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'usuario_admin_renta') THEN
    CREATE ROLE usuario_admin_renta LOGIN;
  END IF;
END $$;

GRANT rol_app_renta TO usuario_app_renta;
GRANT rol_consulta_renta TO usuario_consulta_renta;
GRANT rol_admin_renta TO usuario_admin_renta;

GRANT CONNECT ON DATABASE practica45
  TO rol_app_renta, rol_consulta_renta, rol_admin_renta;
GRANT TEMPORARY ON DATABASE practica45 TO rol_app_renta;

GRANT USAGE ON SCHEMA public
  TO rol_app_renta, rol_consulta_renta, rol_admin_renta;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO rol_app_renta;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO rol_app_renta;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO rol_consulta_renta;

GRANT CREATE ON SCHEMA public TO rol_admin_renta;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO rol_admin_renta;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO rol_admin_renta;

-- En producción se reemplazarían los permisos amplios del cargador por permisos
-- específicos de los servicios. Aquí el mismo usuario de aplicación carga las
-- trece tablas para satisfacer la rúbrica; la cuenta de consulta es solo lectura.

SELECT rolname, rolcanlogin FROM pg_roles
WHERE rolname IN ('rol_app_renta', 'rol_consulta_renta', 'rol_admin_renta',
                  'usuario_app_renta', 'usuario_consulta_renta', 'usuario_admin_renta')
ORDER BY rolname;
