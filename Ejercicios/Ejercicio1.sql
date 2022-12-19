CREATE OR REPLACE PROCEDURE ejercicio1 (p_codcomunidad IN comunidades.codcomunidad%type, p_codpropiedad IN propiedades.codpropiedad%type)
RETURN NUMBER
IS
  p_resultado VARCHAR2(20);
  No_comunidad EXCEPTION;
  No_propiedad EXCEPTION;
  No_comercial EXCEPTION;
BEGIN
  -- Comprobar si existe la comunidad
  SELECT COUNT(*) INTO p_resultado FROM comunidades WHERE codcomunidad = p_codcomunidad;
  IF p_resultado = 0 THEN
   -- RAISE_APPLICATION_ERROR(-20001, 'La comunidad introducida no existe');
    RAISE No_comunidad;
  END IF;
  -- Comprobar si existe la propiedad en esa comunidad
  SELECT COUNT(*) INTO p_resultado FROM propiedades WHERE codcomunidad = p_codcomunidad AND codpropiedad = p_codpropiedad;
  IF p_resultado = 0 THEN
   -- RAISE_APPLICATION_ERROR(-20002, 'La propiedad introducida no existe en esa comunidad');
    RAISE No_propiedad;
  END IF;
  -- Comprobar si la propiedad es un local comercial
  SELECT COUNT(*) into p_resultado from locales WHERE codpropiedad = p_codpropiedad;
  IF p_resultado = 0 THEN
   -- RAISE_APPLICATION_ERROR(-20003, 'La propiedad introducida no es comercial');
    RAISE No_comercial;
  END IF;
  -- Obtener el estado del local
  SELECT COUNT(*) INTO p_resultado FROM horarios WHERE codpropiedad = p_codpropiedad AND SYSDATE BETWEEN hora_apertura AND hora_cierre;
  -- Devolver el resultado
  RETURN p_resultado;
EXCEPTION
  WHEN No_comunidad then
    DBMS_OUTPUT.PUT_LINE('La comunidad introducida no existe');
    RAISE;
  WHEN No_propiedad then
    DBMS_OUTPUT.PUT_LINE('La propiedad introducida no existe en esa comunidad');
    RAISE;
  WHEN No_comercial then
    DBMS_OUTPUT.PUT_LINE('La propiedad introducida no es comercial');
    RAISE;
END ejercicio1;
/


CREATE OR REPLACE PROCEDURE ejercicio1_main (p_codcomunidad IN comunidades.codcomunidad%type, p_codpropiedad IN propiedades.codpropiedad%type)
IS
  v_estado NUMBER;
BEGIN
  v_estado:=ejercicio1(p_codcomunidad, p_codpropiedad);
  IF v_estado = 1 THEN
    DBMS_OUTPUT.PUT_LINE('Estado del local: Abierto');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Estado del local: Cerrado');
  END IF;
END ejercicio1_main;
/










