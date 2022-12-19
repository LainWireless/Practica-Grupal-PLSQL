
-- Procedimiento que dependiendo del número de propiedades
-- que tenga la comunidad, le asigna unos honorarios anuales u otros.
CREATE OR REPLACE PROCEDURE asignar_honorarios
IS
  CURSOR c_propiedades IS
  SELECT codcomunidad, COUNT(*) AS num_propiedades
  FROM propiedades
  GROUP BY codcomunidad;
BEGIN
  FOR rec IN c_propiedades LOOP
  IF rec.num_propiedades BETWEEN 1 AND 5 THEN
    UPDATE contratos_de_mandato SET honorarios_anuales = 600 WHERE codcomunidad = rec.codcomunidad;
  ELSIF rec.num_propiedades BETWEEN 6 AND 10 THEN
    UPDATE contratos_de_mandato SET honorarios_anuales = 1000 WHERE codcomunidad = rec.codcomunidad;
  ELSIF rec.num_propiedades BETWEEN 11 AND 20 THEN
    UPDATE contratos_de_mandato SET honorarios_anuales = 1800 WHERE codcomunidad = rec.codcomunidad;
  ELSIF rec.num_propiedades > 20 THEN
    UPDATE contratos_de_mandato SET honorarios_anuales = 2500 WHERE codcomunidad = rec.codcomunidad;
  END IF;
  END LOOP;
END;
/

-- Procedimiento que dependiendo del número de locales
-- que tenga la comunidad, le asigna un 20% más de honorarios anuales.
CREATE OR REPLACE PROCEDURE asignar_honorarios_locales
IS
  CURSOR c_locales IS
  SELECT codcomunidad, COUNT(*) AS num_locales
  FROM locales
  GROUP BY codcomunidad;
BEGIN
  FOR rec IN c_locales LOOP
  IF rec.num_locales > 0 THEN
    UPDATE contratos_de_mandato SET honorarios_anuales = honorarios_anuales * 1.2 WHERE codcomunidad = rec.codcomunidad;
  END IF;
  END LOOP;
END;
/

-- Procedimiento que dependiendo del número de oficinas
-- que tenga la comunidad, le asigna un 10% más de honorarios anuales.
CREATE OR REPLACE PROCEDURE asignar_honorarios_oficinas
IS
  CURSOR c_oficinas IS
  SELECT codcomunidad, COUNT(*) AS num_oficinas
  FROM oficinas
  GROUP BY codcomunidad;
BEGIN
  FOR rec IN c_oficinas LOOP
  IF rec.num_oficinas > 0 THEN
    UPDATE contratos_de_mandato SET honorarios_anuales = honorarios_anuales * 1.1 WHERE codcomunidad = rec.codcomunidad;
  END IF;
  END LOOP;
END;
/

-- Trigger que actualiza el valor de honorarios anuales 
-- cuando se inserta o actualiza un registro en la tabla contratos_de_mandato.
-- Utiliza los procedimientos asignar_honorarios, asignar_honorarios_locales y asignar_honorarios_oficinas.
CREATE OR REPLACE TRIGGER actualizar_honorarios
AFTER INSERT OR UPDATE ON contratos_de_mandato
FOR EACH ROW
BEGIN
  asignar_honorarios;
  asignar_honorarios_locales;
  asignar_honorarios_oficinas;
END;
/

-- Insertamos un registro en la tabla contratos_de_mandato.
INSERT INTO contratos_de_mandato VALUES('AA0009','472',TO_DATE('2016/01/15','YYYY/MM/DD'),TO_DATE('2017/01/15','YYYY/MM/DD'),420,'AAAA1');
