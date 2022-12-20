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

v_status_table NUMBER;

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
    select count(CODCONTRATO) into vmandatos.v_status_table from CONTRATOS_DE_MANDATO;
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

--Procedimiento validación mandatos

create or replace procedure validacion_mandatos(p_indice2 in out NUMBER, p_rfecha in out NUMBER, p_contador in out NUMBER)
IS
BEGIN
    IF p_rfecha = 1 THEN
        p_contador := p_contador + 1;
        END IF; 
    IF p_contador = 4 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Los Administradores solo pueden gestionar un máximo de 4 comunidades simultáneamente');
	END IF;
    p_indice2 := p_indice2 + 1;
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
    IF vmandatos.v_status_table > 0 THEN
        FOR v_cur in vmandatos.info_contratos_mandatos.FIRST.. vmandatos.info_contratos_mandatos.LAST LOOP
            select comprobar_fecha_mandatos(:NEW.FECHA_INICIO,INDICE2,:NEW.NUMCOLEGIADO) into v_rfecha from dual;
            validacion_mandatos(INDICE2,v_rfecha,contador);
        END LOOP;
        contador := 0;
        vmandatos.info_contratos_mandatos.DELETE;
    end if;
END;
/
