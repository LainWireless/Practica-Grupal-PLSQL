select * from propietarios;
select * from HISTORIAL_CARGOS;
select * from comunidades;
describe HISTORIAL_CARGOS;


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

END;
/

