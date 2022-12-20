-- Felipe ha ayudado en su realización proporcionando supervisión y dando consejos.
-- También se ha prestado a explicarme detalladamente como funcionan los ejercicios de 
-- tablas mutantes que él ya ha realizado. Gracias a esto, yo he podido realizar este 
-- ejercicio con mucha más facilidad.

-- Paquete para guardar las variables de la tabla recibos_cuotas:
CREATE OR REPLACE PACKAGE vrecibo
AS
TYPE columnasrecibo IS RECORD
(
    CODCOMUNIDAD VARCHAR2(8),
    DNI VARCHAR2(9),
    FECHA DATE,
    IMPORTE NUMBER,
    PAGADO VARCHAR2(2)
);
TYPE tablarecibo IS TABLE OF columnasrecibo INDEX BY BINARY_INTEGER;
info_recibo tablarecibo;
v_status_table NUMBER;
END;
/


-- Trigger que rellena el paquete con los datos de la tabla recibos_cuotas:
CREATE OR REPLACE TRIGGER rellenarcolumnasrecibo
BEFORE INSERT or UPDATE on recibos_cuotas
DECLARE
    cursor info_recibo IS select CODCOMUNIDAD,DNI,FECHA,IMPORTE,PAGADO from recibos_cuotas;
    INDICE NUMBER:=0;
BEGIN
    FOR v_cur in info_recibo LOOP
        vrecibo.info_recibo(INDICE).CODCOMUNIDAD := v_cur.CODCOMUNIDAD;
        vrecibo.info_recibo(INDICE).DNI := v_cur.DNI;
        vrecibo.info_recibo(INDICE).FECHA := v_cur.FECHA;
        vrecibo.info_recibo(INDICE).IMPORTE := v_cur.IMPORTE;
        vrecibo.info_recibo(INDICE).PAGADO := v_cur.PAGADO;
        INDICE := INDICE + 1;
    END LOOP;
    vrecibo.v_status_table := INDICE;
END;
/

-- Función para comprobar fechas de recibos:
CREATE OR REPLACE FUNCTION comprobar_fecha_recibos(p_fecha in date,INDICE2 in NUMBER,p_dni in VARCHAR2,p_codcomunidad in VARCHAR2)
RETURN NUMBER
IS
    v_rfecha NUMBER;
BEGIN
    select 1 into v_rfecha from dual 
    WHERE p_fecha BETWEEN vrecibo.info_recibo(INDICE2).fecha AND
    vrecibo.info_recibo(INDICE2).fecha + 30 AND vrecibo.info_recibo(INDICE2).dni = p_dni AND vrecibo.info_recibo(INDICE2).CODCOMUNIDAD = p_codcomunidad;
    if v_rfecha = 1 THEN
        RAISE_APPLICATION_ERROR(-20001,'No se puede emitir un recibo a un propietario en menos de 30 días.');
    END IF;
END;
/

-- Trigger que compruebe que no se emita un recibo a un propietario en menos de 30 días:
CREATE OR REPLACE TRIGGER tr_recibos_cuotas
BEFORE INSERT OR UPDATE ON recibos_cuotas
FOR EACH ROW
DECLARE
    INDICE2 NUMBER:=0;
    v_rfecha NUMBER;
    contador NUMBER:=0;
BEGIN
    IF vrecibo.v_status_table > 0 THEN
        FOR v_cur in vrecibo.info_recibo.FIRST.. vrecibo.info_recibo.LAST LOOP
            select comprobar_fecha_recibos(:NEW.FECHA,INDICE2,:NEW.DNI,:NEW.CODCOMUNIDAD) into v_rfecha from dual;
        END LOOP;
        contador := 0;
        vrecibo.info_recibo.DELETE;
    end if;
END;
/

-- Comprobamos que no se puede emitir un recibo a un propietario en menos de 30 días.
INSERT INTO recibos_cuotas VALUES('0030','AAAA1','50765614Z',TO_DATE('2016/02/17','YYYY/MM/DD'),25,'Si');
INSERT INTO recibos_cuotas VALUES('0030','AAAA1','50765614Z',TO_DATE('2022/02/17','YYYY/MM/DD'),25,'Si');
INSERT INTO recibos_cuotas VALUES('0032','AAAA1','50765614Z',TO_DATE('2022/02/28','YYYY/MM/DD'),25,'Si');
