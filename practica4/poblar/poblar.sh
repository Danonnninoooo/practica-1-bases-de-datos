#!/usr/bin/env bash
# Uso (desde la raiz del repo): bash practica4/poblar/poblar.sh
# Antes de la primera ejecucion: crear roles con practica4/permisos/00-crear-roles.sql
# Carga atomica, repetible, masiva para JSON NHTSA y por lotes para datos sinteticos.
set -euo pipefail
cd "$(dirname "$0")"

CONTENEDOR="${CONTENEDOR:-pg-curso}"
PGUSER="${PGUSER:-usuario_app_renta}"
PGDATABASE="${PGDATABASE:-practica45}"

shopt -s nullglob
archivos=(../datos/vpic_*.json)
if (( ${#archivos[@]} == 0 )); then
  echo "ERROR: no encontre los datos NHTSA en practica4/datos/." >&2
  exit 1
fi

echo "Base: $PGDATABASE | Contenedor: $CONTENEDOR | Usuario de aplicacion: $PGUSER"
echo "La carga se ejecuta en UNA sola transaccion; un error revierte todos los INSERT/COPY."

if {
  cat 00-staging.sql
  cat 05-conteos.sql

  for archivo in "${archivos[@]}"; do
    printf "%s\n" "COPY crudo_vpic (linea) FROM STDIN (FORMAT csv, QUOTE E'\\x01', DELIMITER E'\\x02');"
    # No imprimir lineas en blanco adicionales: cada archivo contiene un JSON
    # compacto por linea; los datos quedan en una tabla temporal.
    while IFS= read -r linea || [[ -n "$linea" ]]; do
      printf '%s\n' "$linea"
    done < "$archivo"
    printf '\\.\n'
  done

  cat 10-modelo.sql
  cat 20-sinteticos.sql
  cat 90-resumen.sql
} | docker exec -i "$CONTENEDOR" psql -U "$PGUSER" -d "$PGDATABASE" \
    -X -1 -v ON_ERROR_STOP=1 -P pager=off
then
  echo "CARGA COMPLETADA: ejecutala una segunda vez para verificar que inserte 0 filas."
else
  echo "ERROR: la carga fallo y se revirtio la transaccion. Copia el ERROR mostrado arriba." >&2
  exit 1
fi
