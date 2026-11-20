#!/usr/bin/env bash
# poblar.sh | Carga de datos. Uso: bash practica4/poblar/poblar.sh
set -euo pipefail
cd "$(dirname "$0")"

CONTENEDOR="${CONTENEDOR:-pg-curso}"
PGUSER="${PGUSER:-postgres}"
PGDATABASE="${PGDATABASE:-practica45}"

echo "Cargando en la base $PGDATABASE (contenedor $CONTENEDOR, usuario $PGUSER)..."

if {
  cat 00-staging.sql
  for f in ../datos/vpic_*.json; do
    echo "COPY crudo_vpic (linea) FROM STDIN (FORMAT csv, QUOTE E'\\x01', DELIMITER E'\\x02');"
    cat "$f"
    echo
    echo '\.'
  done
  cat 10-modelo.sql
} | docker exec -i -e PGPASSWORD "$CONTENEDOR" psql -U "$PGUSER" -d "$PGDATABASE" -X -q -1 -v ON_ERROR_STOP=1
then
  echo "Carga terminada."
else
  echo "LA CARGA FALLO Y SE REVIRTIO TODO. Revisa el mensaje de ERROR de arriba."
  exit 1
fi