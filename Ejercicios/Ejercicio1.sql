create or replace function ejercicio1 (p_codcomunidad comunidades.codcomunidad%type, p_codpropiedad propiedades.codpropiedad%type)
return number
is
  p_resultado number;
  No_comunidad exception;
  No_propiedad exception;
  No_comercial exception;
begin
  -- Comprobar si existe la comunidad
  select count(*) into p_resultado from comunidades where codcomunidad = p_codcomunidad;
  if p_resultado = 0 then
   -- RAISE_APPLICATION_ERROR(-20001, 'La comunidad introducida no existe');
    raise No_comunidad;
  end if;
  -- Comprobar si existe la propiedad en esa comunidad
  select count(*) into p_resultado from propiedades where codcomunidad = p_codcomunidad and codpropiedad = p_codpropiedad;
  if p_resultado = 0 then
   -- RAISE_APPLICATION_ERROR(-20002, 'La propiedad introducida no existe en esa comunidad');
    raise No_propiedad;
  end if;
  -- Comprobar si la propiedad es un local comercial
  select count(*) into p_resultado from locales where codpropiedad = p_codpropiedad;
  if p_resultado = 0 then
   -- RAISE_APPLICATION_ERROR(-20003, 'La propiedad introducida no es comercial');
    raise No_comercial;
  end if;
  -- Obtener el estado del local
  select count(*) into p_resultado from horarios where codpropiedad = p_codpropiedad and sysdate between hora_apertura and hora_cierre;
  -- Devolver el resultado
  return p_resultado;
exception
  when No_comunidad then
    dbms_output.put_line('La comunidad introducida no existe');
    raise;
  when No_propiedad then
    dbms_output.put_line('La propiedad introducida no existe en esa comunidad');
    raise;
  when No_comercial then
    dbms_output.put_line('La propiedad introducida no es comercial');
    raise;
end ejercicio1;
/


create or replace procedure ejercicio1_main (p_codcomunidad comunidades.codcomunidad%type, p_codpropiedad propiedades.codpropiedad%type)
is
  v_estado number;
begin
  v_estado:=ejercicio1(p_codcomunidad, p_codpropiedad);
  if v_estado = 1 then
    dbms_output.put_line('Estado del local: Abierto.');
  else
    dbms_output.put_line('Estado del local: Cerrado.');
  end if;
end ejercicio1_main;
/










