"""Backend de demostración de Semanal Autos.

La app es intencionalmente LOCAL (http://localhost:8081).
No publicarla en Internet sin autenticación, HTTPS y protección de datos.
"""

import os
import re
from pathlib import Path

import psycopg
from flask import Flask, jsonify, request, send_file
from psycopg.errors import CheckViolation, NotNullViolation, UniqueViolation
from psycopg.rows import dict_row

app = Flask(__name__)
app.config["MAX_CONTENT_LENGTH"] = 16 * 1024

INDEX = Path(__file__).resolve().parent.parent / "index.html"

CAMPOS_OBLIGATORIOS = {
    "nombre": 60,
    "ap_paterno": 40,
    "curp": 18,
    "correo": 100,
    "calle": 80,
    "colonia": 60,
    "cp": 5,
    "municipio": 60,
    "telefono": 10,
}
CAMPOS_OPCIONALES = {"ap_materno": 40}


def conectar():
    return psycopg.connect(
        host=os.getenv("DB_HOST", "host.docker.internal"),
        port=int(os.getenv("DB_PORT", "5432")),
        dbname=os.getenv("DB_NAME", "practica45"),
        user=os.getenv("DB_USER", "usuario_app_renta"),
        password=os.environ["DB_PASSWORD"],
        connect_timeout=5,
        row_factory=dict_row,
    )


def normalizar_y_validar(datos):
    if not isinstance(datos, dict):
        return None, "Se necesita un objeto JSON con los datos del formulario."

    limpio = {}
    for campo, longitud in CAMPOS_OBLIGATORIOS.items():
        valor = datos.get(campo)
        if not isinstance(valor, str) or not valor.strip():
            return None, f"Falta el campo obligatorio: {campo}."
        valor = valor.strip()
        if len(valor) > longitud:
            return None, f"El campo {campo} supera {longitud} caracteres."
        limpio[campo] = valor

    for campo, longitud in CAMPOS_OPCIONALES.items():
        valor = datos.get(campo)
        if valor is None or valor == "":
            limpio[campo] = None
        elif not isinstance(valor, str) or len(valor.strip()) > longitud:
            return None, f"El campo {campo} es inválido."
        else:
            limpio[campo] = valor.strip() or None

    limpio["curp"] = limpio["curp"].upper()
    limpio["correo"] = limpio["correo"].lower()
    limpio["telefono"] = re.sub(r"\s+", "", limpio["telefono"])

    if not re.fullmatch(r"[A-Z]{4}[0-9]{6}[HM][A-Z]{5}[A-Z0-9][0-9]", limpio["curp"]):
        return None, "La CURP debe tener 18 caracteres y cumplir el formato del esquema."
    if not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", limpio["correo"]):
        return None, "El correo electrónico tiene un formato inválido."
    if not re.fullmatch(r"[0-9]{5}", limpio["cp"]):
        return None, "El código postal debe tener cinco dígitos."
    if not re.fullmatch(r"[0-9]{10}", limpio["telefono"]):
        return None, "El teléfono debe tener diez dígitos."

    return limpio, None


def obtener_cliente(cur, cod_cliente):
    cur.execute(
        """SELECT c.cod_cliente, c.nombre, c.ap_paterno, c.ap_materno,
                  c.curp, c.correo, c.calle, c.colonia, c.cp, c.municipio,
                  t.telefono
           FROM cliente c
           LEFT JOIN cliente_telefono t ON t.cod_cliente = c.cod_cliente
           WHERE c.cod_cliente = %s
           ORDER BY t.telefono
           LIMIT 1""",
        (cod_cliente,),
    )
    return cur.fetchone()


@app.get("/")
def portada():
    return send_file(INDEX)


@app.get("/api/health")
def health():
    try:
        with conectar() as conn, conn.cursor() as cur:
            cur.execute("SELECT current_database() AS base, current_user AS usuario")
            resultado = cur.fetchone()
        return jsonify({"estado": "ok", **resultado})
    except (psycopg.Error, OSError, KeyError, ValueError):
        return jsonify({"estado": "error", "mensaje": "No se puede conectar a PostgreSQL."}), 503


@app.post("/api/clientes")
def registrar_cliente():
    datos, error = normalizar_y_validar(request.get_json(silent=True))
    if error:
        return jsonify({"error": error}), 400

    try:
        # Todo o nada: si falla el teléfono, también se revierte el cliente.
        with conectar() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """INSERT INTO cliente
                       (nombre, ap_paterno, ap_materno, curp, correo, calle,
                        colonia, cp, municipio)
                       VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                       RETURNING cod_cliente""",
                    (
                        datos["nombre"], datos["ap_paterno"], datos["ap_materno"],
                        datos["curp"], datos["correo"], datos["calle"],
                        datos["colonia"], datos["cp"], datos["municipio"],
                    ),
                )
                cod_cliente = cur.fetchone()["cod_cliente"]
                cur.execute(
                    "INSERT INTO cliente_telefono (cod_cliente, telefono) VALUES (%s, %s)",
                    (cod_cliente, datos["telefono"]),
                )
                registrado = obtener_cliente(cur, cod_cliente)
        return jsonify({"mensaje": "Registro guardado en PostgreSQL.", "cliente": registrado}), 201
    except UniqueViolation:
        return jsonify({"error": "Ya existe un cliente con esa CURP o ese correo."}), 409
    except (CheckViolation, NotNullViolation):
        return jsonify({"error": "Los datos no cumplen una restricción de la base de datos."}), 400
    except (psycopg.Error, OSError, KeyError, ValueError):
        app.logger.exception("Error al registrar cliente")
        return jsonify({"error": "No se pudo guardar el registro. Revisa la conexión o los permisos."}), 503


@app.get("/api/clientes/<int:cod_cliente>")
def consultar_cliente(cod_cliente):
    try:
        with conectar() as conn, conn.cursor() as cur:
            registrado = obtener_cliente(cur, cod_cliente)
        if registrado is None:
            return jsonify({"error": "No se encontró ese cliente."}), 404
        return jsonify({"cliente": registrado})
    except (psycopg.Error, OSError, KeyError, ValueError):
        app.logger.exception("Error al consultar cliente")
        return jsonify({"error": "No se pudo consultar la base de datos."}), 503


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8081, debug=False)
