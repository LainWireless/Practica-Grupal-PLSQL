--Paquete de variables
CREATE OR REPLACE PACKAGE vcargos
AS

TYPE columnascargos IS RECORD
(
    CODCOMUNIDAD VARCHAR2(8),
    DNI VARCHAR2(9),
    FECHA_INICIO DATE,
    FECHA_FIN DATE
);

TYPE tablacargos IS TABLE OF columnascargos INDEX BY BINARY_INTEGER;

info_historial_cargos tablacargos;

v_status_table NUMBER;

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
        vcargos.info_historial_cargos(INDICE).FECHA_INICIO := v_cur.FECHA_INICIO;
        vcargos.info_historial_cargos(INDICE).FECHA_FIN := v_cur.FECHA_FIN;
        INDICE := INDICE + 1;
    END LOOP;
    select count(NOMBRE_CARGO) into VCARGOS.v_status_table from HISTORIAL_CARGOS;
END;
/

--Función para comprobar rangos de fechas
create or replace FUNCTION comprobar_fecha_cargos(p_fecha in date,INDICE2 in NUMBER,p_dni in VARCHAR2,p_codcomunidad in VARCHAR2)
RETURN NUMBER
IS
	v_rfecha NUMBER;
BEGIN
    select 1 into v_rfecha from dual 
    WHERE p_fecha BETWEEN vcargos.info_historial_cargos(INDICE2).fecha_inicio AND
    vcargos.info_historial_cargos(INDICE2).fecha_fin AND vcargos.info_historial_cargos(INDICE2).dni = p_dni AND vcargos.info_historial_cargos(INDICE2).CODCOMUNIDAD = p_codcomunidad;
	if v_rfecha = 1 THEN
        RETURN v_rfecha;
    ELSE
        v_rfecha := 0;
        RETURN v_rfecha;
    END IF;
END;
/

--Procedimiento validación cargos

create or replace procedure validacion_cargos(p_indice2 in out NUMBER, p_rfecha in out NUMBER, p_contador in out NUMBER)
IS
BEGIN
    IF p_rfecha = 1 THEN
        p_contador := p_contador + 1;
    END IF; 
    IF p_contador = 1 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Los propietarios solo pueden ocupar un cargo en la misma comunidad');
	END IF;
    p_indice2 := p_indice2 + 1;
END;
/

--Trigger para controlar los cargos
CREATE OR REPLACE TRIGGER Control_cargos
BEFORE INSERT OR UPDATE ON HISTORIAL_CARGOS
FOR EACH ROW
DECLARE
    INDICE2 NUMBER:=0;
    v_rfecha NUMBER;
    contador NUMBER:=0;
BEGIN
    IF VCARGOS.v_status_table > 0 THEN
        FOR v_cur in vcargos.info_historial_cargos.FIRST.. vcargos.info_historial_cargos.LAST LOOP
            select comprobar_fecha_cargos(:NEW.FECHA_INICIO,INDICE2,:NEW.DNI,:NEW.CODCOMUNIDAD) into v_rfecha from dual;
            validacion_cargos(INDICE2,v_rfecha,contador);
        END LOOP;
        contador := 0;
        vcargos.info_historial_cargos.DELETE;
    end if;
END;
/
