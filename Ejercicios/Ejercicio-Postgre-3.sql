-- Realizado por Iván.

-- Procedimiento que dependiendo del número de propiedades
-- que tenga la comunidad, le asigna unos honorarios anuales u otros.

CREATE OR REPLACE PROCEDURE p_asignar_honorarios()
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

-- Procedimiento que dependiendo del número de locales
-- que tenga la comunidad, le asigna un 20% más de honorarios anuales.

CREATE OR REPLACE PROCEDURE p_asignar_honorarios_locales()
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


-- Procedimiento que dependiendo del número de oficinas
-- que tenga la comunidad, le asigna un 10% más de honorarios anuales.

CREATE OR REPLACE PROCEDURE p_asignar_honorarios_oficinas()
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



-- Procedimiento que actualiza el valor de honorarios anuales.
-- Utiliza los procedimientos asignar_honorarios, asignar_honorarios_locales y asignar_honorarios_oficinas.

CREATE OR REPLACE PROCEDURE p_actualizar_honorarios()
AS $$
BEGIN
  call p_asignar_honorarios();
  call p_asignar_honorarios_locales();
  call p_asignar_honorarios_oficinas();
END;
$$ LANGUAGE plpgsql;


-- Función que comprueba que el valor introducido en honorarios anuales es correcto:
CREATE OR REPLACE FUNCTION comprobar_honorarios_anuales(p_codcomunidad in VARCHAR(4000))
RETURNS INT
AS $$
DECLARE
  v_honorarios_anuales INT;
  v_num_propiedades INT;
BEGIN
  SELECT COUNT(*) INTO v_num_propiedades FROM propiedades WHERE codcomunidad = p_codcomunidad;
  IF v_num_propiedades BETWEEN 1 AND 5 THEN
    v_honorarios_anuales:= 600;
  ELSIF v_num_propiedades BETWEEN 6 AND 10 THEN
    v_honorarios_anuales:= 1000;
  ELSIF v_num_propiedades BETWEEN 11 AND 20 THEN
    v_honorarios_anuales:= 1800;
  ELSIF v_num_propiedades > 20 THEN
    v_honorarios_anuales:= 2500;
  END IF;
  RETURN v_honorarios_anuales;
END;
$$ LANGUAGE plpgsql;


-- Función que comprueba que el valor introducido en honorarios anuales es correcto dependiendo del número de locales.
CREATE OR REPLACE FUNCTION comprobar_honorarios_locales(p_codcomunidad in VARCHAR(4000))
RETURNS INT
AS $$
DECLARE
  v_honorarios_locales INT;
  v_num_locales INT;
BEGIN
  SELECT COUNT(*) INTO v_num_locales FROM locales WHERE codcomunidad = p_codcomunidad;
  IF v_num_locales > 0 THEN
    v_honorarios_locales:= 1.2;
  END IF;
  RETURN v_honorarios_locales;
END;
$$ LANGUAGE plpgsql;


-- Función que comprueba que el valor introducido en honorarios anuales es correcto dependiendo del número de oficinas.
CREATE OR REPLACE FUNCTION comprobar_honorarios_oficinas(p_codcomunidad in VARCHAR(4000))
RETURNS INT
AS $$
DECLARE
  v_honorarios_oficinas INT;
  v_num_oficinas INT;
BEGIN
  SELECT COUNT(*) INTO v_num_oficinas FROM oficinas WHERE codcomunidad = p_codcomunidad;
  IF v_num_oficinas > 0 THEN
    v_honorarios_oficinas:= 1.1;
  END IF;
  RETURN v_honorarios_oficinas;
END;
$$ LANGUAGE plpgsql;



-- Función para el trigger que comprueba que el valor introducido en honorarios anuales es correcto.
-- Utiliza las funciones comprobar_honorarios, comprobar_honorarios_locales y comprobar_honorarios_oficinas.
CREATE OR REPLACE FUNCTION comprobar_honorarios() 
RETURNS TRIGGER 
AS $$
  DECLARE
    v_honorarios_anuales INT;
    v_honorarios_locales INT;
    v_honorarios_oficinas INT;
  BEGIN
    SELECT comprobar_honorarios_anuales(new.codcomunidad) INTO v_honorarios_anuales;
    SELECT comprobar_honorarios_locales(new.codcomunidad) INTO v_honorarios_locales;
    SELECT comprobar_honorarios_oficinas(new.codcomunidad) INTO v_honorarios_oficinas;
    IF new.honorarios_anuales <> v_honorarios_anuales * v_honorarios_locales * v_honorarios_oficinas THEN
      RAISE EXCEPTION 'El valor de honorarios anuales no es correcto.';
    END IF;
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;


-- Trigger que compruebe que el valor introducido en honorarios anuales es correcto.
-- Utiliza la función comprobar_honorarios.
CREATE TRIGGER t_comprobar_honorarios 
BEFORE INSERT OR UPDATE ON contratos_de_mandato
FOR EACH ROW
EXECUTE PROCEDURE comprobar_honorarios();
