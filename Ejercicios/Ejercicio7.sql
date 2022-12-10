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

--Trigger para controlar los contratos de mandatos
CREATE OR REPLACE TRIGGER Control_mandatos
BEFORE INSERT OR UPDATE ON CONTRATOS_DE_MANDATO
FOR EACH ROW
DECLARE
    INDICE2 NUMBER:=0;
    v_rfecha NUMBER;
BEGIN
    FOR v_cur in vmandatos.info_contratos_mandatos.FIRST.. vmandatos.info_contratos_mandatos.LAST LOOP
        select comprobar_fecha_mandatos(:NEW.FECHA_INICIO,0) into v_rfecha from dual;

        IF :NEW.NUMCOLEGIADO = vcargos.info_historial_cargos(INDICE2).NUMCOLEGIADO AND :NEW.CODCOMUNIDAD = vcargos.info_historial_cargos(INDICE2).CODCOMUNIDAD THEN
            IF :NEW.FECHA_INICIO >= vcargos.info_historial_cargos(INDICE2).FECHA_FINAL AND :NEW.FECHA_FIN <= vcargos.info_historial_cargos(INDICE2).FECHA_FIN THEN
                RAISE_APPLICATION_ERROR(-20001, 'Los Administradores solo pueden gestionar un máximo de 4 comunidades simultáneamente');
            END IF; 
	    END IF;
        INDICE2 := INDICE2 + 1;
    END LOOP;


END;
/

--Función para comprobar rangos de fechas
create or replace FUNCTION comprobar_fecha_mandatos(p_fecha in date, INDICE2 in NUMBER)
RETURN NUMBER
IS
	v_rfecha NUMBER;
BEGIN
    select 1 into v_rfecha from dual 
    WHERE p_fecha BETWEEN vmandatos.info_contratos_mandatos(INDICE2).fecha_inicio AND
    vmandatos.info_contratos_mandatos(INDICE2).fecha_final;
	if v_rfecha = 1 THEN
        RETURN v_rfecha;
    ELSE
        v_rfecha := 0;
        RETURN v_rfecha;
    END IF;
END;
/

