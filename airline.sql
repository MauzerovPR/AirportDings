DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

CREATE TABLE IF NOT EXISTS lotnisko
(
    lotnisko_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nazwa       VARCHAR(255) NOT NULL,
    czynny      BOOL         NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS samolot
(
    samolot_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    model      VARCHAR(255),
    miejsca    INT NOT NULL CHECK ( miejsca > 0 )
);

CREATE TABLE IF NOT EXISTS pilot
(
    pilot_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    imie     VARCHAR(255) NOT NULL,
    nazwisko VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS lot
(
    lot_id         BIGINT    PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    pochodzenie    BIGINT    NOT NULL,
    kierunek       BIGINT    NOT NULL,
    nastepny_lot   BIGINT    NULL     DEFAULT NULL,
    samolot_id     BIGINT    NOT NULL,
    pilot_id       BIGINT    NOT NULL,
    drugi_pilot_id BIGINT    NOT NULL,
    data_odlotu    timestamp NOT NULL DEFAULT current_timestamp,
    dlugosc_lotu   interval  NOT NULL,
    opoznienia     interval  NOT NULL DEFAULT '0 minutes',
    FOREIGN KEY (pochodzenie) REFERENCES lotnisko (lotnisko_id),
    FOREIGN KEY (kierunek) REFERENCES lotnisko (lotnisko_id),
    FOREIGN KEY (nastepny_lot) REFERENCES lot (lot_id),
    FOREIGN KEY (pilot_id) REFERENCES Pilot (pilot_id),
    FOREIGN KEY (drugi_pilot_id) REFERENCES Pilot (pilot_id),
    FOREIGN KEY (samolot_id) REFERENCES samolot (samolot_id),
    CHECK ( pochodzenie <> kierunek ),
    CHECK ( drugi_pilot_id <> pilot_id )
);

CREATE TABLE IF NOT EXISTS pasazer
(
    pasazer_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    imie       VARCHAR(255) NOT NULL,
    nazwisko   VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS bilet
(
    lot_id      BIGINT         NOT NULL,
    pasazer_id  BIGINT         NOT NULL,
    cena        decimal(20, 2) NOT NULL DEFAULT 0 CHECK ( cena >= 0 ),
    miejce      VARCHAR(4)     NOT NULL,
    klasa       int            NOT NULL,
    data_zakupu timestamp      NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (lot_id, pasazer_id),
    FOREIGN KEY (lot_id) REFERENCES lot (lot_id),
    FOREIGN KEY (pasazer_id) REFERENCES pasazer (pasazer_id)
);

