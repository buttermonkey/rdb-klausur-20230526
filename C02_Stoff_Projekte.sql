-- (a) Erstellen der neuen DB (drop wegen entwicklungszyklus)
drop schema if exists "C02_Stoff_Projekte" cascade;
create schema "C02_Stoff_Projekte";
set schema 'C02_Stoff_Projekte';

-- (b) Erstellen der Tabelle 'abteilung'
--     Keine Referenzierung der Tabelle mitarbeiter moeglich, da diese noch nicht exisitiert
create table abteilung (
    Abteilungsname      varchar(50) unique primary key,
    Kostenstelle        char(1) not null CHECK (Kostenstelle IN ('A', 'B', 'C', 'D', 'E')),
    Abteilungsleiter    int
);

-- (c) Erstellen der Tabelle 'mitarbeiter'
create table mitarbeiter (
    MitarbeiterNr       int generated always as identity primary key,
    Abteilung           varchar(50) references abteilung(Abteilungsname),   -- foreign key
    Vorname             varchar(50) not null,
    Nachname            varchar(50) not null,
    Strasse             varchar(100) not null,
    Plz                 varchar(10) not null,       -- andere laender haben nicht zwingend nur ziffern
    Ort                 varchar(100) not null,
    Land                varchar(50) not null,
    Email               varchar(100),
    Telefon             varchar(20),
    Geburtsdatum        date not null,
    Eintrittsdatum      date not null,
    Firmenauto          boolean default false,
    Stundenlohn         DECIMAL(9,2) not null
);

-- (b) Erstellen der Verknuepfung zwischen dem Feld Abteilungsleiter und der Mitarbeiternummer
-- alter table abteilung
-- add foreign key fk_abteilungsleiter references mitarbeiter(MitarbeiterNr);

-- (d) Erstellen der Tabelle 'projekt'
create table projekt (
    ProjektNr           int generated always as identity primary key,
    Titel               varchar(50) not null ,
    Budget              decimal(9,2) not null,
    Startdatum          date not null ,
    Enddatum            date
);

-- (e) Erstellen der Tabelle 'aufgabe' ...
create table aufgabe (
    AufgabeNr           int generated always as identity primary key ,
    ProjektNr           int references projekt(ProjektNr),             -- foreign key
    Name                varchar(50) not null ,
    Prioritaet          varchar(10),
    Arbeitszeit         decimal(9,2)
);

-- (e) ... sowie der Verknuepfungstabelle 'mitarbeiter_bearbeitet_aufgabe'
create table mitarbeiter_bearbeitet_aufgabe (
    MitarbeiterNr       int references mitarbeiter(MitarbeiterNr),  -- foreign key
    AufgabeNr           int references aufgabe(AufgabeNr),          -- foreign key
    Arbeitszeit         decimal(9,2) not null,
    primary key (MitarbeiterNr, AufgabeNr)
);

-- (f) Insert data in abteilung
insert into abteilung (Abteilungsname, Kostenstelle)
values ('Verwaltung', 'A'),
       ('Softwareentwicklung', 'B'),
       ('Verkauf', 'C');

-- (g) Mitarbeiter anlegen
insert into mitarbeiter (Abteilung, Vorname, Nachname, Strasse, Plz, Ort, Land, Email, Telefon, Geburtsdatum, Eintrittsdatum, Firmenauto, Stundenlohn)
values ('Softwareentwicklung', 'Markus', 'Stoff', 'Kaerntnerstrasse 42', '1010', 'Wien', 'Austria', 's52005@edu.campus02.at', '+4369911123456', '1975-02-28', '2023-01-02', true, 97);

-- (h) Befoerderung zum Abteilungsleiter
update abteilung
set Abteilungsleiter = (select MitarbeiterNr from mitarbeiter where Nachname = 'Stoff' AND Vorname = 'Markus')
where Abteilungsname = 'Softwareentwicklung';

-- (i) Neues Projekt anlegen
insert into projekt (Titel, Budget, Startdatum, Enddatum)
values ('CAMPUS02 APP', 325000, '2023-06-01', '2024-08-31');

-- (j) Beispielaufgaben anlegen
insert into aufgabe (ProjektNr, Name, Prioritaet, Arbeitszeit)
values ((select ProjektNr from projekt where Titel = 'CAMPUS02 APP'), 'Nginx aufsetzen', 'hoch', 40),
       ((select ProjektNr from projekt where Titel = 'CAMPUS02 APP'), 'PostgreSQL server aufsetzen', 'hoch', 40),
       ((select ProjektNr from projekt where Titel = 'CAMPUS02 APP'), 'Datenbankschema entwickeln', 'mittel', 40),
       ((select ProjektNr from projekt where Titel = 'CAMPUS02 APP'), 'App entwickeln', 'niedrig', 40);

insert into mitarbeiter_bearbeitet_aufgabe (MitarbeiterNr, AufgabeNr, Arbeitszeit)
values ((select MitarbeiterNr from mitarbeiter where Nachname = 'Stoff' AND Vorname = 'Markus'), (select AufgabeNr from aufgabe where Name = 'Nginx aufsetzen'), 2.5),
       ((select MitarbeiterNr from mitarbeiter where Nachname = 'Stoff' AND Vorname = 'Markus'), (select AufgabeNr from aufgabe where Name = 'PostgreSQL server aufsetzen'), 3.5);

-- (k) Aufgaben abfragen (ich nehme meinen Namen statt der ID, da es fuer die Uebung stabiler ist: ansonsten where m.MitarbeiterId = 1)
select m.Vorname, m.Nachname, a.AufgabeNr, a.Name
from mitarbeiter m, mitarbeiter_bearbeitet_aufgabe b, aufgabe a
where m.MitarbeiterNr = b.MitarbeiterNr and b.AufgabeNr = a.AufgabeNr and m.Nachname = 'Stoff' and m.Vorname = 'Markus';

-- (l) Stundensatz fuer Softwareentwickler erhoehen
update mitarbeiter
set Stundenlohn = Stundenlohn * 1.05
where Abteilung = 'Softwareentwicklung';

-- (m) Personal sortiert ausgeben
select * from mitarbeiter
order by Nachname asc ;

-- (n) Summe der erwarteten Projektarbeitszeit ausgeben
select sum(b.Arbeitszeit)
from mitarbeiter_bearbeitet_aufgabe b
inner join aufgabe a on a.AufgabeNr = b.AufgabeNr;

-- (o) Aufgabe Nr. 3 loeschen
delete from aufgabe
where AufgabeNr = 3;
