
-- Función que dependiendo del número de propiedades
-- que tenga la comunidad, le asigna unos honorarios anuales u otros.
CREATE OR REPLACE FUNCTION asignar_honorarios() RETURNS VOID
AS $$
DECLARE
  c_propiedades CURSOR FOR
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
$$ LANGUAGE plpgsql;


-- Función que dependiendo del número de locales
-- que tenga la comunidad, le asigna un 20% más de honorarios anuales.
CREATE OR REPLACE FUNCTION asignar_honorarios_locales() RETURNS VOID
AS $$
DECLARE
  c_locales CURSOR FOR
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
$$ LANGUAGE plpgsql;



-- Función que dependiendo del número de oficinas
-- que tenga la comunidad, le asigna un 10% más de honorarios anuales.
CREATE OR REPLACE FUNCTION asignar_honorarios_oficinas() RETURNS VOID
AS $$
DECLARE
  c_oficinas CURSOR FOR
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
$$ LANGUAGE plpgsql;



-- Función que actualiza el valor de honorarios anuales.
-- Utiliza las funciones asignar_honorarios, asignar_honorarios_locales y asignar_honorarios_oficinas.
CREATE OR REPLACE FUNCTION actualizar_honorarios() RETURNS VOID
AS $$
BEGIN
  PERFORM asignar_honorarios();
  PERFORM asignar_honorarios_locales();
  PERFORM asignar_honorarios_oficinas();
END;
$$ LANGUAGE plpgsql;
