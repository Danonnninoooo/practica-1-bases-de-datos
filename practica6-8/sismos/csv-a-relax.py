"""Convierte la exportación SQLite de Sismos a un grupo de RelaX.
Uso: python practica6-8/sismos/csv-a-relax.py
Solo utiliza la biblioteca estándar de Python.
"""
import csv
from collections import Counter
from decimal import Decimal
from pathlib import Path

base = Path(__file__).resolve().parent
source = base / "sqlite-relax.csv"
target = base / "grupo-relax-actual.txt"
records = []
catalogs = {}
ids = set()

def literal(value):
    # Las claves y etiquetas de los catálogos observados no tienen comillas
    # simples ni barras inversas. Detenerse si cambia esa condición.
    if not value or any(ch in value for ch in ("'", "\\", "\r", "\n")):
        raise ValueError(f"Texto no compatible con este exportador: {value!r}")
    return "'" + value + "'"

with source.open(encoding="utf-8-sig", newline="") as f:
    reader = csv.DictReader(f)
    required = {"row_no", "record_key", "catalogue_id", "year", "mag", "label"}
    if not required.issubset(reader.fieldnames or []):
        raise ValueError("El CSV no contiene las seis columnas de la consulta de exportacion.")
    for row in reader:
        row_no = int(row["row_no"])
        year = int(row["year"])
        mag = Decimal(row["mag"])
        key, cid, label = (row[k] for k in ("record_key", "catalogue_id", "label"))
        for value in (key, cid, label):
            literal(value)
        if row_no in ids or not mag.is_finite():
            raise ValueError("Fila duplicada o magnitud no finita.")
        ids.add(row_no)
        if cid in catalogs and catalogs[cid] != label:
            raise ValueError("Etiquetas inconsistentes para un catalogo.")
        catalogs[cid] = label
        records.append((row_no, key, cid, year, mag))

if not records:
    raise ValueError("El CSV esta vacio.")

selection = {(key, year, mag) for _, key, _, year, mag in records if year == 2017 and mag >= 6}
join = {(key, catalogs[cid]) for _, key, cid, year, mag in records if year == 2017 and mag >= 6}
annual = Counter(year for _, _, _, year, mag in records if 2017 <= year <= 2025 and Decimal("5.9") <= mag <= 10)
print("Seleccion:", len(selection), "Reunion:", len(join))
print("Agrupacion:", sorted(annual.items()))
expected = dict(zip(range(2017, 2026), [11, 14, 10, 28, 20, 25, 17, 23, 21]))
if len(selection) != 10 or len(join) != 10 or dict(annual) != expected:
    raise ValueError("Los resultados difieren de las capturas previas. Revisar seleccion y CSV.")

lines = [
    "group:Sismos observatorio SQLite",
    "description:Proyeccion de registros que satisfacen al menos un filtro de los ejercicios; catalogos referenciados.",
    "records = {",
    "row_no:number, record_key:string, catalogue_id:string, year:number, mag:number",
]
for row_no, key, cid, year, mag in records:
    lines.append(f"{row_no}, {literal(key)}, {literal(cid)}, {year}, {format(mag, 'f')}")
lines += ["}", "catalogs = {", "catalogue_id:string, label:string"]
for cid, label in sorted(catalogs.items()):
    lines.append(f"{literal(cid)}, {literal(label)}")
lines += ["}"]
target.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(f"Grupo creado: {target} ({len(records)} registros, {len(catalogs)} catalogos)")
