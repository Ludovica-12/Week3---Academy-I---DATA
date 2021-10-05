--Esercitazione Musei
--Progettare un database per tenere traccia delle Opere d’arte presenti nei vari Musei.
--Ogni Museo è caratterizzato da un codice, un nome univoco, la Città in cui si trova.
--Di ogni museo è necessario tenere traccia delle Opere d’arte lì esposte. 
--In particolare per ogni Opera d’arte le informazioni da salvare sono: codice (che la identifica univocamente), Titolo, l’artista che l’ha realizzata e i personaggi eventualmente raffigurati. 
--Dell’artista interessa tenere traccia del Nome (univoco) e della Nazionalità, del Personaggio/i raffigurato/i invece del Nome.

create database MuseiAcademyI

create table Museo (
	IdMuseo INT IDENTITY(1,1),
	Nome VARCHAR(30) NOT NULL unique,
	Citta VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Museo PRIMARY KEY (IdMuseo)	
);

create table Artista (
	IdArtista INT IDENTITY(1,1),
	Nome VARCHAR(30) NOT NULL unique,
	Nazionalita VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Artista PRIMARY KEY (IdArtista)	
);

create table Opera (
	IdOpera INT IDENTITY(1,1),
	Codice VARCHAR(30) NOT NULL unique,
	Titolo VARCHAR(70) NOT NULL,
	IdMuseo INT NOT NULL,
	IdArtista INT NOT NULL
	CONSTRAINT PK_Opera PRIMARY KEY (IdOpera)
	CONSTRAINT FK_Museo FOREIGN KEY (IdMuseo) REFERENCES Museo (IdMuseo),
	CONSTRAINT FK_Artista FOREIGN KEY (IdArtista) REFERENCES Artista (IdArtista)
);

create table Personaggio (
	IdPersonaggio INT IDENTITY(1,1),
	Nome VARCHAR(30) NOT NULL unique,	
	CONSTRAINT PK_Personaggio PRIMARY KEY (IdPersonaggio)	
);

create table OperaPersonaggio (
	IdOpera INT NOT NULL,
	IdPersonaggio INT NOT NULL	
	CONSTRAINT FK_Oprera FOREIGN KEY (IdOpera)	REFERENCES Opera (IdOpera),
	CONSTRAINT FK_Personaggio FOREIGN KEY (IdPersonaggio) REFERENCES Personaggio (IdPersonaggio),
	CONSTRAINT PK_OperaPersonaggio PRIMARY KEY (IdOpera,IdPersonaggio)
);


--insert
INSERT INTO MUSEO VALUES ('National Gallery', 'Londra');
INSERT INTO MUSEO VALUES ('Museo arte contemporanea', 'Londra');
INSERT INTO MUSEO VALUES ('MAXXI', 'Roma');
INSERT INTO MUSEO VALUES ('Museum', 'Londra');
INSERT INTO MUSEO VALUES ('GAlleria U', 'Firenze');
INSERT INTO MUSEO VALUES ('Museum solo tiziano', 'Londra');
INSERT INTO MUSEO VALUES ('Museum2', 'Londra');

select * from museo;

INSERT INTO Artista VALUES ('Tiziano', 'Italia');
INSERT INTO Artista VALUES ('Michelangelo', 'Italia');
INSERT INTO Artista VALUES ('Picasso', 'Spagnolo');

select * from Artista;

--codice, titolo, idMuseo, IdArtista
INSERT INTO OPERA VALUES ('1234', 'Venere', 1, 3)
INSERT INTO OPERA VALUES ('1235', 'Pieta', 1, 2)
INSERT INTO OPERA VALUES ('1237', 'prova', 1, 2)
INSERT INTO OPERA VALUES ('1236', 'Guernica', 1, 3)
INSERT INTO OPERA VALUES ('1239', 'Guernica2', 2, 3)
INSERT INTO OPERA VALUES ('2222', 'Opera Tiz', 1, 1)
INSERT INTO OPERA VALUES ('2223', 'Opera Tiz2', 1, 2)
INSERT INTO OPERA VALUES ('2225', 'Opera Tiz3', 1, 1)
INSERT INTO OPERA VALUES ('2226', 'Opera Tiz4', 1, 3)
INSERT INTO OPERA VALUES ('2227', 'Opera Spagnolo a Firenze', 5, 3)
INSERT INTO OPERA VALUES ('2228', 'Opera artista italiano a londra', 1, 1)
INSERT INTO OPERA VALUES ('2229', 'Operaegzh a londra', 6, 1)
INSERT INTO OPERA VALUES ('2230', 'Operaegzdfsahjk', 7, 2)
--delete from opera;
select * from Opera;

INSERT INTO PERSONAGGIO VALUES ('Madonna');
INSERT INTO PERSONAGGIO VALUES ('Dea Venere');
INSERT INTO PERSONAGGIO VALUES ('Peronaggio1');
INSERT INTO PERSONAGGIO VALUES ('Peronaggio2');

INSERT INTO OperaPersonaggio VALUES (1,2);
INSERT INTO OperaPersonaggio VALUES (1,3);
INSERT INTO OperaPersonaggio VALUES (2,1);
INSERT INTO OperaPersonaggio VALUES (3,1);
INSERT INTO OperaPersonaggio VALUES (11,1);
 

select * from Museo;
select * from Artista;
select * from Opera;
select * from Personaggio;
select * from OperaPersonaggio;

--1.Il nome dell’artista ed il titolo delle opere conservate alla “Galleria degli Uffizi” o alla “National Gallery”.
select a.Nome, o.Titolo
from Opera o join Artista a on o.IdArtista=a.IdArtista
			join Museo m on m.IdMuseo=o.IdMuseo
--where m.Nome='Galleria degli Uffizi' or m.Nome='National Gallery';
where m.Nome in ('Galleria degli Uffizi','National Gallery');

--2.Il nome dell’artista ed il titolo delle opere di artisti spagnoli conservate nei musei di Firenze
select a.Nome, o.Titolo
from Opera o join Artista a on o.IdArtista=a.IdArtista
			join Museo m on m.IdMuseo=o.IdMuseo
where a.Nazionalita='Spagnolo' and m.Citta='Firenze';

--3.Il codice ed il titolo delle opere di artisti italiani conservate nei musei di Londra, 
--in cui è rappresentata la Madonna
select o.Codice, o.Titolo
from Opera o join Artista a on o.IdArtista=a.IdArtista
			join Museo m on m.IdMuseo=o.IdMuseo
			join OperaPersonaggio op on op.IdOpera=o.IdOpera
			join Personaggio p on p.IdPersonaggio= op.IdPersonaggio
where a.Nazionalita='italia' and m.Citta='Londra' and p.Nome='Madonna'

--4.Per ciascun museo di Londra, il numero di opere di artisti italiani ivi conservate
select m.Nome, count(*) 
from Opera o join Artista a on o.IdArtista=a.IdArtista
			join Museo m on m.IdMuseo=o.IdMuseo
where a.Nazionalita='italia' and m.Citta='Londra'
group by m.Nome

--5.Il nome dei musei di Londra che non conservano opere di Tiziano

select m.Nome
from Museo m
where m.Citta='Londra'
and m.Nome not in (
select m.Nome
from Museo m join Opera o on o.IdMuseo=m.IdMuseo
join Artista a on a.IdArtista= o.IdArtista
where a.Nome='Tiziano')

--6.Il nome dei musei di Londra che conservano solo opere di Tiziano

select m.Nome
from Opera o join museo m on m.IdMuseo=o.IdMuseo
join artista a on a.IdArtista=o.IdArtista
where m.Citta='Londra' and m.Nome not in (
select m.Nome
from Museo m join Opera o on o.IdMuseo=m.IdMuseo
join Artista a on a.IdArtista= o.IdArtista
where a.Nome<>'Tiziano')


--7.I musei che conservano almeno 20 opere di artisti italiani
select m.Nome --, count(*)
from Museo m join Opera o on o.IdMuseo=m.IdMuseo
join Artista a on a.IdArtista= o.IdArtista
where a.Nazionalita='italia'
group by m.Nome
having Count (*)>=20

--8.Per ogni museo, il numero di opere divise per la nazionalità dell’artista
select m.Nome, a.Nazionalita, count(*) as [Numero di Opere per nazionalità dell'artista]
from Museo m join Opera o on o.IdMuseo=m.IdMuseo
join Artista a on a.IdArtista= o.IdArtista
group by m.Nome, a.Nazionalita



