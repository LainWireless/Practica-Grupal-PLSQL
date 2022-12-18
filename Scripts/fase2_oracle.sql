
--CREACIÓN DE TABLAS-----------------------------------------------------------------------------------------------------

CREATE TABLE comunidades
(
codcomunidad		VARCHAR2(8),
nombre				VARCHAR2(20),
calle				VARCHAR2(35),
poblacion			VARCHAR2(30),
codigopostal		VARCHAR2(5),
CONSTRAINT pk_codcomunidad PRIMARY KEY (codcomunidad),
CONSTRAINT poblacionok CHECK (poblacion LIKE '%(Sevilla)' OR poblacion LIKE '%(Cadiz)' OR poblacion LIKE '%(Huelva)' OR poblacion LIKE '%(Cordoba)'),
CONSTRAINT comunidadesok CHECK(REGEXP_LIKE(codcomunidad,'[A-Z]{4,8}'))
);


CREATE TABLE administradores(
numcolegiado		VARCHAR2(5),
dni					VARCHAR2(9),
nombre				VARCHAR2(20),
apellidos			VARCHAR2(20),
CONSTRAINT pk_numcolegiado PRIMARY KEY (numcolegiado),
CONSTRAINT dni_unico unique(dni)
);


CREATE TABLE contratos_de_mandato(
codcontrato			VARCHAR2(6),
numcolegiado		VARCHAR2(5),
fecha_inicio		DATE,
fecha_final			DATE,
honorarios_anuales	NUMBER,
codcomunidad		VARCHAR2(8),
CONSTRAINT pk_codcontrato PRIMARY KEY (codcontrato),
CONSTRAINT fk_numcolegiado FOREIGN KEY (numcolegiado) REFERENCES administradores (numcolegiado),
CONSTRAINT fk_codcomunidad FOREIGN KEY (codcomunidad) REFERENCES comunidades (codcomunidad),
CONSTRAINT codcontratook CHECK(REGEXP_LIKE(codcontrato,'^[A-Z]{2}[0-9]{4}'))
);


CREATE TABLE propietarios(
dni					VARCHAR2(9),
nombre				VARCHAR2(20),
apellidos			VARCHAR2(20),
direccion			VARCHAR2(40),
localidad			VARCHAR2(35),
provincia			VARCHAR2(20),
tlf_contacto		VARCHAR2(9),
CONSTRAINT pk_propietario PRIMARY KEY (dni),
CONSTRAINT apellidosok CHECK(INITCAP(apellidos)=apellidos)
);


CREATE TABLE historial_cargos(
nombre_cargo		VARCHAR2(20),
codcomunidad		VARCHAR2(8),
dni					VARCHAR2(9),
fecha_inicio		DATE,
fecha_fin 			DATE,
CONSTRAINT pk_hcargo PRIMARY KEY(nombre_cargo, codcomunidad, dni,fecha_inicio),
CONSTRAINT fk_hcomunidad FOREIGN KEY(codcomunidad) REFERENCES comunidades (codcomunidad),
CONSTRAINT fk_hpropietario FOREIGN KEY(dni) REFERENCES propietarios(dni),
CONSTRAINT fecha_ok CHECK (TO_CHAR(fecha_inicio,'mmdd')NOT BETWEEN '0209' AND '1231')
);


CREATE TABLE recibos_cuotas(
numrecibo			VARCHAR2(4),
codcomunidad		VARCHAR2(8),
dni					VARCHAR2(9),
fecha 				DATE,
importe				NUMBER,
pagado				VARCHAR(9),
CONSTRAINT pk_numrecibo PRIMARY KEY (numrecibo,codcomunidad),
CONSTRAINT fk_recomunidad  FOREIGN KEY (codcomunidad) REFERENCES comunidades(codcomunidad),
CONSTRAINT fk_repropietario FOREIGN KEY (dni) REFERENCES propietarios(dni)
);


CREATE TABLE propiedades(
codcomunidad		VARCHAR2(8),
codpropiedad		VARCHAR2(4),
dni_propietario		VARCHAR2(9),
portal				VARCHAR2(3),
planta				VARCHAR2(7),
letra				VARCHAR2(1),
porcentaje_participacion NUMBER(5,2),
CONSTRAINT pk_propiedad PRIMARY KEY (codcomunidad,codpropiedad),
CONSTRAINT fk_propropietrio FOREIGN KEY (dni_propietario) REFERENCES propietarios(dni),
CONSTRAINT fk_procomunidad FOREIGN KEY (codcomunidad) REFERENCES comunidades(codcomunidad),
CONSTRAINT propiedadok CHECK(REGEXP_LIKE(codpropiedad,'[0-9]{4}'))
);


CREATE TABLE inquilinos(
dni 				VARCHAR2(9),
codpropiedad		VARCHAR2(4),
codcomunidad		VARCHAR2(8),
nombre 				VARCHAR2(20),
apellidos			VARCHAR2(20),
tlf_contacto		VARCHAR2(9),
CONSTRAINT pk_inquilino PRIMARY KEY (dni),
CONSTRAINT fk_inpropiedad FOREIGN KEY (codpropiedad,codcomunidad) REFERENCES propiedades(codpropiedad,codcomunidad),
CONSTRAINT utlf_contacto UNIQUE(tlf_contacto),
CONSTRAINT inquilinodniok CHECK(REGEXP_LIKE(dni,'^[0-9]{8}[A-Z]') or REGEXP_LIKE(dni,'^[KLMXYZ]{1}[0-9]{7}[A-Z]{1}'))
);


CREATE TABLE oficinas(
codpropiedad		VARCHAR2(4),
codcomunidad		VARCHAR2(8),
actividad			VARCHAR2(30),
CONSTRAINT pk_oficinas PRIMARY KEY (codpropiedad,codcomunidad),
CONSTRAINT fk_ofpropiedad FOREIGN KEY (codpropiedad,codcomunidad) REFERENCES propiedades(codpropiedad,codcomunidad)
);


CREATE TABLE locales(
codpropiedad		VARCHAR2(4),
codcomunidad		VARCHAR2(8),
CONSTRAINT pk_locales PRIMARY KEY (codpropiedad,codcomunidad),
CONSTRAINT fk_locpropiedad FOREIGN KEY (codpropiedad,codcomunidad) REFERENCES propiedades(codpropiedad,codcomunidad)
);


CREATE TABLE horarios_apertura(
codcomunidad		VARCHAR2(8),
codpropiedad		VARCHAR2(4),
diasemana			VARCHAR2(9),
hora_apertura 		TIMESTAMP,
hora_cierre			TIMESTAMP,
CONSTRAINT pk_horario PRIMARY KEY (codpropiedad,codcomunidad,diasemana,hora_apertura),
CONSTRAINT fk_hopropiedad FOREIGN KEY (codpropiedad,codcomunidad) REFERENCES propiedades(codpropiedad,codcomunidad),
CONSTRAINT hora_aperturaok CHECK((to_char(hora_apertura,'hh24:mi')BETWEEN '06:00' AND '23:00'))
);


CREATE TABLE viviendas(
codpropiedad		VARCHAR2(4),
codcomunidad		VARCHAR2(8),
numhabitaciones		VARCHAR2(2),
CONSTRAINT pk_viviendas PRIMARY KEY (codpropiedad,codcomunidad),
CONSTRAINT fk_vipropiedad FOREIGN KEY (codpropiedad,codcomunidad) REFERENCES propiedades(codpropiedad,codcomunidad)
);


--INSERCCIONES-----------------------------------------------------------------------------------------------------------

--Tabla comunidades

INSERT INTO comunidades VALUES('AAAA1','CV.Montecillos 13','Plaza Bertendona,13 ','Dos Hermanas(Sevilla)','41702');
INSERT INTO comunidades VALUES('AAAA2','CV.Anselmo','Plaza Constitución,12','Rota(Cadiz)','11520');
INSERT INTO comunidades VALUES('AAAA3','CV.Doñana','Plaza Doñana,2','Almonte(Huelva)','21750');
INSERT INTO comunidades VALUES('AAAA4','CV.Los Naranjos 2','Calle Cuartel,6 ','Alcolea(Cordoba)','14610');
INSERT INTO comunidades VALUES('AAAA5','CV.Los Principes 4','Avda Reyes Catolicos,7 ','Dos Hermanas(Sevilla)','41702');


--Tabla administradores

INSERT INTO administradores VALUES('472','52801993L','Elisa','Rodriguez Sempere');
INSERT INTO administradores VALUES('812','27449907M','José Manuel','Aguilar Aguilar');
INSERT INTO administradores VALUES('1186','23229790C','Carlos','Rivas Valero');
INSERT INTO administradores VALUES('389','23229791T','Tomás','Merino Juárez');


--Tabla contratos_de_mandato

INSERT INTO contratos_de_mandato VALUES('AA0001','472',TO_DATE('2016/01/15','YYYY/MM/DD'),TO_DATE('2017/01/15','YYYY/MM/DD'),420,'AAAA1');
INSERT INTO contratos_de_mandato VALUES('AA0002','812',TO_DATE('2016/01/05','YYYY/MM/DD'),TO_DATE('2017/01/05','YYYY/MM/DD'),550,'AAAA2');
INSERT INTO contratos_de_mandato VALUES('AA0003','472',TO_DATE('2016/01/25','YYYY/MM/DD'),TO_DATE('2017/01/25','YYYY/MM/DD'),420,'AAAA5');
INSERT INTO contratos_de_mandato VALUES('AA0004','1186',TO_DATE('2016/01/12','YYYY/MM/DD'),TO_DATE('2017/01/12','YYYY/MM/DD'),720,'AAAA3');
INSERT INTO contratos_de_mandato VALUES('AA0005','472',TO_DATE('2016/02/05','YYYY/MM/DD'),TO_DATE('2017/02/05','YYYY/MM/DD'),400,'AAAA4');
INSERT INTO contratos_de_mandato VALUES('AA0006','389',TO_DATE('2016/02/07','YYYY/MM/DD'),TO_DATE('2017/02/07','YYYY/MM/DD'),400,'AAAA4');


--Tabla propietarios

INSERT INTO propietarios VALUES('49027387N','Jose Manuel','Carmona Gotan','Plaza Bertendona,13 Bajo A','Dos Hermanas','Sevilla','607292602');
INSERT INTO propietarios VALUES('50765614Z','Álvaro','Acosta Gonzalez','Plaza Bertendona,13 Bajo B','Dos Hermanas','Sevilla','602272302');
INSERT INTO propietarios VALUES('10880946Z','Mª Isabel','Alonso Paz','Plaza Bertendona,13 1ºA','Dos Hermanas','Sevilla','802272304');
INSERT INTO propietarios VALUES('23293294K','Francisco','Andreo Gazquez','Plaza Bertendona,13 1ºB','Dos Hermanas','Sevilla','702276302');
INSERT INTO propietarios VALUES('79074112J','Carlos','Armas Acosta','Plaza Bertendona,13 1ºC','Dos Hermanas','Sevilla','603372301');
INSERT INTO propietarios VALUES('16593504Q','Natalia','Armendariz Artacho','Plaza Bertendona,13 1ºD','Dos Hermanas','Sevilla','602272302');
INSERT INTO propietarios VALUES('52349896X','Beatriz','Arranz Arranz','Plaza Constitución,12 Bajo A','Rota','Cadiz','602272301');
INSERT INTO propietarios VALUES('09291497A','Rosa','Asenjo Orive','Plaza Constitución,12 Bajo B','Rota','Cadiz','702222302');
INSERT INTO propietarios VALUES('X4945396M','Asya','Atanasova Rafaelova','Plaza Constitución,12 1ºA','Rota','Cadiz','802232303');
INSERT INTO propietarios VALUES('11830895V','Fernando','Bautista Fernandez','Plaza Constitución,12 1ºB','Rota','Cadiz','601242304');
INSERT INTO propietarios VALUES('46866917R','Laura','Briz Ponce','Plaza Constitución,12 1ºC','Rota','Cadiz','604252305');
INSERT INTO propietarios VALUES('71441529X','Laura','Bueno Martinez','Plaza Doñana,2 1ºA','Almonte','Huelva','690340854');
INSERT INTO propietarios VALUES('53042369E','Concepción','Caballero Casillas','Plaza Doñana,2 1ºB','Almonte','Huelva','790340854');
INSERT INTO propietarios VALUES('71128255L','Mª Jesús','Caballero Sanchez','Plaza Doñana,2 1ºC','Almonte','Huelva','890340854');
INSERT INTO propietarios VALUES('50863298V','Carmen','Cachero Alonso','Plaza Doñana,2 1ºD','Almonte','Huelva','694348852');
INSERT INTO propietarios VALUES('29201838A','Fernando','Cano Selva','Calle Cuartel,6 1ºA','Alcolea','Cordoba','602272302');
INSERT INTO propietarios VALUES('51945369F','María del Rocio','Castilla Hernandez','Calle Cuartel,6 1ºB','Alcolea','Cordoba','602272302');
INSERT INTO propietarios VALUES('23788215M','José','Castro Estevez','Calle Cuartel,6 1ºB','Alcolea','Cordoba','602272302');
INSERT INTO propietarios VALUES('K6033994J','Leif Erikson','Cayo Ventura','Calle Cuartel,6 1ºC','Alcolea','Cordoba','602272302');
INSERT INTO propietarios VALUES('K6022994B','Luisa','Sanchez Sanchez','Calle Cuartel,6 Bajo A','Alcolea','Cordoba','601142302');


--Tabla historial_cargos

INSERT INTO historial_cargos VALUES('Presidente','AAAA1','49027387N',TO_DATE('2016/01/15','YYYY/MM/DD'),TO_DATE('2017/01/15','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Vicepresidente','AAAA1','50765614Z',TO_DATE('2016/01/15','YYYY/MM/DD'),TO_DATE('2017/01/15','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Vocal','AAAA1','10880946Z',TO_DATE('2016/01/15','YYYY/MM/DD'),TO_DATE('2017/01/15','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Vocal','AAAA1','23293294K',TO_DATE('2016/01/15','YYYY/MM/DD'),TO_DATE('2017/01/15','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Presidente','AAAA2','09291497A',TO_DATE('2016/01/05','YYYY/MM/DD'),TO_DATE('2017/01/05','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Vicepresidente','AAAA2','52349896X',TO_DATE('2016/01/05','YYYY/MM/DD'),TO_DATE('2017/01/05','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Vocal','AAAA2','X4945396M',TO_DATE('2016/01/05','YYYY/MM/DD'),TO_DATE('2017/01/05','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Vocal','AAAA2','11830895V',TO_DATE('2016/01/05','YYYY/MM/DD'),TO_DATE('2017/01/05','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Presidente','AAAA3','71441529X',TO_DATE('2016/01/12','YYYY/MM/DD'),TO_DATE('2017/01/12','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Vicepresidente','AAAA3','53042369E',TO_DATE('2016/01/12','YYYY/MM/DD'),TO_DATE('2017/01/12','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Vocal','AAAA3','71128255L',TO_DATE('2016/01/12','YYYY/MM/DD'),TO_DATE('2017/01/12','YYYY/MM/DD'));
INSERT INTO historial_cargos VALUES('Vocal','AAAA3','50863298V',TO_DATE('2016/01/12','YYYY/MM/DD'),TO_DATE('2017/01/12','YYYY/MM/DD'));


--Tabla recibos_cuotas

INSERT INTO recibos_cuotas VALUES('0001','AAAA1','50765614Z',TO_DATE('2016/02/15','YYYY/MM/DD'),25,'Si');
INSERT INTO recibos_cuotas VALUES('0002','AAAA1','10880946Z',TO_DATE('2016/02/15','YYYY/MM/DD'),25,'Si');
INSERT INTO recibos_cuotas VALUES('0003','AAAA1','23293294K',TO_DATE('2016/02/15','YYYY/MM/DD'),25,'No');
INSERT INTO recibos_cuotas VALUES('0004','AAAA1','79074112J',TO_DATE('2016/02/15','YYYY/MM/DD'),25,'No');
INSERT INTO recibos_cuotas VALUES('0005','AAAA1','16593504Q',TO_DATE('2016/02/15','YYYY/MM/DD'),25,'No');
INSERT INTO recibos_cuotas VALUES('0001','AAAA2','52349896X',TO_DATE('2016/02/05','YYYY/MM/DD'),35,'No');
INSERT INTO recibos_cuotas VALUES('0002','AAAA2','09291497A',TO_DATE('2016/02/05','YYYY/MM/DD'),35,'No');
INSERT INTO recibos_cuotas VALUES('0006','AAAA1','50765614Z',TO_DATE('2016/03/15','YYYY/MM/DD'),25,'Si');
INSERT INTO recibos_cuotas VALUES('0007','AAAA1','10880946Z',TO_DATE('2016/03/15','YYYY/MM/DD'),25,'Si');
INSERT INTO recibos_cuotas VALUES('0008','AAAA1','23293294K',TO_DATE('2016/03/15','YYYY/MM/DD'),25,'No');
INSERT INTO recibos_cuotas VALUES('0009','AAAA1','79074112J',TO_DATE('2016/03/15','YYYY/MM/DD'),25,'No');
INSERT INTO recibos_cuotas VALUES('0010','AAAA1','16593504Q',TO_DATE('2016/03/15','YYYY/MM/DD'),25,'No');
INSERT INTO recibos_cuotas VALUES('0003','AAAA2','52349896X',TO_DATE('2016/03/05','YYYY/MM/DD'),35,'No');
INSERT INTO recibos_cuotas VALUES('0004','AAAA2','09291497A',TO_DATE('2016/03/05','YYYY/MM/DD'),35,'No');
INSERT INTO recibos_cuotas VALUES('0011','AAAA1','50765614Z',TO_DATE('2016/04/15','YYYY/MM/DD'),25,'Si');
INSERT INTO recibos_cuotas VALUES('0012','AAAA1','10880946Z',TO_DATE('2016/04/15','YYYY/MM/DD'),25,'Si');
INSERT INTO recibos_cuotas VALUES('0013','AAAA1','23293294K',TO_DATE('2016/04/15','YYYY/MM/DD'),25,'No');
INSERT INTO recibos_cuotas VALUES('0014','AAAA1','79074112J',TO_DATE('2016/04/15','YYYY/MM/DD'),25,'No');
INSERT INTO recibos_cuotas VALUES('0015','AAAA1','16593504Q',TO_DATE('2016/04/15','YYYY/MM/DD'),25,'No');
INSERT INTO recibos_cuotas VALUES('0005','AAAA2','52349896X',TO_DATE('2016/04/05','YYYY/MM/DD'),35,'No');
INSERT INTO recibos_cuotas VALUES('0006','AAAA2','09291497A',TO_DATE('2016/04/05','YYYY/MM/DD'),35,'No');


--Tabla propiedades

INSERT INTO propiedades VALUES('AAAA1','0001','49027387N','13','Bajo','A',7.750);
INSERT INTO propiedades VALUES('AAAA1','0002','50765614Z','13','Bajo','B',10.50);
INSERT INTO propiedades VALUES('AAAA1','0003','10880946Z','13','1º','A',25.75);
INSERT INTO propiedades VALUES('AAAA1','0004','23293294K','13','1º','B',7.750);
INSERT INTO propiedades VALUES('AAAA1','0005','79074112J','13','1º','C',7.750);
INSERT INTO propiedades VALUES('AAAA1','0006','16593504Q','13','1º','D',7.750);
INSERT INTO propiedades VALUES('AAAA2','0001','52349896X','12','Bajo','A',7.750);
INSERT INTO propiedades VALUES('AAAA2','0002','09291497A','12','Bajo','B',12.45);
INSERT INTO propiedades VALUES('AAAA2','0003','X4945396M','12','1º','A',7.750);
INSERT INTO propiedades VALUES('AAAA2','0004','11830895V','12','1º','B',7.750);
INSERT INTO propiedades VALUES('AAAA2','0005','46866917R','12','1º','C',7.750);
INSERT INTO propiedades VALUES('AAAA3','0001','71441529X','2','1º','A',7.750);
INSERT INTO propiedades VALUES('AAAA3','0002','53042369E','2','1º','B',75.00);
INSERT INTO propiedades VALUES('AAAA3','0003','71128255L','2','1º','C',7.750);
INSERT INTO propiedades VALUES('AAAA3','0004','50863298V','2','1º','D',8.50);
INSERT INTO propiedades VALUES('AAAA4','0001','29201838A','6','1º','A',8.50);
INSERT INTO propiedades VALUES('AAAA4','0002','51945369F','6','1º','B',7.750);
INSERT INTO propiedades VALUES('AAAA4','0003','23788215M','6','1º','C',7.750);
INSERT INTO propiedades VALUES('AAAA4','0004','K6033994J','6','1º','D',80.75);
INSERT INTO propiedades VALUES('AAAA4','0005','K6022994B','6','1º','D',5.50);


--Tabla inquilinos

INSERT INTO inquilinos VALUES('22421953N','0003','AAAA2','ANTONIA ','VIDAL PORRAS','639901719');
INSERT INTO inquilinos VALUES('22456294Z','0004','AAAA2','JOSE ANTONIO','SANCHEZ MOLINA','649496996');
INSERT INTO inquilinos VALUES('27440525F','0003','AAAA1','FUENSANTA','RUIZ MARTINEZ','749486956');
INSERT INTO inquilinos VALUES('27447854E','0004','AAAA1','FERNANDO','ROMAN LAPUENTE','835436995');
INSERT INTO inquilinos VALUES('22478873F','0003','AAAA3','MANUEL','NICOLAS GARCIA','669456006');
INSERT INTO inquilinos VALUES('22918037D','0004','AAAA3','JUANA','MORENZA MATEO','774406190');


--Tabla oficinas

INSERT INTO oficinas VALUES('0006','AAAA1','Arquitectura');
INSERT INTO oficinas VALUES('0002','AAAA2','Banco');
INSERT INTO oficinas VALUES('0002','AAAA3','Arquitectura');
INSERT INTO oficinas VALUES('0001','AAAA4','Arquitectura');
INSERT INTO oficinas VALUES('0002','AAAA4','Administracion Fincas');
INSERT INTO oficinas VALUES('0003','AAAA4','Diseño Grafico');
INSERT INTO oficinas VALUES('0004','AAAA4','Empleo');
INSERT INTO oficinas VALUES('0005','AAAA4','Banco');


--Tabla locales

INSERT INTO locales VALUES('0001','AAAA3');
INSERT INTO locales VALUES('0001','AAAA1');
INSERT INTO locales VALUES('0001','AAAA2');
INSERT INTO locales VALUES('0002','AAAA1');


--Tabla horarios_apertura

INSERT INTO horarios_apertura VALUES('AAAA1','0001','Lunes',TO_DATE('08:00','HH24:MI'),TO_DATE('18:00','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA1','0001','Martes',TO_DATE('08:00','HH24:MI'),TO_DATE('18:00','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA1','0001','Miercoles',TO_DATE('08:00','HH24:MI'),TO_DATE('18:00','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA1','0001','Jueves',TO_DATE('08:00','HH24:MI'),TO_DATE('18:00','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA1','0001','Viernes',TO_DATE('08:00','HH24:MI'),TO_DATE('14:00','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA2','0001','Lunes',TO_DATE('09:30','HH24:MI'),TO_DATE('17:30','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA2','0001','Martes',TO_DATE('09:30','HH24:MI'),TO_DATE('17:30','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA2','0001','Miercoles',TO_DATE('09:30','HH24:MI'),TO_DATE('17:30','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA2','0001','Jueves',TO_DATE('09:30','HH24:MI'),TO_DATE('17:30','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA2','0001','Viernes',TO_DATE('09:30','HH24:MI'),TO_DATE('14:30','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA3','0001','Lunes',TO_DATE('10:00','HH24:MI'),TO_DATE('20:00','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA3','0001','Martes',TO_DATE('10:00','HH24:MI'),TO_DATE('20:00','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA3','0001','Miercoles',TO_DATE('10:00','HH24:MI'),TO_DATE('20:00','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA3','0001','Jueves',TO_DATE('10:00','HH24:MI'),TO_DATE('20:00','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA3','0001','Viernes',TO_DATE('10:00','HH24:MI'),TO_DATE('20:00','HH24:MI'));
INSERT INTO horarios_apertura VALUES('AAAA3','0001','Sabado',TO_DATE('09:00','HH24:MI'),TO_DATE('13:00','HH24:MI'));


--Tabla viviendas

INSERT INTO viviendas VALUES('0003','AAAA1','3');
INSERT INTO viviendas VALUES('0003','AAAA2','4');
INSERT INTO viviendas VALUES('0003','AAAA3','2');
INSERT INTO viviendas VALUES('0004','AAAA1','3');
INSERT INTO viviendas VALUES('0004','AAAA2','4');
INSERT INTO viviendas VALUES('0004','AAAA3','2');
INSERT INTO viviendas VALUES('0005','AAAA1','3');
INSERT INTO viviendas VALUES('0005','AAAA2','4');
