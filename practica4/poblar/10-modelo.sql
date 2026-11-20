-- 10-modelo.sql | Carga de modelo desde el catalogo vPIC del NHTSA

-- Autos que una arrendadora rentaria. El catalogo trae tambien motos y otros vehiculos.
-- Se excluyen los electricos porque litros_motor es NOT NULL.
CREATE TEMP TABLE autos_renta (marca TEXT, nombre TEXT);
INSERT INTO autos_renta VALUES
('NISSAN','VERSA'),('NISSAN','SENTRA'),('NISSAN','ALTIMA'),('NISSAN','KICKS'),('NISSAN','ROGUE'),
('NISSAN','MAXIMA'),('NISSAN','FRONTIER'),('NISSAN','MURANO'),('NISSAN','PATHFINDER'),
('CHEVROLET','AVEO'),('CHEVROLET','SPARK'),('CHEVROLET','SONIC'),('CHEVROLET','CRUZE'),
('CHEVROLET','MALIBU'),('CHEVROLET','EQUINOX'),('CHEVROLET','TRAX'),('CHEVROLET','SILVERADO'),
('CHEVROLET','TAHOE'),('CHEVROLET','SUBURBAN'),('CHEVROLET','TRAVERSE'),('CHEVROLET','COLORADO'),
('VOLKSWAGEN','JETTA'),('VOLKSWAGEN','GOLF'),('VOLKSWAGEN','PASSAT'),('VOLKSWAGEN','TIGUAN'),
('VOLKSWAGEN','TAOS'),('VOLKSWAGEN','ATLAS'),('VOLKSWAGEN','BEETLE'),
('KIA','RIO'),('KIA','SOUL'),('KIA','FORTE'),('KIA','K5'),('KIA','OPTIMA'),('KIA','SPORTAGE'),
('KIA','SORENTO'),('KIA','SELTOS'),('KIA','SEDONA'),('KIA','CARNIVAL'),('KIA','RONDO'),('KIA','TELLURIDE'),
('TOYOTA','COROLLA'),('TOYOTA','CAMRY'),('TOYOTA','YARIS'),('TOYOTA','RAV4'),('TOYOTA','HIGHLANDER'),
('TOYOTA','TACOMA'),('TOYOTA','TUNDRA'),('TOYOTA','PRIUS'),('TOYOTA','SIENNA'),('TOYOTA','4RUNNER'),
('HYUNDAI','ACCENT'),('HYUNDAI','ELANTRA'),('HYUNDAI','SONATA'),('HYUNDAI','TUCSON'),
('HYUNDAI','SANTA FE'),('HYUNDAI','KONA'),('HYUNDAI','VENUE'),('HYUNDAI','VELOSTER'),
('MAZDA','MAZDA3'),('MAZDA','MAZDA6'),('MAZDA','CX-5'),('MAZDA','CX-3'),('MAZDA','CX-30'),
('MAZDA','CX-9'),('MAZDA','MX-5 MIATA'),
('HONDA','CIVIC'),('HONDA','ACCORD'),('HONDA','FIT'),('HONDA','CR-V'),('HONDA','HR-V'),
('HONDA','PILOT'),('HONDA','ODYSSEY'),('HONDA','INSIGHT'),('HONDA','RIDGELINE');

-- Se abre el JSON y se obtiene un renglon por modelo
CREATE TEMP TABLE vpic AS
SELECT initcap(trim(r->>'Make_Name')) AS marca,
       trim(r->>'Model_Name')         AS nombre
FROM crudo_vpic c,
     jsonb_array_elements(c.linea::jsonb -> 'Results') AS r;

-- Solo autos de la lista. Los litros no vienen en la fuente: se asignan con una
-- formula fija (mismo modelo = mismos litros siempre), entre 1.2 y 2.5.
CREATE TEMP TABLE candidatos AS
SELECT DISTINCT v.marca, v.nombre,
       (ARRAY[1.2,1.5,1.6,2.0,2.5])[1 + (abs(hashtext(v.marca || v.nombre)::bigint) % 5)::int]::numeric(2,1) AS litros_motor
FROM vpic v
JOIN autos_renta a ON upper(v.marca) = upper(a.marca)
                  AND upper(v.nombre) = upper(a.nombre);

-- Insercion repetible: si ya existe, se salta
WITH ins AS (
  INSERT INTO modelo (marca, nombre, litros_motor)
  SELECT marca, nombre, litros_motor FROM candidatos ORDER BY marca, nombre
  ON CONFLICT (marca, nombre, litros_motor) DO NOTHING
  RETURNING 1
)
SELECT 'modelo' AS tabla,
       (SELECT count(*) FROM vpic)       AS leidos,
       (SELECT count(*) FROM vpic) - (SELECT count(*) FROM candidatos) AS descartados_por_filtro,
       (SELECT count(*) FROM ins)        AS insertados,
       (SELECT count(*) FROM candidatos) - (SELECT count(*) FROM ins)  AS ya_existian;

-- Para revisar que modelos de la lista si aparecieron en el catalogo
SELECT marca, count(*) AS aceptados, string_agg(nombre, ', ' ORDER BY nombre) AS modelos
FROM candidatos GROUP BY marca ORDER BY marca;