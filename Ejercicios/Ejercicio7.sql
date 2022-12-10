--Paquete de variables
CREATE OR REPLACE PACKAGE vmandatos
AS

TYPE columnasmandatos IS RECORD
(
    NUMCOLEGIADO VARCHAR2(5),
    CODCOMUNIDAD VARCHAR2(8),
    FECHA_INICIO DATE,
    FECHA_FINAL DATE
);

TYPE tablamandatos IS TABLE OF columnasmandatos INDEX BY BINARY_INTEGER;

info_contratos_mandatos tablamandatos;

END;
/

--Trigger para rellenar las variables del paquete
CREATE OR REPLACE TRIGGER rellenarcolumnasmandatos
BEFORE INSERT or UPDATE on CONTRATOS_DE_MANDATO
DECLARE
    cursor info_mandatos IS select NUMCOLEGIADO,CODCOMUNIDAD,FECHA_INICIO,FECHA_FINAL from CONTRATOS_DE_MANDATO;
    INDICE NUMBER:=0;
BEGIN
    FOR v_cur in info_mandatos LOOP
        vmandatos.info_contratos_mandatos(INDICE).NUMCOLEGIADO := v_cur.NUMCOLEGIADO;
        vmandatos.info_contratos_mandatos(INDICE).CODCOMUNIDAD := v_cur.CODCOMUNIDAD;
        vmandatos.info_contratos_mandatos(INDICE).FECHA_INICIO := v_cur.FECHA_INICIO;
        vmandatos.info_contratos_mandatos(INDICE).FECHA_FINAL := v_cur.FECHA_FINAL;
        INDICE := INDICE + 1;
    END LOOP;
END;
/

--Función para comprobar rangos de fechas
create or replace FUNCTION comprobar_fecha_mandatos(p_fecha in date,INDICE2 in NUMBER,p_colegiado in VARCHAR2)
RETURN NUMBER
IS
	v_rfecha NUMBER;
BEGIN
    select 1 into v_rfecha from dual 
    WHERE p_fecha BETWEEN vmandatos.info_contratos_mandatos(INDICE2).fecha_inicio AND
    vmandatos.info_contratos_mandatos(INDICE2).fecha_final AND vmandatos.info_contratos_mandatos(INDICE2).numcolegiado = p_colegiado ;
	if v_rfecha = 1 THEN
        RETURN v_rfecha;
    ELSE
        v_rfecha := 0;
        RETURN v_rfecha;
    END IF;
END;
/

--Trigger para controlar los contratos de mandatos
CREATE OR REPLACE TRIGGER Control_mandatos
BEFORE INSERT OR UPDATE ON CONTRATOS_DE_MANDATO
FOR EACH ROW
DECLARE
    INDICE2 NUMBER:=0;
    v_rfecha NUMBER;
    contador NUMBER:=0;
BEGIN
    FOR v_cur in vmandatos.info_contratos_mandatos.FIRST.. vmandatos.info_contratos_mandatos.LAST LOOP
        select comprobar_fecha_mandatos(:NEW.FECHA_INICIO,INDICE2,:NEW.NUMCOLEGIADO) into v_rfecha from dual;
        IF v_rfecha = 1 THEN
            contador := contador + 1;
        END IF; 
        IF contador = 4 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Los Administradores solo pueden gestionar un máximo de 4 comunidades simultáneamente');
	    END IF;
        INDICE2 := INDICE2 + 1;
    END LOOP;
    contador := 0;
    vmandatos.info_contratos_mandatos.DELETE;
END;
/

--Pruebas

INSERT INTO contratos_de_mandato
VALUES('AA0015','812',TO_DATE('2018/01/19','YYYY/MM/DD'),
TO_DATE('2019/01/20','YYYY/MM/DD'),420,'AAAA1');

INSERT INTO contratos_de_mandato
VALUES('AA0016','812',TO_DATE('2018/01/19','YYYY/MM/DD'),
TO_DATE('2019/01/20','YYYY/MM/DD'),420,'AAAA2');

INSERT INTO contratos_de_mandato
VALUES('AA0017','812',TO_DATE('2018/01/19','YYYY/MM/DD'),
TO_DATE('2019/01/20','YYYY/MM/DD'),420,'AAAA3');

INSERT INTO contratos_de_mandato
VALUES('AA0018','389',TO_DATE('2018/01/19','YYYY/MM/DD'),
TO_DATE('2019/01/20','YYYY/MM/DD'),420,'AAAA4');

INSERT INTO contratos_de_mandato
VALUES('AA0010','472',TO_DATE('2018/01/19','YYYY/MM/DD'),
TO_DATE('2019/01/20','YYYY/MM/DD'),420,'AAAA1');

INSERT INTO contratos_de_mandato
VALUES('AA0011','472',TO_DATE('2018/01/19','YYYY/MM/DD'),
TO_DATE('2019/01/20','YYYY/MM/DD'),420,'AAAA2');

INSERT INTO contratos_de_mandato
VALUES('AA0012','472',TO_DATE('2018/01/19','YYYY/MM/DD'),
TO_DATE('2019/01/20','YYYY/MM/DD'),420,'AAAA3');

INSERT INTO contratos_de_mandato
VALUES('AA0013','472',TO_DATE('2018/01/19','YYYY/MM/DD'),
TO_DATE('2019/01/20','YYYY/MM/DD'),420,'AAAA4');

INSERT INTO contratos_de_mandato
VALUES('AA0014','472',TO_DATE('2018/01/19','YYYY/MM/DD'),
TO_DATE('2019/01/20','YYYY/MM/DD'),420,'AAAA5');

delete from CONTRATOS_DE_MANDATO where FECHA_INICIO = TO_DATE('2018/01/19','YYYY/MM/DD');

drop TRIGGER Control_mandatos;

BEGIN
    FOR v_cur in vmandatos.info_contratos_mandatos.FIRST.. vmandatos.info_contratos_mandatos.LAST LOOP
        dbms_output.put_line(vmandatos.info_contratos_mandatos(v_cur).NUMCOLEGIADO);
        dbms_output.put_line(vmandatos.info_contratos_mandatos(v_cur).CODCOMUNIDAD);
        dbms_output.put_line(vmandatos.info_contratos_mandatos(v_cur).FECHA_INICIO);
        dbms_output.put_line(vmandatos.info_contratos_mandatos(v_cur).FECHA_FINAL);
        dbms_output.put_line(' ');
    END LOOP;
END;

BEGIN
    vmandatos.info_contratos_mandatos.DELETE;
END;

select * from CONTRATOS_DE_MANDATO;
describe CONTRATOS_DE_MANDATO;