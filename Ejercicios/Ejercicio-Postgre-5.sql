
-- Realizado por Iván.

-- Añade una columna ImportePendiente en la tabla Propietarios y rellénalo con la suma de los importes de los recibos pendientes de pago de cada propietario. Realiza los módulos de programación necesarios para que los datos de la columna sean siempre coherentes con los datos que se encuentran en la tabla Recibos.

--1.--Añadimos la columna ImportePendiente en la tabla Propietarios.

ALTER TABLE Propietarios ADD ImportePendiente NUMERIC(6);

--2.--Función para rellenar la nueva columna (ImportePendiente) con la suma de los importes de recibos no pagados de cada propietario.

--Funcion principal

CREATE OR REPLACE FUNCTION F_Rellenar_ImportePendiente()
RETURNS TRIGGER AS $$
DECLARE
c_propietarios CURSOR FOR
select DNI FROM Propietarios;
BEGIN
for v_propietario in c_propietarios loop
UPDATE Propietarios SET ImportePendiente=DevolverSumaImportePendientesDePago(v_propietario.dni) WHERE dni=v_propietario.dni;
END LOOP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Función que indicando un DNI de un propietario, nos devuelve la suma de los importes pendientes.

CREATE OR REPLACE FUNCTION DevolverSumaImportePendientesDePago(p_dni propietarios.dni%type)
RETURNS NUMERIC
AS $$
DECLARE
    v_sumimporte NUMERIC;
BEGIN 
    SELECT COALESCE(SUM(IMPORTE),0) AS importe INTO v_sumimporte FROM RECIBOS_CUOTAS WHERE PAGADO='No' AND DNI=p_dni;
    RETURN v_sumimporte;
END;
$$ LANGUAGE plpgsql;

--3.--Trigger para controlar que los datos de la columna ImportePendiente sean siempre coherentes con los datos que se encuentran en la tabla Recibos.

CREATE TRIGGER t_sync_importependiente
BEFORE INSERT OR UPDATE OR DELETE ON recibos_cuotas
FOR EACH ROW
EXECUTE PROCEDURE F_Rellenar_ImportePendiente();

drop trigger t_sync_importependiente on recibos_cuotas;
