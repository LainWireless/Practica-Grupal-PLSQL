create or replace procedure ejercicio1_main (p_codcomunidad comunidades.codcomunidad%type, p_codpropiedad propiedades.codpropiedad%type)
is
  v_estado number;
begin
  v_estado:=ejercicio11(p_codcomunidad, p_codpropiedad);
  if v_estado = 1 then
    dbms_output.put_line('Estado del local: Abierto.');
  else
    dbms_output.put_line('Estado del local: Cerrado.');
  end if;
exception
  when others then
    null;
end ejercicio1_main;
/

create or replace function ejercicio11 (p_codcomunidad comunidades.codcomunidad%type, p_codpropiedad propiedades.codpropiedad%type)
return number
is
  p_resultado number;
begin
  comprobar_excepciones_ej1(p_codcomunidad, p_codpropiedad, p_resultado);
  select count(*) into p_resultado from horarios_apertura where codcomunidad=p_codcomunidad and codpropiedad=p_codpropiedad and to_char(LOCALTIMESTAMP, 'HH:MI:SS') between to_char(hora_apertura, 'HH:MI:SS') and to_char(hora_cierre, 'HH:MI:SS');
  return p_resultado;
end ejercicio11;
/

create or replace procedure comprobar_excepciones_ej1 (p_codcomunidad comunidades.codcomunidad%type, p_codpropiedad propiedades.codpropiedad%type, p_resultado in out number)
is
  No_comunidad exception;
  No_propiedad exception;
  No_comercial exception;
begin
  select count(*) into p_resultado from comunidades where codcomunidad=p_codcomunidad;
  if p_resultado = 0 then
    raise No_comunidad;
  end if;
  select count(*) into p_resultado from propiedades where codcomunidad=p_codcomunidad and codpropiedad = p_codpropiedad;
  if p_resultado = 0 then
    raise No_propiedad;
  end if;
  select count(*) into p_resultado from locales where codpropiedad=p_codpropiedad and codcomunidad=p_codcomunidad;
  if p_resultado = 0 then
    raise No_comercial;
  end if;
exception
  when No_comunidad then
    dbms_output.put_line('La comunidad introducida no existe.');
    raise;
  when No_propiedad then
    dbms_output.put_line('La propiedad introducida no existe en esa comunidad.');
    raise;
  when No_comercial then
    dbms_output.put_line('La propiedad introducida no es comercial.');
    raise;
end comprobar_excepciones_ej1;
/
