DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

CREATE TABLE IF NOT EXISTS lotnisko
(
    lotnisko_id bigint primary key generated always as identity,
    nazwa       varchar(255) not null,
    czynny      bool         not null default false
);

CREATE TABLE IF NOT EXISTS samolot
(
    samolot_id bigint primary key generated always as identity,
    model      varchar(255),
    miejsca    int not null check ( miejsca > 0 )
);

CREATE TABLE IF NOT EXISTS pilot
(
    pilot_id bigint primary key generated always as identity,
    imie     varchar(255) not null,
    nazwisko varchar(255)
);

CREATE TABLE IF NOT EXISTS lot
(
    lot_id         bigint primary key generated always as identity,
    pochodzenie    bigint    not null,
    kierunek       bigint    not null,
    nastepny_lot   bigint    null     default null,
    samolot_id     bigint    not null,
    pilot_id       bigint    not null,
    drugi_pilot_id bigint    not null,
    data_odlotu    timestamp not null default current_timestamp,
    dlugosc_lotu   interval  not null,
    opuznienia     interval  not null default '0 minutes',
    foreign key (pochodzenie) references lotnisko (lotnisko_id),
    foreign key (kierunek) references lotnisko (lotnisko_id),
    foreign key (nastepny_lot) references lot (lot_id),
    foreign key (pilot_id) references Pilot (pilot_id),
    foreign key (drugi_pilot_id) references Pilot (pilot_id),
    foreign key (samolot_id) references samolot (samolot_id),
    check ( pochodzenie <> kierunek ),
    check ( drugi_pilot_id <> pilot_id )
);

CREATE TABLE IF NOT EXISTS pasazer
(
    pasazer_id bigint primary key generated always as identity,
    imie       varchar(255) not null,
    nazwisko   varchar(255)
);

CREATE TABLE IF NOT EXISTS bilet
(
    lot_id      bigint         not null,
    pasazer_id  bigint         not null,
    cena        decimal(20, 2) not null default 0 check ( cena >= 0 ),
    miejce      varchar(4)     not null,
    klasa       int            not null,
    data_zakupu timestamp      not null default current_timestamp,
    primary key (lot_id, pasazer_id),
    foreign key (lot_id) references lot (lot_id),
    foreign key (pasazer_id) references pasazer (pasazer_id)
);

-- Procedures

