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

INSERT INTO years(year)
SELECT DISTINCT ON (year) year FROM car_models;

ALTER TABLE car_models ADD COLUMN year_id integer REFERENCES years(id);

UPDATE car_models
SET year_id = (SELECT years.id FROM years
WHERE years.year = car_models.year);

ALTER TABLE car_models DROP COLUMN year;

\dS car_models

SELECT DISTINCT ON (make_title) make_title FROM makes
INNER JOIN car_models ON makes.id = car_models.make_id;