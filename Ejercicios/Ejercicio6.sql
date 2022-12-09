select * from propietarios;
select * from HISTORIAL_CARGOS;
select * from comunidades;
describe HISTORIAL_CARGOS;


--Paquete de variables
CREATE OR REPLACE PACKAGE vcargos
AS

TYPE columnascargos IS RECORD
(
    CODCOMUNIDAD VARCHAR2(8),
    DNI VARCHAR2(9),
    FECHA_FIN DATE
);

TYPE tablacargos IS TABLE OF columnascargos INDEX BY BINARY_INTEGER;

info_historial_cargos tablacargos;

END;
/

--Trigger para rellenar las variables del paquete
CREATE OR REPLACE TRIGGER rellenarcolumnascargos
BEFORE INSERT or UPDATE on HISTORIAL_CARGOS
DECLARE
    cursor info_cargos IS select CODCOMUNIDAD,DNI,FECHA_INICIO,FECHA_FIN from HISTORIAL_CARGOS;
    INDICE NUMBER:=0;
BEGIN
    FOR v_cur in info_cargos LOOP
        vcargos.info_historial_cargos(INDICE).CODCOMUNIDAD := v_cur.CODCOMUNIDAD;
        vcargos.info_historial_cargos(INDICE).DNI := v_cur.DNI;
        vcargos.info_historial_cargos(INDICE).FECHA_FIN := v_cur.FECHA_FIN;
        INDICE := INDICE + 1;
    END LOOP;
END;
/

--Trigger para controlar los cargos
CREATE OR REPLACE TRIGGER Control_cargos
BEFORE INSERT OR UPDATE ON HISTORIAL_CARGOS
FOR EACH ROW
DECLARE
    INDICE2 NUMBER:=0;
BEGIN
	IF :NEW.CODCOMUNIDAD = vcargos.info_historial_cargos(INDICE2).CODCOMUNIDAD AND :NEW.DNI = vcargos.info_historial_cargos(INDICE2).DNI AND :NEW.FECHA_INICIO <= vcargos.info_historial_cargos(INDICE2).FECHA_FIN THEN
        RAISE_APPLICATION_ERROR(-20001, 'Los propietarios solo pueden ocupar un cargo en la misma comunidad');
    ELSIF :NEW.CODCOMUNIDAD = :OLD.CODCOMUNIDAD AND :NEW.DNI = :OLD.DNI AND :NEW.FECHA_INICIO <= :OLD.FECHA_FIN THEN
        RAISE_APPLICATION_ERROR(-20001, 'Los propietarios solo pueden ocupar un cargo en la misma comunidad');
	END IF;
    INDICE2 := INDICE2 + 1;
END;
/


--Pruebas

INSERT INTO HISTORIAL_CARGOS
VALUES('Presidente','AAAA1','49027387N',
TO_DATE('2018/01/15','YYYY/MM/DD'),TO_DATE('2019/01/15','YYYY/MM/DD'));
INSERT INTO HISTORIAL_CARGOS
VALUES('vocal','AAAA1','49027387N',
TO_DATE('2017/01/15','YYYY/MM/DD'),TO_DATE('2020/01/15','YYYY/MM/DD'));

delete from HISTORIAL_CARGOS;

delete from HISTORIAL_CARGOS where FECHA_FIN = TO_DATE('2019/01/15','YYYY/MM/DD');

select * from HISTORIAL_CARGOS;

drop TRIGGER Control_cargos;

BEGIN
    FOR v_cur in vcargos.info_historial_cargos.FIRST.. vcargos.info_historial_cargos.LAST LOOP
        dbms_output.put_line(vcargos.info_historial_cargos(v_cur).CODCOMUNIDAD);
        dbms_output.put_line(vcargos.info_historial_cargos(v_cur).DNI);
        dbms_output.put_line(vcargos.info_historial_cargos(v_cur).FECHA_FIN);
        dbms_output.put_line(' ');
    END LOOP;
END;
