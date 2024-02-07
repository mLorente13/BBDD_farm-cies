-- Crear base de datos farmacies
DROP DATABASE IF EXISTS farmacies;

CREATE DATABASE farmacies;

USE farmacies;

-- Crear tablas
CREATE TABLE medicament (
    codi int UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    nom varchar(50) UNIQUE NOT NULL,
    composicio varchar(100) NOT NULL
) AUTO_INCREMENT = 1;

CREATE TABLE ciutat (
    nom varchar(50) UNIQUE NOT NULL,
    provincia varchar(50) NOT NULL,
    habitants int(11) NOT NULL,
    superficie int(11) NOT NULL,
    PRIMARY KEY (nom)
);

CREATE TABLE propietari (
    dni varchar(9) UNIQUE NOT NULL,
    nom varchar(50) NOT NULL,
    carrer varchar(75) NOT NULL,
    codi_postal int(5) NOT NULL,
    nom_ciutat varchar(50) NOT NULL,
    PRIMARY KEY (dni),
    FOREIGN KEY (nom_ciutat) REFERENCES ciutat(nom) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE farmacia (
    nom varchar(50) UNIQUE NOT NULL,
    carrer varchar(75) NOT NULL,
    codi_postal int(5) NOT NULL,
    nom_ciutat varchar(50) NOT NULL,
    dni_propietari varchar(50) NOT NULL,
    PRIMARY KEY (nom),
    FOREIGN KEY (nom_ciutat) REFERENCES ciutat(nom) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (dni_propietari) REFERENCES propietari(dni) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE preu (
    nom varchar(50),
    codi int(11) UNSIGNED,
    preu int(10) NOT NULL,
    FOREIGN KEY (nom) REFERENCES farmacia(nom) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (codi) REFERENCES medicament(codi) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Insertar datos

INSERT INTO
    medicament (nom, composicio)
VALUES
    ('Frenadol', 'Composicio 1'),
    ('Paracetamol', 'Composicio 2'),
    ('Ibuprofeno', 'Composicio 3');

INSERT INTO
    ciutat (nom, provincia, habitants, superficie)
VALUES
    ('Palma', 'Islas Baleares', 409661, 208),
    ('Marratxí', 'Islas Baleares', 34385, 54),
    ('Inca', 'Islas Baleares', 32137, 58);

INSERT INTO
    propietari (dni, nom, carrer, codi_postal, nom_ciutat)
VALUES
    ('12345678A', 'Propietari 1', 'Carrer 1', 12345, 'Palma'),
    ('12345678B', 'Propietari 2', 'Carrer 2', 12345, 'Marratxí'),
    ('12345678C', 'Propietari 3', 'Carrer 3', 12345, 'Inca');

INSERT INTO
    farmacia (nom, carrer, codi_postal, nom_ciutat, dni_propietari)
VALUES
    ('Farmacia 1', 'Carrer 1', 12345, 'Palma', '12345678A'),
    ('Farmacia 2', 'Carrer 2', 12345, 'Marratxí', '12345678B'),
    ('Farmacia 3', 'Carrer 3', 12345, 'Inca', '12345678C');

INSERT INTO
    preu (nom, codi, preu)
VALUES
    ('Farmacia 1', 1, 10),
    ('Farmacia 1', 2, 20),
    ('Farmacia 1', 3, 30),
    ('Farmacia 2', 1, 15),
    ('Farmacia 2', 2, 25),
    ('Farmacia 2', 3, 35),
    ('Farmacia 3', 1, 12),
    ('Farmacia 3', 2, 22),
    ('Farmacia 3', 3, 32);

-- Consultas

-- 1. Mostrar el nombre del propietario, nombre de su farmacia y la ubicación de la farmacia (calle, codigo postal, provincia y ciudad).
SELECT
    propietari.nom,
    farmacia.nom,
    farmacia.carrer,
    farmacia.codi_postal,
    ciutat.provincia,
    ciutat.nom
FROM
    propietari
    INNER JOIN farmacia ON propietari.dni = farmacia.dni_propietari
    INNER JOIN ciutat ON farmacia.nom_ciutat = ciutat.nom;


-- 2. Mostrar el nombre de los propietarios que vivan en Palma.
SELECT
    propietari.nom
FROM
    propietari
    INNER JOIN ciutat ON propietari.nom_ciutat = ciutat.nom
WHERE
    ciutat.nom = 'Palma';


-- 3. Mostrar el nombre del medicamento, nombre de la farmacia donde se vende y precio de cada medicamento.
SELECT
    medicament.nom,
    farmacia.nom,
    preu.preu
FROM
    medicament
    INNER JOIN preu ON medicament.codi = preu.codi
    INNER JOIN farmacia ON preu.nom = farmacia.nom;


-- 4. Mostrar el nombre y composición de todos los medicamentos que se venden en las ciudades de más de 1000 habitantes.
SELECT
    medicament.nom,
    medicament.composicio
FROM
    medicament
    INNER JOIN preu ON medicament.codi = preu.codi
    INNER JOIN farmacia ON preu.nom = farmacia.nom
    INNER JOIN ciutat ON farmacia.nom_ciutat = ciutat.nom
WHERE
    ciutat.habitants > 1000;


-- 5. Mostrar el nombre de las ciudades que no tienen ninguna farmacia.
SELECT
    ciutat.nom
FROM
    ciutat
    LEFT JOIN farmacia ON ciutat.nom = farmacia.nom
WHERE
    farmacia.nom IS NULL;


-- 6. Mostrar el nombre de las farmacias que no se encuentran en la ciudad donde vive su propietario.
SELECT
    farmacia.nom
FROM
    farmacia
    INNER JOIN propietari ON farmacia.dni_propietari = propietari.dni
    INNER JOIN ciutat ON farmacia.nom_ciutat = ciutat.nom
WHERE
    farmacia.nom_ciutat != propietari.nom_ciutat;


-- 7. Mostrar el precio del medicamento más caro y del medicamento más barato de cada farmacia.
SELECT
    farmacia.nom,
    MAX(preu.preu),
    MIN(preu.preu)
FROM
    farmacia
    INNER JOIN preu ON farmacia.nom = preu.nom
GROUP BY
    farmacia.nom;


-- 8. Mostrar la media de habitantes de todas las ciudades de las Islas Baleares.
SELECT
    AVG(ciutat.habitants)
FROM
    ciutat
WHERE
    ciutat.provincia = 'Islas Baleares';


-- 9. Mostrar el nombre y composición de los medicamentos que no se venden en Palma.
SELECT
    medicament.nom,
    medicament.composicio
FROM
    medicament
    LEFT JOIN preu ON medicament.codi = preu.codi
    LEFT JOIN farmacia ON preu.nom = farmacia.nom
    LEFT JOIN ciutat ON farmacia.nom_ciutat = ciutat.nom
WHERE
    ciutat.nom != 'Palma'
    OR ciutat.nom IS NULL;


-- 10 Mostrar el nombre y DNI de los propietarios que no tiene en venta el medicamento con nombre "Ibuprofeno".
SELECT
    propietari.nom,
    propietari.dni
FROM
    propietari
    LEFT JOIN farmacia ON propietari.dni = farmacia.dni_propietari
    LEFT JOIN preu ON farmacia.nom = preu.nom
    LEFT JOIN medicament ON preu.codi = medicament.codi
WHERE
    medicament.nom != 'Ibuprofeno'
    OR medicament.nom IS NULL;