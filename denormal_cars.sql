\c test

CREATE USER denormal_user;

CREATE DATABASE denormal_cars OWNER denormal_user;

\c denormal_cars

\i scripts/denormal_data.sql

\dS car_models

SELECT DISTINCT ON (make_title) make_title FROM car_models;

SELECT DISTINCT ON (model_title) model_title FROM car_models
WHERE make_code = 'VOLKS';

SELECT make_code, model_code, model_title, year FROM car_models
WHERE make_code = 'LAM';

SELECT * FROM car_models WHERE year BETWEEN 2010 AND 2015;