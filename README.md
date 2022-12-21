# Practica-Grupal-PLSQL
Práctica grupal de PL/SQL realizada por Iván, Felipe, Alfonso y David.
## Descripción

Se adjuntan los siguientes cinco documentos:

- a) Descripción del problema. (Fase 1)

- b) Esquema de las tablas que tendréis que utilizar (Fase 2)

- c) Dos scripts para la creación de las tablas y la inserción de registros tanto en ORACLE como en Postgres (los originales contenían errores, pero ya están solucionados)

- d) El enunciado real de la práctica. (Fase 4)

Se realizarán los ocho ejercicios en ORACLE y dos de ellos se harán también en Postgres.

# Enunciado Ejercicio 3:
## Realizar un trigger que actualice los honorarios anuales de un contrato de mandato de acuerdo a lo siguiente:
- Si el número de Propiedades de la comunidad a la que pertenece el contrato de mandato es de 1 a 5, los Honorarios Anuales serán de 600
- Si el número de Propiedades de la comunidad a la que pertenece el contrato de mandato es de 6 a 10, los Honorarios Anuales serán de 1000
- Si el número de Propiedades de la comunidad a la que pertenece el contrato de mandato es de 11 a 20, los Honorarios Anuales serán de 1800
- Si el número de Propiedades de la comunidad a la que pertenece el contrato de mandato es mayor de 20, los Honorarios Anuales serán de 2500
- La existencia de locales en la comunidad a la que pertenece el contrato de mandato incrementará en un 20% los honorarios 
- La existencia de oficinas en la comunidad a la que pertenece el contrato de mandato incrementará en un 10% los honorarios

## Select de la tabla CONTRATROS_DE_MANDATO antes de ejecutar el procedimiento que actualiza los datos:
![Imagen](capturas/ejercicio3-original.png)

## Select de la tabla CONTRATROS_DE_MANDATO después de ejecutar el procedimiento que actualiza los datos:
![Imagen](capturas/ejercicio3-prueba.png)

## Comprobación de que el trigger funciona correctamente:
- Primero se ha insertado un registro que debe de dar un error, ya que no se ha cumplido la condición del trigger.
- Luego se ha insertado un registro que sí cumple la condición del trigger.
- Por último se ha comprobado que el último registro insertado se ha insertado correctamente mediante un select de la tabla CONTRATOS_DE_MANDATO.
![Imagen](capturas/ejercicio3-prueba2.png)

## En esta imagen se puede ver otra comprobación del trigger:
- Primero se ha hecho un select para ver el número de propiedades, locales y oficinas de las comunidades.
- Luego se ha insertado un registro de una comunidad que no tiene propiedades, locales ni oficinas.
- Por último se ha hecho un select de la tabla CONTRATOS_DE_MANDATO para comprobar que el registro se ha insertado correctamente.
![Imagen](capturas/ejercicio3-prueba3.png)


# Enunciado Ejercicio 3 hecho en PostgreSQL:
## Realizar un trigger que actualice los honorarios anuales de un contrato de mandato de acuerdo a lo siguiente:
- Si el número de Propiedades de la comunidad a la que pertenece el contrato de mandato es de 1 a 5, los Honorarios Anuales serán de 600
- Si el número de Propiedades de la comunidad a la que pertenece el contrato de mandato es de 6 a 10, los Honorarios Anuales serán de 1000
- Si el número de Propiedades de la comunidad a la que pertenece el contrato de mandato es de 11 a 20, los Honorarios Anuales serán de 1800
- Si el número de Propiedades de la comunidad a la que pertenece el contrato de mandato es mayor de 20, los Honorarios Anuales serán de 2500
- La existencia de locales en la comunidad a la que pertenece el contrato de mandato incrementará en un 20% los honorarios 
- La existencia de oficinas en la comunidad a la que pertenece el contrato de mandato incrementará en un 10% los honorarios

## Select de la tabla CONTRATROS_DE_MANDATO antes de ejecutar el procedimiento que actualiza los datos:
![Imagen](capturas/ejercicio3-postgre-original.png)

## Select de la tabla CONTRATROS_DE_MANDATO después de ejecutar el procedimiento que actualiza los datos:
![Imagen](capturas/ejercicio3-postgre-prueba.png)

## Comprobación de que el trigger funciona correctamente:
- Se ha insertado un registro que debe de dar un error, ya que no se ha cumplido la condición del trigger.
![Imagen](capturas/ejercicio3-postgre-prueba2.png)

## En esta imagen se puede ver otra comprobación del trigger:
- Primero se ha insertado un registro que sí cumple la condición del trigger.
- Luego se ha hecho un select de la tabla CONTRATOS_DE_MANDATO para comprobar que el registro se ha insertado correctamente.
![Imagen](capturas/ejercicio3-postgre-prueba3.png)


# Enunciado Ejercicio 8:
## Realiza los módulos de programación necesarios para evitar que se emitan dos recibos a un mismo propietario en menos de 30 días.

## Comprobación de que el trigger funciona correctamente:
- Primero se ha insertado un registro que no cumple la condición del trigger y da un error.
- Luego se ha insertado un registro que sí cumple la condición del trigger.
- Después se ha insertado un registro que no cumple la condición del trigger y da un error.
![Imagen](capturas/ejercicio8-prueba.png)

## En esta imagen se puede ver que el registro que antes se insertó correctamente:
![Imagen](capturas/ejercicio8-select.png)

## En esta imagen se puede ver como elimino todos los registros de la tabla RECIBOS_CUOTAS para poder insertarlos de nuevo:
![Imagen](capturas/ejercicio8-prueba2.png)

## En esta imagen se puede ver otra comprobación del trigger en la cual se ve que no todos los registros se han insertado correctamente debido a que no cumplen la condición del trigger:
![Imagen](capturas/ejercicio8-prueba3.png)

## En esta imagen se puede ver mediante un select de la tabla RECIBOS_CUOTAS los registros que se han insertado correctamente:
![Imagen](capturas/ejercicio8-prueba4.png)

## Mas comprobaciones del trigger:
- Primero he tratado de insertar un registro que no cumple la condición del trigger y da un error, esto es debido a que el trigger cuenta los días desde la fecha de emisión del último recibo del propiertario y deben pasar exactamente 30 días. Del día 15 de febrero al 16 de marzo hay 29 días, por lo que no se cumple la condición del trigger.
- Luego he insertado un registro que sí cumple la condición del trigger. En este caso sí han pasado 30 días desde la fecha de emisión del último recibo del propietario.
![Imagen](capturas/ejercicio8-prueba5.png)

## En esta imagen se puede ver que el registro que antes se insertó correctamente:
![Imagen](capturas/ejercicio8-prueba6.png)
