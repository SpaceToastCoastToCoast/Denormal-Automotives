\c test

CREATE USER normal_user;

CREATE DATABASE normal_cars OWNER normal_user;

\c normal_cars

DROP TABLE IF EXISTS car_models CASCADE;
DROP TABLE IF EXISTS makes CASCADE;
DROP TABLE IF EXISTS models CASCADE;
DROP TABLE IF EXISTS years CASCADE;

\i scripts/denormal_data.sql

CREATE TABLE makes (
  id serial PRIMARY KEY,
  make_code character varying(125) NOT NULL,
  make_title character varying(125) NOT NULL
);

CREATE TABLE models (
  model_id serial PRIMARY KEY,
  model_code character varying(125) NOT NULL,
  model_title character varying(125) NOT NULL,
  make_id integer REFERENCES makes(id)
);

CREATE TABLE years (
  id serial PRIMARY KEY,
  year integer NOT NULL,
  model_id integer REFERENCES models(model_id)
);

INSERT INTO makes(make_code, make_title)
SELECT DISTINCT ON (make_code) make_code, make_title
FROM car_models;

ALTER TABLE car_models ADD COLUMN make_id integer REFERENCES makes(id);

UPDATE car_models
SET make_id = (SELECT id FROM makes
WHERE makes.make_code = car_models.make_code);

ALTER TABLE car_models DROP COLUMN make_code;
ALTER TABLE car_models DROP COLUMN make_title;

INSERT INTO models(model_code, model_title)
SELECT DISTINCT ON (model_code) model_code, model_title
FROM car_models;

UPDATE models
SET make_id = (SELECT car_models.make_id FROM car_models
WHERE car_models.model_code = models.model_code
LIMIT 1);

ALTER TABLE car_models ADD COLUMN model_id integer REFERENCES models(model_id);

UPDATE car_models
SET model_id = (SELECT models.model_id FROM models
WHERE models.model_code = car_models.model_code);

ALTER TABLE car_models DROP COLUMN model_code;
ALTER TABLE car_models DROP COLUMN model_title;
ALTER TABLE car_models DROP COLUMN make_id;

INSERT INTO years(year)
SELECT DISTINCT ON (year) year FROM car_models;

ALTER TABLE car_models ADD COLUMN year_id integer REFERENCES years(id);

UPDATE car_models
SET year_id = (SELECT years.id FROM years
WHERE years.year = car_models.year);

ALTER TABLE car_models DROP COLUMN year;

\dS car_models

SELECT DISTINCT ON (make_title) make_title FROM makes
INNER JOIN models ON makes.id = models.make_id
INNER JOIN car_models ON models.model_id = car_models.model_id;

SELECT DISTINCT ON (model_title) model_title FROM models
INNER JOIN car_models ON models.model_id = car_models.model_id
INNER JOIN makes ON models.make_id = makes.id
WHERE makes.make_code = 'VOLKS';

SELECT make_code, model_code, model_title, year FROM car_models
INNER JOIN years ON car_models.year_id = years.id
INNER JOIN models ON car_models.model_id = models.model_id
INNER JOIN makes ON models.make_id = makes.id
WHERE makes.make_code = 'LAM';

SELECT * FROM car_models
INNER JOIN years ON car_models.year_id = years.id
INNER JOIN models ON car_models.model_id = models.model_id
INNER JOIN makes ON models.make_id = makes.id
WHERE years.year BETWEEN 2010 AND 2015;