-- Realizado por Iván.
-- Felipe ha ayudado en su realización proporcionando supervisión y dando consejos.

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

-- Procedimiento que actualiza el valor de honorarios anuales.
-- Utiliza los procedimientos asignar_honorarios, asignar_honorarios_locales y asignar_honorarios_oficinas.
CREATE OR REPLACE PROCEDURE actualizar_honorarios
IS
BEGIN
  asignar_honorarios;
  asignar_honorarios_locales;
  asignar_honorarios_oficinas;
END;
/


-- Función que comprueba que el valor introducido en honorarios anuales es correcto.
CREATE OR REPLACE FUNCTION comprobar_honorarios_anuales(p_codcomunidad in VARCHAR2)
RETURN NUMBER
IS
  v_honorarios_anuales NUMBER;
  v_num_propiedades NUMBER;
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
/



-- Función que comprueba que el valor introducido en honorarios anuales es correcto dependiendo del número de locales.
CREATE OR REPLACE FUNCTION comprobar_honorarios_locales(p_codcomunidad in VARCHAR2)
RETURN NUMBER
IS
  v_honorarios_locales NUMBER;
  v_num_locales NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_num_locales FROM locales WHERE codcomunidad = p_codcomunidad;
  IF v_num_locales > 0 THEN
    v_honorarios_locales:= 1.2;
  END IF;
  RETURN v_honorarios_locales;
END;
/



-- Función que comprueba que el valor introducido en honorarios anuales es correcto dependiendo del número de oficinas.
CREATE OR REPLACE FUNCTION comprobar_honorarios_oficinas(p_codcomunidad in VARCHAR2)
RETURN NUMBER
IS
  v_honorarios_oficinas NUMBER;
  v_num_oficinas NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_num_oficinas FROM oficinas WHERE codcomunidad = p_codcomunidad;
  IF v_num_oficinas > 0 THEN
    v_honorarios_oficinas:= 1.1;
  END IF;
  RETURN v_honorarios_oficinas;
END;
/


-- Trigger que compruebe que el valor introducido en honorarios anuales es correcto.
-- Utiliza las funciones comprobar_honorarios, comprobar_honorarios_locales y comprobar_honorarios_oficinas.
CREATE OR REPLACE TRIGGER t_comprobar_honorarios
BEFORE INSERT OR UPDATE ON contratos_de_mandato
FOR EACH ROW
DECLARE
  v_honorarios_anuales NUMBER;
  v_honorarios_locales NUMBER;
  v_honorarios_oficinas NUMBER;
BEGIN
  v_honorarios_anuales:= comprobar_honorarios_anuales(:new.codcomunidad);
  v_honorarios_locales:= comprobar_honorarios_locales(:new.codcomunidad);
  v_honorarios_oficinas:= comprobar_honorarios_oficinas(:new.codcomunidad);
  IF :new.honorarios_anuales <> v_honorarios_anuales * v_honorarios_locales * v_honorarios_oficinas THEN
    RAISE_APPLICATION_ERROR(-20001, 'El valor de honorarios anuales no es correcto.');
  END IF;
END;
/

