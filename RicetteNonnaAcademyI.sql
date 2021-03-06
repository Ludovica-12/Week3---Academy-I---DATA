create database RicetteNonna3;

create table Libro(
IdLibro int Identity(1,1) not null,
Titolo nvarchar(50) not null,
Tipologia nvarchar (30) not null,
constraint PK_Libro primary key (idLibro),
constraint Chk_Tipologia check (Tipologia='Primi' OR Tipologia='Secondi' OR Tipologia='Dolci')
);

create table Ricetta(
IdRicetta int identity(1,1) not null constraint PK_IdRicetta primary key,
Nome nvarchar(50) not null,
TempoPreparazione int not null,
NumeroPersone int not null,
Preparazione nvarchar(100),
IdLibro int Constraint FK_IdLibro foreign key references Libro(IdLibro)
);

create table Ingrediente(
IdIngrediente int identity(1,1) not null constraint PK_IdIngrediente primary key,
Nome nvarchar(50) not null,
Descrizione nvarchar(50) not null,
UnitaDiMisura nvarchar(10)
);

create table RicettaIngrediente(
IdRicetta int not null Constraint FK_IdRicetta foreign key references Ricetta(IdRicetta),
IdIngrediente int not null Constraint FK_IdIngrediente foreign key references Ingrediente(IdIngrediente),
Quantita int constraint check_qnt_positiva check (Quantita>=0)
constraint UNQ_RICETTA_INGREDIENTE unique (idRicetta, IdIngrediente)
)

insert into Ingrediente values ('Uova', 'Uova medie allevate a terra', null)
insert into Ingrediente values ('Carne', 'carne macinata', 'kg')
insert into Ingrediente values ('Pesce Spada', 'pesce spada oceano atlantico', 'kg')
insert into Ingrediente values ('Latte', 'Latte intero fresco', 'litri')
insert into Ingrediente values ('Zucchero', 'zucchero semolato', 'grammi')
insert into Ingrediente values ('Zucchero a velo', 'zucchero a velo vanigliato', 'grammi')
insert into Ingrediente values ('Pomodori', 'Pomodori datterini', 'kg')
insert into Ingrediente values ('Pomodori', 'Pomodorini gialli', 'kg')
insert into Ingrediente values ('Olive', 'Olive nere greche', 'grammi')
select * from Ingrediente;

insert into Libro values ('I dolci della nonna','Dolci')
insert into Libro values ('I secondi della nonna','Secondi')
insert into Libro values ('I primi della nonna','Primi')
select * from Libro;


--Nome,TempoPreparazione,NumeroPersone,Preparazione,IdLibro
insert into Ricetta values ('Torta', 120, 10,'Sbattere le uova..', 1)
insert into Ricetta values ('Torta Paradiso', 130, 8, 'Preparare zucchero a velo..',1)
insert into Ricetta values ('Polpette fritte', 30, 4, 'Condire carne con..',2)
select * from Ricetta;

--IdRicetta, IdIngrediente, Quantit?
insert into RicettaIngrediente values (1,1,4)
insert into RicettaIngrediente values (1,4,1)
insert into RicettaIngrediente values (2,1,10)
insert into RicettaIngrediente values (3,2,1)


--Viste
create view LibriConRicette (Libro, Tipologia, Ricetta)
AS(
select l.Titolo, l.Tipologia, r.Nome
from Libro l join Ricetta r on l.IdLibro=r.IdLibro
)

select * from LibriConRicette;
select * from LibriConRicetteEIngredienti;

select distinct Ricetta 
from LibriConRicetteEIngredienti
where Tipologia='Dolci';


--Stored Procedure
create procedure InserisciRicetta
@NomeRicetta varchar(50),
@tempoPreparazione int,
@numeroPersone int,
@Preparazione varchar(200),
@TitoloLibro varchar(50)

AS
declare @IDLIBRO int
select @IDLIBRO=IdLibro from Libro where Titolo=@TitoloLibro
insert into Ricetta values (@NomeRicetta,@tempoPreparazione,@numeroPersone,@Preparazione, @IDLIBRO);
Go

execute InserisciRicetta 'Frittata',10, 4,'sbattere le uova e mettere il sale','I secondi della nonna'

execute InserisciRicetta 'Crostata',10, 10,'sbattere le uova..','I dolci della nonna'

select * from Ricetta


create procedure InserisciRicettaSenzaPreparazione
@NomeRicetta varchar(50),
@tempoPreparazione int,
@numeroPersone int,
@TitoloLibro varchar(50)

AS
declare @IDLIBRO int
select @IDLIBRO=IdLibro from Libro where Titolo=@TitoloLibro
insert into Ricetta (Nome,TempoPreparazione,NumeroPersone,IdLibro) values (@NomeRicetta,@tempoPreparazione,@numeroPersone, @IDLIBRO);
Go

execute InserisciRicettaSenzaPreparazione 'Toast',2, 5,'I secondi della nonna'

--Funzioni
--funzione scalare che restituisce un valore
--ovvero restituisce il numero delle ricette del libro passato in input
create function NumeroRicetteDelLibro(@TitoloLibro varchar(50))
returns int
as
Begin
declare @numeroRicette int

select @numeroRicette=count(*)
from Libro l join Ricetta r on l.IdLibro=r.IdLibro
where l.Titolo=@TitoloLibro

return @numeroRicette
end

select dbo.NumeroRicetteDelLibro('I dolci della nonna') as [Numero ricette]

--Funzione che ritorna una tabella con le ricette del libro passato in input
create function RicetteDelLibro(@TitoloLibro varchar(50))
returns table

AS
return
select r.Nome, r.NumeroPersone, r.TempoPreparazione
from Libro l join Ricetta r on l.IdLibro=r.IdLibro
where l.Titolo=@TitoloLibro

select * from dbo.RicetteDelLibro('I dolci della nonna')

--stored procedure con Try catch
create procedure InserisciIngredienteAllaRicetta
@nomeIngrediente nvarchar(50),
@nomeRicetta nvarchar(50),
@quantita int
AS
begin
	BEGIN TRY
	declare @ID_Ingrediente int

	select @ID_Ingrediente = IdIngrediente
	from Ingrediente
	where Nome=@nomeIngrediente

	declare @ID_Ricetta int

	select @ID_Ricetta= IdRicetta
	from Ricetta
	where Nome=@nomeRicetta

	insert into RicettaIngrediente values (@ID_Ricetta,@ID_Ingrediente, @quantita)
	END TRY

	BEGIN CATCH
	--stampare le eccezioni
	select ERROR_MESSAGE(), ERROR_LINE()
	END CATCH
end

execute InserisciRicetta 'Torta di mele',10, 10,'sbattere le uova..','I dolci della nonna'

select * from Ingrediente
Select * from Ricetta

execute InserisciIngredienteAllaRicetta 'Latte','Torta di mele',1;
execute InserisciIngredienteAllaRicetta 'xxxx','Torta di mele',1;

--stored procedure con transaction
create procedure InserisciNuovoIngredienteARicetta
@nomeNuovoIngrediente nvarchar(50),
@descrizioneNuovoIngrediente nvarchar(50),
@unitaDiMisura nvarchar(10),
@nomeRicetta nvarchar(50),
@quantita int

AS
begin
	begin try
	BEGIN TRANSACTION
	insert into Ingrediente values (@nomeNuovoIngrediente,@descrizioneNuovoIngrediente,@unitaDiMisura);
	insert into RicettaIngrediente values ((select IdRicetta from Ricetta where Nome=@nomeRicetta), (select IdIngrediente from Ingrediente where Nome=@nomeNuovoIngrediente), @quantita);
	COMMIT TRAN;
	END TRY

	BEGIN CATCH
	if @@ERROR>0
	Begin
		ROLLBACK TRAN;
	END

	select ERROR_LINE() As ErrorLine, ERROR_MESSAGE() As [Messaggio d'errore] 
	END CATCH
End

execute InserisciNuovoIngredienteARicetta 'Lievito', 'lievito in polvere', 'gr','Torta di mele',12
select * from Ingrediente;
select * from LibriConRicetteEIngredienti;

execute InserisciNuovoIngredienteARicetta 'Vaniglia', 'vaniglia aroma', 'gr','Torta XXXX',12



--stored procedure con transaction PROVA
create procedure InserisciNuovoIngredienteARicetta2
@nomeNuovoIngrediente nvarchar(50),
@descrizioneNuovoIngrediente nvarchar(50),
@unitaDiMisura nvarchar(10),
@nomeRicetta nvarchar(50),
@quantita int

AS
begin
	BEGIN TRANSACTION
	begin try
	insert into Ingrediente values (@nomeNuovoIngrediente,@descrizioneNuovoIngrediente,@unitaDiMisura);
	insert into RicettaIngrediente values ((select IdRicetta from Ricetta where Nome=@nomeRicetta), (select IdIngrediente from Ingrediente where Nome=@nomeNuovoIngrediente), @quantita);
	COMMIT TRAN;
	END TRY

	BEGIN CATCH	
		ROLLBACK TRAN;
	select ERROR_LINE() As ErrorLine, ERROR_MESSAGE() As [Messaggio d'errore] 
	END CATCH	
End

execute InserisciNuovoIngredienteARicetta2 'Mele', 'mele a fette', 'gr','Torta di mele',12
execute InserisciNuovoIngredienteARicetta2 'Vaniglia', 'vaniglia aroma', 'gr','Torta XXXX',12


