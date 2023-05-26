create table abteilung
(
    abteilungsname   varchar(50) not null
        primary key,
    kostenstelle     char        not null
        constraint abteilung_kostenstelle_check
            check (kostenstelle = ANY (ARRAY ['A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar, 'E'::bpchar])),
    abteilungsleiter integer
);

alter table abteilung
    owner to ms;

create table mitarbeiter
(
    mitarbeiternr  integer generated always as identity
        primary key,
    abteilung      varchar(50)
        references abteilung,
    vorname        varchar(50)   not null,
    nachname       varchar(50)   not null,
    strasse        varchar(100)  not null,
    plz            varchar(10)   not null,
    ort            varchar(100)  not null,
    land           varchar(50)   not null,
    email          varchar(100),
    telefon        varchar(20),
    geburtsdatum   date          not null,
    eintrittsdatum date          not null,
    firmenauto     boolean default false,
    stundenlohn    numeric(9, 2) not null
);

alter table mitarbeiter
    owner to ms;

create table projekt
(
    projektnr  integer generated always as identity
        primary key,
    titel      varchar(50)   not null,
    budget     numeric(9, 2) not null,
    startdatum date          not null,
    enddatum   date
);

alter table projekt
    owner to ms;

create table aufgabe
(
    aufgabenr   integer generated always as identity
        primary key,
    projektnr   integer
        references projekt,
    name        varchar(50) not null,
    prioritaet  varchar(10),
    arbeitszeit numeric(9, 2)
);

alter table aufgabe
    owner to ms;

create table mitarbeiter_bearbeitet_aufgabe
(
    mitarbeiternr integer       not null
        references mitarbeiter,
    aufgabenr     integer       not null
        references aufgabe,
    arbeitszeit   numeric(9, 2) not null,
    primary key (mitarbeiternr, aufgabenr)
);

alter table mitarbeiter_bearbeitet_aufgabe
    owner to ms;

