
Añade una columna ImportePendiente en la tabla Propietarios y rellénalo con la suma de los importes de los recibos pendientes de pago de cada propietario. Realiza los módulos de programación necesarios para que los datos de la columna sean siempre coherentes con los datos que se encuentran en la tabla Recibos.

--1.--Añadimos la columna ImportePendiente en la tabla Propietarios.

ALTER TABLE Propietarios ADD ImportePendiente NUMBER(6);


--2.--Procedimiento para rellenar la nueva columna (ImportePendiente) con la suma de los importes de recibos no pagados de cada propietario.

--Procedimiento principal

CREATE OR REPLACE PROCEDURE Rellenar_ImportePendiente
IS 
cursor c_propietarios is
select DNI FROM Propietarios;
BEGIN
for v_propietario in c_propietarios loop
update Propietarios set ImportePendiente=DevolverSumaImportePendientesDePago(v_propietario.dni) where dni=v_propietario.dni;
end loop;
END;
/

--Función que indicando un DNI de un propietario, nos devuelve la suma de los importes pendientes.

CREATE OR REPLACE FUNCTION DevolverSumaImportePendientesDePago(p_dni propietarios.dni%type)
RETURN NUMBER
IS 
    v_sumimporte number;
BEGIN 
    select NVL(sum(importe),0) as importe into v_sumimporte from recibos_cuotas where pagado='No' and dni=p_dni;
RETURN v_sumimporte;
END;
/


--3.--Trigger para controlar que los datos de la columna ImportePendiente sean siempre coherentes con los datos que se encuentran en la tabla Recibos.

CREATE OR REPLACE TRIGGER sync_importependiente
after insert or update or delete on recibos_cuotas
BEGIN
    Rellenar_ImportePendiente;
END;
/


--4.--Prueba de funcionamiento de Trigger.

--En este caso insertaré algunos registros en la tabla recibos_cuotas, seleccionando el valor del campo "Pagado" a "No" y añadiendo el DNI de algún propietario que tenga el valor 0 en la columna "ImportePendiente" en este caso (Luisa).

--Inserción de datos.

INSERT INTO recibos_cuotas VALUES('0016','AAAA1','K6022994B',TO_DATE('2016/02/15','YYYY/MM/DD'),25,'No');
INSERT INTO recibos_cuotas VALUES('0017','AAAA1','K6022994B',TO_DATE('2016/02/15','YYYY/MM/DD'),25,'No');

--Realizamos la siguiente consulta y podremos ver como Luisa tiene el valor 50 en la columna "ImportePendiente".

select nombre, dni, importependiente from propietarios where dni='K6022994B';

--Por último, borraremos los registros anteriores y volveremos a realizar la consulta anterior para comprobar como "Luisa" tiene el valor 0 en la columna "ImportePendiente".

DELETE FROM RECIBOS_CUOTAS WHERE NUMRECIBO=0016;
DELETE FROM RECIBOS_CUOTAS WHERE NUMRECIBO=0017;

