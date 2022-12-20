create or replace procedure GenerarInformes(p_num number, p_codcomunidad comunidades.codcomunidad%type, p_fecha date)
is
begin
    case
        when p_num = 1 then
            informe_de_cargos(p_codcomunidad, p_fecha);
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


--Procedimiento informe_de_cargos (Tipo1)

create or replace procedure informe_de_cargos(p_codcomunidad varchar2, p_fecha date)
is
begin
    dbms_output.put_line(chr(10)||'INFORME DE CARGOS');
exception
end;
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


--PROCEDIMIENTOS Y FUNCIONES DEPENDIENTES 

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


--Procedimiento informe_de_propiedades (Tipo3)

create or replace procedure informe_de_propiedades(p_codcomunidad varchar2)
is
begin
    dbms_output.put_line(chr(10)||'INFORME DE PROPIEDADES');
exception
end;
/




