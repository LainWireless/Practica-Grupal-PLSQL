
Realiza los módulos de programación necesarios para que cuando se abone un recibo que lleve más de un año 
impagado se avise por correo electrónico al presidente de la comunidad y al administrador que tiene un contrato de 
mandato vigente con la comunidad correspondiente. Añade el campo e-mail tanto a la tabla Propietarios como 
Administradores.

--Añadimos la columna email en la tabla Propietarios.

ALTER TABLE Propietarios 
ADD email VARCHAR2(255)
CONSTRAINT check_email_propietarios CHECK (LOWER (email) LIKE '%@%');


--Añadimos la columna email en la tabla Administradores.

ALTER TABLE Administradores
ADD email VARCHAR2(255)
CONSTRAINT check_email_administradores CHECK (LOWER (email) LIKE '%@%');


--Actualización de datos (email) en las tabla Propietarios.

--Primero realizaremos una consulta para mostrar los DNI y Nombre de los Propietarios que sean "Presidente".

SELECT p.DNI, Nombre 
FROM Propietarios p, historial_cargos h
WHERE p.DNI=h.DNI and h.nombre_cargo='Presidente';

--Realizamos una serie de actualizaciones en la columna "email" de la tabla "propietarios" sobre los resultados obtenidos en la consulta anterior.v_propietario.dni
--Como el nombre de cada correo es totalmente distinto, este proceso de asignación se realiza manualmente.

update Propietarios set email='rosa@iesgn.com' where dni='09291497A';
update Propietarios set email='josemanuel@iesgn.com' where dni='49027387N';
update Propietarios set email='laura@iesgn.com' where dni='71441529X';


--Actualización de datos (email) en las tabla Administradores.

--En este caso aplicamos la actualización a todos los Administradores.

update Administradores set email='adminelisa@iesgn.com' where dni='52801993L';
update Administradores set email='adminjosemanuel@iesgn.com' where dni='27449907M';
update Administradores set email='admincarlos@iesgn.com' where dni='23229790C';
update Administradores set email='admintomas@iesgn.com' where dni='23229791T';


--Trigger principal

CREATE OR REPLACE TRIGGER recibo_mas_de_un_ano_impagado
before insert on recibos_cuotas
for each row
DECLARE
BEGIN
if (Devolver_ano_actual - Devolver_ano(:new.fecha)) > 1 then
    :new.comunidad

end if;
END;
/


--Función que devuelve el año actual

CREATE OR REPLACE FUNCTION Devolver_ano_actual
return number
IS
v_anoactual NUMBER;
BEGIN
select extract(year from sysdate) into v_anoactual from dual;
return v_anoactual;
END;
/


--Función que devuelve el año de la fecha introducida

CREATE OR REPLACE FUNCTION Devolver_ano (p_fecha recibos_cuotas.fecha%type)
return number
IS
v_ano NUMBER;
BEGIN
v_ano:=TO_NUMBER(TO_CHAR(p_fecha,'YYYY'));
return v_ano;
END;
/


--Función que introduciendo el código de la comunidad nos devuelve el dni del presidente de dicha comunidad.

CREATE OR REPLACE FUNCTION Devolver_dni_presidente_comunidad(p_codcomunidad comunidades.codcomunidad%type)
return propietarios.dni%type
IS
v_dni propietarios.dni%type;
BEGIN
select dni into v_dni from propietarios where dni=(select dni from historial_cargos where nombre_cargo='Presidente' and codcomunidad=p_codcomunidad);
return v_dni;
END;
/


--Función que introduciendo el código de la comunidad nos devuelve el dni del administrador que tiene un contrato de mandato vigente con dicha comunidad.

CREATE OR REPLACE FUNCTION Devolver_dni_administrador_comunidad(p_codcomunidad comunidades.codcomunidad%type)
return administradores.dni%type
IS
v_dni administradores.dni%type;
BEGIN
select dni into v_dni from administradores where numcolegiado=(select numcolegiado from contratos_de_mandato where codcomunidad=p_codcomunidad);
return v_dni;
END;
/


--Procedimiento que introduciendo un código de comunidad envía un correo al presidente de la comunidad.

CREATE OR REPLACE PROCEDURE correo_presidente_comunidad (p_comunidad recibos_cuotas.codcomunidad%type)
IS
BEGIN
END;
/


--Procedimiento que introduciendo un codigo de comunidad envía un correo al administrador que tiene un contrato de mandato.
