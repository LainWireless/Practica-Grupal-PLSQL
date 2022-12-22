
--PROCEDIMIENTO PRINCIPAL

create or replace procedure GenerarInformes(p_num number, p_codcomunidad comunidades.codcomunidad%type, p_fecha date)
is
begin
    case
        when p_num = 1 then
            Tipo1(p_codcomunidad, p_fecha);
        when p_num = 2 then
            recibos_impagados(p_codcomunidad);
        when p_num = 3 then
            informe_de_propiedades(p_codcomunidad);
        end case;
exception
    when others then
        null;
end;
/


--Procedimiento informe_de_cargos (Tipo1) davidrg

create or replace procedure Tipo1(p_codcomunidad comunidades.codcomunidad%type, p_fecha date)
is
    contador number:=1;
begin
    comprobaciones(p_codcomunidad, p_fecha);
    dbms_output.put_line(chr(10)||'INFORME DE CARGOS:');
    infocomunidad(p_codcomunidad, p_fecha);
    informecomunidad(p_codcomunidad, p_fecha, contador);
    contador:=contador-1;
    dbms_output.put_line(chr(10)||chr(9)||'Numero de Directivos: '||contador);
exception
    when others then
        null;
end Tipo1;
/

create or replace procedure informecomunidad(p_codcomunidad comunidades.codcomunidad%type, p_fecha date, contador in out number)
is
    v_aux4 propietarios.nombre%type;
    v_aux5 propietarios.apellidos%type;
    v_aux6 propietarios.tlf_contacto%type;
    cursor v_cargos is select nombre_cargo, dni from historial_cargos where codcomunidad=p_codcomunidad and p_fecha between fecha_inicio and fecha_fin order by nombre_cargo;
begin
    for x in v_cargos loop
        datosdirectiva(x.dni, v_aux4, v_aux5, v_aux6);
        case contador
            when 1 then
                dbms_output.put_line(chr(10)||chr(9)||'Presidente D.'||v_aux4||' '||v_aux5||' '||v_aux6);
            when 2 then
                dbms_output.put_line(chr(10)||chr(9)||'Vicepresidente D.'||v_aux4||' '||v_aux5||' '||v_aux6);
                dbms_output.put_line(chr(10)||chr(9)||'Vocales:');
            when 3 then
                dbms_output.put_line(chr(10)||chr(9)||chr(9)||'D.'||v_aux4||' '||v_aux5||' '||v_aux6);
            when 4 then
                dbms_output.put_line(chr(10)||chr(9)||chr(9)||'D.'||v_aux4||' '||v_aux5||' '||v_aux6);
        end case;
        contador:=contador+1;
    end loop;
end informecomunidad;
/

create or replace procedure comprobaciones(p_codcomunidad comunidades.codcomunidad%type, p_fecha date)
is
    v_exception varchar2(10);
    Comunidad_noexiste exception;
    Nopropiedades_fecha exception;
begin
    select count(dni) into v_exception from historial_cargos where codcomunidad=p_codcomunidad;
    if v_exception=0 then
        raise Comunidad_noexiste;
    end if;
    select count(dni) into v_exception from historial_cargos where codcomunidad=p_codcomunidad and p_fecha between fecha_inicio and fecha_fin;
    if v_exception=0 then
        raise Nopropiedades_fecha;
    end if;
exception
    when Comunidad_noexiste then
        dbms_output.put_line('No existe esa comunidad.');
        raise;
    when Nopropiedades_fecha then
        dbms_output.put_line('No existen datos de esa comunidad en esa fecha.');
        raise;
end comprobaciones;
/

create or replace procedure infocomunidad(p_codcomunidad comunidades.codcomunidad%type, p_fecha date)
is
    v_aux1 varchar2(60);
    v_aux2 varchar2(60);
    v_aux3 varchar2(60);
begin
    select nombre into v_aux1 from comunidades where codcomunidad=p_codcomunidad;
    select poblacion into v_aux2 from comunidades where codcomunidad=p_codcomunidad;
    select codigopostal into v_aux3 from comunidades where codcomunidad=p_codcomunidad;
    dbms_output.put_line(chr(10)||chr(9)||'Comunidad: '||v_aux1);
    dbms_output.put_line(chr(10)||chr(9)||'Poblacion: '||v_aux2||chr(9)||'Codigo Postal: '||v_aux3);
    dbms_output.put_line(chr(10)||chr(9)||'Fecha: '||p_fecha);
end infocomunidad;
/

create or replace procedure datosdirectiva(x_dni historial_cargos.dni%type, v_aux4 out propietarios.nombre%type, v_aux5 out propietarios.apellidos%type, v_aux6 out propietarios.tlf_contacto%type)
is
begin
    select nombre into v_aux4 from propietarios where dni=x_dni;
    select apellidos into v_aux5 from propietarios where dni=x_dni;
    select tlf_contacto into v_aux6 from propietarios where dni=x_dni;
end datosdirectiva;
/


--Procedimiento recibos_impagados (Tipo2) -- Realizado por Alfonso Roldán

create or replace procedure recibos_impagados(p_codcomunidad comunidades.codcomunidad%type)
is
    cursor c_propietarios is
    select p.nombre as nombre, p.apellidos as apellidos, p.dni as dni from recibos_cuotas r, propietarios p where p.dni=r.dni and r.pagado='No' and r.codcomunidad=p_codcomunidad group by p.nombre, p.apellidos, p.dni order by sum(r.importe) desc;
    v_cont number := 1;
begin
    dbms_output.put_line(chr(10)||'INFORME DE RECIBOS IMPAGADOS'||chr(10)||chr(10)||'Comunidad: '||devolver_nombrecomunidad(p_codcomunidad)||chr(10));
    dbms_output.put_line(devolver_poblacioncomunidad(p_codcomunidad)||' '||devolver_codpostalcomunidad(p_codcomunidad)||chr(10));
    dbms_output.put_line('Fecha: '||devolver_fecha_actual||chr(10));
    for v_propietario in c_propietarios loop
        dbms_output.put_line('Propietario'||v_cont||': D.'||v_propietario.nombre||' '||v_propietario.apellidos||chr(10));
        listar_recibos_impagados_por_propietario(v_propietario.dni);
        dbms_output.put_line(chr(10)||'Total Adeudado D.'||v_propietario.nombre||' '||v_propietario.apellidos||': '||devolver_total_adeudado_propietario(v_propietario.dni)||chr(10));
        v_cont := v_cont+1;
    end loop;
    dbms_output.put_line('Total Adeudado en la Comunidad: '||devolver_total_adeudado_comunidad(p_codcomunidad));
end;
/


--Funciones y procedimientos dependientes 

create or replace function devolver_fecha_actual
return DATE
is
v_fecha_actual DATE;
begin
    select sysdate into v_fecha_actual from dual;
    return v_fecha_actual;
end;
/

create or replace function devolver_nombrecomunidad(p_codcomunidad comunidades.codcomunidad%type)
return comunidades.nombre%type
is
    v_nombrecomunidad comunidades.nombre%type;
begin
    select nombre into v_nombrecomunidad from comunidades where codcomunidad = p_codcomunidad;
    return v_nombrecomunidad;
end;
/


create or replace function devolver_poblacioncomunidad(p_codcomunidad comunidades.codcomunidad%type)
return comunidades.poblacion%type
is
    v_poblacion comunidades.poblacion%type;
begin
    select poblacion into v_poblacion from comunidades where codcomunidad = p_codcomunidad;
    return v_poblacion;
end;
/


create or replace function devolver_codpostalcomunidad(p_codcomunidad comunidades.codcomunidad%type)
return comunidades.codigopostal%type
is
    v_codpostal comunidades.codigopostal%type;
begin
    select codigopostal into v_codpostal from comunidades where codcomunidad = p_codcomunidad;
    return v_codpostal;
end;
/


CREATE OR REPLACE PROCEDURE listar_recibos_impagados_por_propietario(p_dni propietarios.dni%type)
IS
    cursor c_recibos is
    select numrecibo, fecha, importe from recibos_cuotas where dni=p_dni;
BEGIN
    for v_recibo in c_recibos loop
    dbms_output.put_line(chr(9)||v_recibo.numrecibo||chr(9)||v_recibo.fecha||chr(9)||v_recibo.importe);
    end loop;
END;
/


CREATE OR REPLACE function devolver_total_adeudado_propietario(p_dni propietarios.dni%type)
return varchar2
IS
    v_total varchar2(20);
BEGIN
    select TO_CHAR(sum(r.importe),'fm9,999.00') as importe into v_total from recibos_cuotas r, propietarios p where p.dni=r.dni and p.dni=p_dni;

    return v_total;
END;
/


CREATE OR REPLACE function devolver_total_adeudado_comunidad(p_codcomunidad comunidades.codcomunidad%type)
return varchar2
IS
    v_total varchar2(20);
BEGIN
    select TO_CHAR(sum(r.importe),'fm999,999.00') as importe into v_total from recibos_cuotas r where codcomunidad=p_codcomunidad;
    return v_total;
END;
/


--Procedimiento informe_de_propiedades (Tipo3). Realizado por Felipe, Iván y Alfonso.

create or replace procedure informe_de_propiedades(p_codcomunidad varchar2)
is
    cursor c_propietarios is
    select dni, nombre, apellidos from PROPIETARIOS where dni IN (select DNI_PROPIETARIO from PROPIEDADES where CODCOMUNIDAD = p_codcomunidad) order by nombre;
    v_cont number := 1;    
begin
    dbms_output.put_line(chr(10)||'INFORME DE PROPIEDADES'||chr(10)||chr(10)||'Comunidad: '||devolver_nombrecomunidad(p_codcomunidad)||chr(10));
    dbms_output.put_line(devolver_poblacioncomunidad(p_codcomunidad)||' '||devolver_codpostalcomunidad(p_codcomunidad)||chr(10));
    for v_propietario in c_propietarios loop
        dbms_output.put_line('Propietario'||v_cont||': D.'||v_propietario.nombre||' '||v_propietario.apellidos||chr(10));
        listar_porcentaje_participacion(v_propietario.dni);
        dbms_output.put_line(chr(10)||'Porcentaje de Participacion Total Propietario'||v_cont||': '||devolver_total_porcentaje_participacion(v_propietario.dni)||'%'||chr(10));
        v_cont := v_cont+1;
    end loop;
end;
/


--Funciones y procedimientos dependientes (Algunos de los requeridos los encontramos en el tipo2)

CREATE OR REPLACE FUNCTION devolver_tipopropiedad (p_codpropiedad VARCHAR2, p_codcomunidad VARCHAR2) RETURN VARCHAR2
IS
  v_tipopropiedad VARCHAR2(30);
BEGIN
  SELECT
    CASE
      WHEN EXISTS (SELECT 1 FROM oficinas WHERE codpropiedad = p_codpropiedad AND codcomunidad = p_codcomunidad) THEN 'Oficina'
      WHEN EXISTS (SELECT 1 FROM locales WHERE codpropiedad = p_codpropiedad AND codcomunidad = p_codcomunidad) THEN 'Local'
      WHEN EXISTS (SELECT 1 FROM viviendas WHERE codpropiedad = p_codpropiedad AND codcomunidad = p_codcomunidad) THEN 'Vivienda'
      ELSE 'Desconocido'
    END INTO v_tipopropiedad
  FROM DUAL;
  RETURN v_tipopropiedad;
END;
/

create or replace function devolver_inquilino(p_codpropiedad varchar2, p_codcomunidad varchar2) 
return varchar2
is
  v_inquilino varchar2(30);
begin
  select NOMBRE into v_inquilino
  from INQUILINOS
  where CODPROPIEDAD = p_codpropiedad and CODCOMUNIDAD = p_codcomunidad;
  return v_inquilino;
exception
    when no_data_found then
        v_inquilino:='"Ningun inquilino registrado"';
        return v_inquilino;
end;
/

create or replace procedure listar_porcentaje_participacion(p_dni varchar2)
is
    cursor c_propiedades is
    select codpropiedad, codcomunidad, portal, planta, letra, porcentaje_participacion
    from propiedades
    where DNI_PROPIETARIO = p_dni
    order by codpropiedad;
begin
    for v_propiedad in c_propiedades loop
    dbms_output.put_line(chr(9)||v_propiedad.codpropiedad||' '||devolver_tipopropiedad(v_propiedad.codpropiedad,v_propiedad.codcomunidad)||' '||v_propiedad.portal||' '||v_propiedad.planta||' '||v_propiedad.letra||' '||v_propiedad.porcentaje_participacion||' '||devolver_inquilino(v_propiedad.codpropiedad,v_propiedad.codcomunidad));
  end loop;
end;
/

create or replace function devolver_total_porcentaje_participacion(p_dni varchar2) 
return number
is
  v_total_porcentaje_participacion number;
begin
  select sum(porcentaje_participacion) into v_total_porcentaje_participacion
  from propiedades
  where DNI_PROPIETARIO = p_dni;
  return v_total_porcentaje_participacion;
end;
/
