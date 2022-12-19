create or replace procedure GenerarInformes(p_num1 number, p_num2 varchar2, p_num3 date)
is
begin
    case p_num1
        when 1 then
            dbms_output.put_line(chr(10)||chr(9)||'INFORME DE CARGOS');
            Tipo1(p_num2, p_num3);
        when 2 then
            dbms_output.put_line(chr(10)||chr(9)||'INFORME DE RECIBOS IMPAGADOS');
            Tipo2(p_num2);
        when 3 then
            dbms_output.put_line(chr(10)||chr(9)||'INFORME DE PROPIEDADES');
            Tipo3(p_num2);
        end case;
exception
    when others then
        null;
end GenerarInformes;
/

create or replace procedure Tipo1(p_num2 varchar2, p_num3 date)
is
begin
exception
end Tipo1;
/

create or replace procedure Tipo2(p_num2 varchar2)
is
begin
exception
end Tipo2;
/

create or replace procedure Tipo3(p_num2 varchar2)
is
begin
exception
end Tipo3;
/

