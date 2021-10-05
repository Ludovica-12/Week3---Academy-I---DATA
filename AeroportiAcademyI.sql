--create database StazioneControlloVoli3

CREATE TABLE AEROPORTO(
	IdAeroporto INT IDENTITY(1,1),
	Nome VARCHAR(30) NOT NULL,
	Citta VARCHAR(30) NOT NULL,
	Nazione VARCHAR(30) NOT NULL,
	NumeroPiste INT,
	CONSTRAINT PK_AEROPORTO PRIMARY KEY (IdAeroporto)	
);

CREATE TABLE AEREO(
	CodiceAereo INT IDENTITY(1,1),
	TipoAereo VARCHAR(20) NOT NULL,
	NumeroPasseggeri INT NOT NULL check (NumeroPasseggeri >0 and NumeroPasseggeri<500 ),
	QtaMerci INT NOT NULL check (QtaMerci >=0),
	CONSTRAINT PK_AEREO PRIMARY KEY (CodiceAereo)	
);

CREATE TABLE VOLO(
	CodiceVolo NCHAR(5) NOT NULL,
	DataOraPartenza DATETIME NOT NULL,
	DataOraArrivo DATETIME NOT NULL,
	IdAeroportoPartenza INT NOT NULL,	
	IdAeroportoArrivo INT NOT NULL,
	CodiceAereo INT not null,
	CONSTRAINT PK_VOLO PRIMARY KEY (CodiceVolo),
	CONSTRAINT FK_PARTENZA FOREIGN KEY (IdAeroportoPartenza) REFERENCES Aeroporto(IdAeroporto),
	CONSTRAINT FK_ARRIVO FOREIGN KEY (IdAeroportoArrivo)	REFERENCES Aeroporto (IdAeroporto),
	CONSTRAINT FK_AEREO FOREIGN KEY (CodiceAereo) REFERENCES AEREO (CodiceAereo),
	constraint CHK_ARRIVOPARTENZA check (IdAeroportoPartenza<>IdAeroportoArrivo),

);
alter table volo add constraint CHK_DATAARRIVO check (DataOraArrivo>DataOraPartenza)


INSERT INTO Aereo VALUES ('Boeing 757', 250, 200);
INSERT INTO AEREO VALUES ('Aliante X', 20, 130);
INSERT INTO AEREO VALUES ('Boeing 737', 250, 100);


INSERT INTO AEROPORTO VALUES ('Malpensa', 'Milano', 'Italia', 5)
INSERT INTO AEROPORTO VALUES ('Ciampino', 'Roma', 'Italia', 15)
INSERT INTO AEROPORTO VALUES ('De Gaulle', 'Parigi', 'Francia', 25)
INSERT INTO AEROPORTO VALUES ('Kennedy', 'Los Angeles', 'USA', 12)
INSERT INTO AEROPORTO VALUES ('Capodichino', 'Napoli', 'Italia', NULL)


INSERT INTO VOLO VALUES ('AC123', '2021-10-01 12:30', '2021-10-01 13:30', 1, 2, 1);
INSERT INTO VOLO VALUES ('AC124', '2021-10-02 12:30', '2021-10-02 14:30', 1, 3, 1);
INSERT INTO VOLO VALUES ('AC125', '2021-10-03 10:30', '2021-10-03 22:30', 2, 4, 3);
INSERT INTO VOLO VALUES ('AC126', '2021-10-04 09:30', '2021-10-04 22:30', 1, 4, 3);
INSERT INTO VOLO VALUES ('AC127', '2021-10-05 09:30', '2021-10-05 22:30', 1, 2, 2);
INSERT INTO VOLO VALUES ('AC128', '2021-10-06 09:30', '2021-10-06 22:30', 3, 2, 2);
INSERT INTO VOLO VALUES ('AC129', '2021-10-07 12:30', '2021-10-07 13:30', 5, 2, 1);
INSERT INTO VOLO VALUES ('AC130', '2021-10-07 12:30', '2021-10-07 13:30', 5, 3, 1);

select * from AEROPORTO
select * from AEREO
select* from VOLO

--1. Le città con un aeroporto di cui non è noto il numero di piste; 
select distinct Citta 
from aeroporto 
where NumeroPiste is null

--2. Le nazioni da cui parte e arriva il volo con codice AZ274; 
select APartenza.Nazione as [Nazione Partenza], AArrivo.Nazione as [Nazione Arrivo]
from Aeroporto as APartenza join volo v on v.IdAeroportoPartenza=APartenza.IdAeroporto
join Aeroporto as AArrivo on AArrivo.IdAeroporto=v.IdAeroportoArrivo
where v.CodiceVolo='AZ274'

--3. I tipi di aereo usati nei voli che partono da Torino; 
select distinct a.TipoAereo
from Aereo a join VOLO v on a.CodiceAereo=v.CodiceAereo
join Aeroporto APartenza on APartenza.IdAeroporto=v.IdAeroportoPartenza
where APartenza.Citta='Torino'

--4. I tipi di aereo e il corrispondente numero di passeggeri per i tipi di aereo usati nei voli che partono da Torino. 
select distinct a.TipoAereo, a.NumeroPasseggeri
from Aereo a join VOLO v on a.CodiceAereo=v.CodiceAereo
join Aeroporto APartenza on APartenza.IdAeroporto=v.IdAeroportoPartenza
where APartenza.Citta='Torino'

--5. Le città da cui partono voli internazionali; 
select distinct APartenza.Citta
from volo v join aeroporto as APartenza on v.IdAeroportoPartenza=APartenza.IdAeroporto
			join aeroporto as AArrivo on v.IdAeroportoArrivo= AArrivo.IdAeroporto
where APartenza.Nazione<>AArrivo.Nazione

--6. Le città da cui partono voli diretti a Bologna, ordinate alfabeticamente; 
select  distinct APartenza.Citta
from volo  v join AEROPORTO as APartenza on v.IdAeroportoPartenza=APartenza.IdAeroporto
			join AEROPORTO as AArrivo on v.IdAeroportoArrivo=AArrivo.IdAeroporto
where AArrivo.Citta='Bologna'
order by APartenza.Citta 

--7. Il numero di voli internazionali che partono il giovedì da Napoli; 
select count(*) as 'Voli Internazionali da Napoli il giovedì'
from volo  v join AEROPORTO as APartenza on v.IdAeroportoPartenza=APartenza.IdAeroporto
			join AEROPORTO as AArrivo on v.IdAeroportoArrivo=AArrivo.IdAeroporto
where APartenza.Citta='Napoli'
and AArrivo.Nazione <> 'Italia'
and datename(weekday, v.DataOraPartenza)='thursday'

--8a. Il numero di voli che partono da città italiane
select Count(*) as [Voli in partenza da città italiane]
from VOLO v join AEROPORTO APartenza on v.IdAeroportoPartenza=APartenza.IdAeroporto
where APartenza.Nazione='Italia'
--8b. Il numero di voli internazionali che partono da città italiane
select Count(*) as [Voli internazionali in partenza da città italiane]
from VOLO v join AEROPORTO APartenza on v.IdAeroportoPartenza=APartenza.IdAeroporto
			join AEROPORTO AArrivo on AArrivo.IdAeroporto=v.IdAeroportoArrivo
where APartenza.Nazione='Italia' and AArrivo.Nazione<>'Italia'

--9. Le città francesi da cui partono più di venti voli diretti in Italia; 
select distinct APartenza.Citta
from VOLO v join AEROPORTO APartenza on v.IdAeroportoPartenza=APartenza.IdAeroporto
			join AEROPORTO AArrivo on AArrivo.IdAeroporto=v.IdAeroportoArrivo
where APartenza.Nazione='Francia' and AArrivo.Nazione='Italia'
group by APartenza.Citta
having count(*)>20

--10. Gli aeroporti italiani che hanno SOLO voli interni. 
select * 
from Aeroporto
where Nazione='Italia' and citta not in 
(select distinct APartenza.Citta
from VOLO v join AEROPORTO APartenza on v.IdAeroportoPartenza=APartenza.IdAeroporto
			join AEROPORTO AArrivo on AArrivo.IdAeroporto=v.IdAeroportoArrivo
where AArrivo.NAzione<>APartenza.Nazione and APartenza.Nazione='Italia')

--11. Le città che sono servite dall'aereo caratterizzato dal massimo numero di passeggeri;

select distinct APartenza.Citta
from VOLO v join AEROPORTO APartenza on v.IdAeroportoPartenza=APartenza.IdAeroporto
			join AEREO a on a.CodiceAereo=v.CodiceAereo
where a.NumeroPasseggeri = (select max (NumeroPasseggeri) from AEREO)
Union 
select distinct AArrivo.Citta
from VOLO v join AEROPORTO AArrivo on v.IdAeroportoArrivo=AArrivo.IdAeroporto
			join AEREO a on a.CodiceAereo=v.CodiceAereo
where a.NumeroPasseggeri = (select max (NumeroPasseggeri) from AEREO)

--12. La lista di tutti i tipi di aerei “Boing”
select TipoAereo
from Aereo
where TipoAereo like 'Boeing%';



