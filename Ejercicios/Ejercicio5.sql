Añade una columna ImportePendiente en la tabla Propietarios y rellénalo con la suma de los importes de los 
recibos pendientes de pago de cada propietario. Realiza los módulos de programación necesarios para que los 
datos de la columna sean siempre coherentes con los datos que se encuentran en la tabla Recibos.

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