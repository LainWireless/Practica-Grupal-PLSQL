
Realiza los módulos de programación necesarios para que cuando se abone un recibo que lleve más de un año 
impagado se avise por correo electrónico al presidente de la comunidad y al administrador que tiene un contrato de 
mandato vigente con la comunidad correspondiente. Añade el campo e-mail tanto a la tabla Propietarios como 
Administradores.

--CONFIGURACIÓN PREVIA----------------------------------------------------------------------------------------------------------------------------------------------

--En este ejercicio, realizaré una prueba de envío y recepción de correo electrónico local (Entre usuarios de iesgn.com).
--Debemos de instalar en el sistema los paquetes postfix (Servidor de correo, configurándolo con el nombre del sistema de correo "iesgn.com") y bsd-mailx (Herramienta para envío/recepción de correo).

--Para enviar correos electrónicos mediante procedimientos PL/SQL usaremos UTL_MAIL.
--Antes de crear los procedimientos previos al envío de correo electrónico, debemos de realizar una configuración previa:

--1. Accedemos con el usuario sys

sqlplus / as sysdba


--2. Ejecutamos los siguiente scripts (Esto instalará la paquetería que requiere UTL_MAIL)

@$ORACLE_HOME/rdbms/admin/utlmail.sql
@$ORACLE_HOME/rdbms/admin/prvtmail.plb


--3. Establecemos el servidor SMTP de salida
--En este caso la configuración de retransmisión de correo será simple, con una referencia a "localhost" en el parámetro SMTP_OUT_SERVER.

alter system set smtp_out_server='localhost';

--*Nota: Podemos comprobar el valor de este parámetro con el siguiente comando:

show parameter smtp


--4. Creamos la ACL, dándole privilegios al usuario con el cual se ejecutará el procedimiento referente al envío de correo electrónico. 

BEGIN
DBMS_NETWORK_acl_ADMIN.CREATE_ACL (
acl => 'envio_correo.xml',
description => 'Permisos para enviar correos',
principal => 'ALFONSO',
is_grant => TRUE,
privilege => 'connect',
start_date => SYSTIMESTAMP,
end_date => NULL);
COMMIT;
END;
/

BEGIN
DBMS_NETWORK_acl_ADMIN.ADD_PRIVILEGE(
acl => 'envio_correo.xml',
principal => 'ALFONSO',
is_grant => true,
privilege => 'resolve'
);
COMMIT;
END;
/


BEGIN
DBMS_NETWORK_acl_ADMIN.ASSIGN_ACL (
acl => 'envio_correo.xml',
host => 'localhost',
lower_port => 25,
upper_port => NULL);
COMMIT;
END;
/

--Para comprobar los privilegios que tenemos y las ACLs creadas en nuestra base de datos usamos las siguiente consultas:

select acl, host, lower_port, upper_port from DBA_NETWORK_ACLS;
select acl, principal, privilege, is_grant from DBA_NETWORK_ACL_PRIVILEGES;


--5. Concedemos permisos al usuario para que pueda hacer uso de utl_mail.

alter session set "_ORACLE_SCRIPT"=TRUE;
grant execute on utl_mail to alfonso;

--Una vez realizada la configuración anterior, ya podemos volver a nuestro usuario y compilar el código mostrado a continuación.

disconnect
connect alfonso

--NUEVAS COLUMNAS Y ACTUALIZACIÓN DE DATOS--------------------------------------------------------------------------------------------------------------------------

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

--Realizamos una serie de actualizaciones en la columna "email" de la tabla "propietarios" sobre los resultados obtenidos en la consulta anterior.
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


--CREACIÓN DE TRIGGER PRINCIPAL Y PROCEDIMIENTOS/FUNCIONES DEPENDIENTES---------------------------------------------------------------------------------------------

--Trigger principal

CREATE OR REPLACE TRIGGER recibo_mas_de_un_ano_impagado
after insert or update on recibos_cuotas
for each row
DECLARE
BEGIN
  if (Devolver_ano_actual - Devolver_ano(:new.fecha)) > 1 then
      correo_presidente_comunidad(:new.codcomunidad);
      correo_administrador_comunidad(:new.codcomunidad);
  end if;
END;
/


--PROCEDIMIENTOS/FUNCIONES DEPENDIENTES (Compilar primero - De arriba a abajo)

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


--Función que introduciendo el código de la comunidad nos devuelve el correo del presidente de dicha comunidad.

CREATE OR REPLACE FUNCTION Devolver_email_presidente_comunidad(p_codcomunidad comunidades.codcomunidad%type)
return propietarios.email%type
IS
v_email propietarios.email%type;
BEGIN
select email into v_email from propietarios where dni=(select dni from historial_cargos where nombre_cargo='Presidente' and codcomunidad=p_codcomunidad);
return v_email;
END;
/


--Función que introduciendo el código de la comunidad nos devuelve el correo del administrador que tiene un contrato de mandato vigente con dicha comunidad.

CREATE OR REPLACE FUNCTION Devolver_email_administrador_comunidad(p_codcomunidad comunidades.codcomunidad%type)
return administradores.email%type
IS
v_email administradores.email%type;
BEGIN
select email into v_email from administradores where numcolegiado=(select numcolegiado from contratos_de_mandato where codcomunidad=p_codcomunidad);
return v_email;
END;
/


--Procedimiento que introduciendo un código de comunidad envía un correo al presidente de la comunidad.

CREATE OR REPLACE PROCEDURE correo_presidente_comunidad(p_codcomunidad recibos_cuotas.codcomunidad%type)
IS
BEGIN
  UTL_MAIL.send(sender     => 'alfonso@iesgn.com',
                recipients => Devolver_email_presidente_comunidad(p_codcomunidad),
                subject    => 'Recibo (+1 año impagado)',
                message    => 'Se ha abonado un recibo que lleva mas de un ano impagado');
END;
/


--Procedimiento que introduciendo un codigo de comunidad envía un correo al administrador que tiene un contrato de mandato.

CREATE OR REPLACE PROCEDURE correo_administrador_comunidad(p_codcomunidad recibos_cuotas.codcomunidad%type)
IS
BEGIN
  UTL_MAIL.send(sender     => 'alfonso@iesgn.com',
                recipients => Devolver_email_administrador_comunidad(p_codcomunidad),
                subject    => 'Recibo (+1 año impagado)',
                message    => 'Se ha abonado un recibo que lleva mas de un ano impagado');
END;
/


--PRUEBA DE FUNCIONAMIENTO------------------------------------------------------------------------------------------------------------------------------------------

--Probaremos a insertar un registro en Recibos_cuotas donde la fecha tenga más de un año de antiguedad y el valor "Pagado" sea "No".

INSERT INTO recibos_cuotas VALUES('0022','AAAA2','09291497A',TO_DATE('2013/11/11','YYYY/MM/DD'),35,'No');

--Una vez insertado, comprobaremos la bandeja de entrada, en este caso, de los usuarios "Rosa" (Presidenta) y "adminjosemanuel" (Administrador) de la comunidad.  