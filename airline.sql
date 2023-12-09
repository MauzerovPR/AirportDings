drop schema public cascade;
create schema public;


CREATE TABLE IF NOT EXISTS airport
(
    airport_id bigint primary key generated always as identity,
    name       varchar(255) not null,
    valid      bool         not null default false
);

CREATE TABLE IF NOT EXISTS aircraft
(
    aircraft_id bigint primary key generated always as identity,
    type        varchar(255),
    seats       int not null check ( seats > 0 )
);

CREATE TABLE IF NOT EXISTS pilot
(
    pilot_id bigint primary key generated always as identity,
    name     varchar(255) not null,
    surname  varchar(255)
);

CREATE TABLE IF NOT EXISTS flight
(
    flight_id       bigint primary key generated always as identity,
    origin          bigint    not null,
    destination     bigint    not null,
    next_flight     bigint    null     default null,
    aircraft_id     bigint    not null,
    pilot_id        bigint    not null,
    copilot_id      bigint    not null,
    departure_time  timestamp not null default current_timestamp,
    approx_duration interval  not null,
    foreign key (origin) references Airport (airport_id),
    foreign key (destination) references Airport (airport_id),
    foreign key (next_flight) references Flight (flight_id),
    foreign key (pilot_id) references Pilot (pilot_id),
    foreign key (copilot_id) references Pilot (pilot_id),
    foreign key (aircraft_id) references Aircraft (aircraft_id),
    check ( origin <> destination ),
    check ( copilot_id <> pilot_id )
);

CREATE TABLE IF NOT EXISTS passenger
(
    passenger_id bigint primary key generated always as identity,
    name         varchar(255) not null,
    surname      varchar(255)
);

CREATE TABLE IF NOT EXISTS ticket
(
    flight_id    bigint         not null,
    passenger_id bigint         not null,
    cost         decimal(20, 2) not null default 0 check ( cost >= 0 ),
    seat         varchar(4)     not null,
    primary key (flight_id, passenger_id),
    foreign key (flight_id) references Flight (flight_id),
    foreign key (passenger_id) references Passenger (passenger_id)
);

-- CREATE TABLE IF NOT EXISTS distance
-- (
--     airport_a  bigint not null,
--     airport_b  bigint not null,
--     kilometers int    not null,
--     primary key (airport_a, airport_b),
--     foreign key (airport_a) references airport (airport_id),
--     foreign key (airport_b) references airport (airport_id),
--     UNIQUE (airport_a, airport_b)
-- );

-- CREATE OR REPLACE FUNCTION NewDistanceCheck()
--     RETURNS TRIGGER AS
-- $$
-- BEGIN
--     IF EXISTS((SELECT *
--                FROM distance
--                WHERE (airport_a = NEW.airport_a AND airport_b = new.airport_b)
--                   OR (airport_a = NEW.airport_b AND airport_b = new.airport_a))) THEN
--         RETURN NULL; -- cancel insertion
--     END IF;
--     RETURN NEW;
-- END
-- $$ LANGUAGE plpgsql;
--
-- CREATE OR REPLACE TRIGGER NewDistanceAdded
--     BEFORE INSERT
--     ON distance
--     FOR EACH ROW
-- EXECUTE PROCEDURE NewDistanceCheck();


-- Data Insertion --

INSERT INTO Aircraft(type, seats)
VALUES ('Boing 737', 400),
       ('Airbus A320', 370);

INSERT INTO Pilot(name, surname)
VALUES ('Jerry', 'Green'),
       ('Josh', 'Blue'),
       ('Ashley', 'Black'),
       ('Josh', 'White');

INSERT INTO Passenger(name, surname)
VALUES ('Jerry', 'Green'),
       ('Josh', 'Blue'),
       ('Ashley', 'Black'),
       ('Josh', 'White');

INSERT INTO Airport(name, valid)
VALUES ('Anaa Airport', true),
       ('Arraias Airport', true),
       ('Golfo de Morrosquillo Airport', true),
       ('Upington Airport', true),
       ('Lomlom Airport', true);

INSERT INTO Flight(origin, destination, next_flight, aircraft_id, pilot_id, copilot_id, approx_duration)
VALUES (1, 2, 2, 1, 1, 2, INTERVAL '2 hours'),
       (2, 3, 3, 1, 1, 2, INTERVAL '150 minutes'),
       (3, 4, NULL, 1, 1, 2, INTERVAL '1 hour'),
       (2, 4, 5, 2, 3, 4, INTERVAL '10 hours 45 minutes'),
       (4, 3, NULL, 2, 3, 4, INTERVAL '4 hours 5 minutes'),
       (1, 2, null, 2, 2, 3, INTERVAL '12 hours 20 minutes'),
       (4, 3, null, 2, 1, 3, INTERVAL '8 hours 44 minutes');

INSERT INTO Ticket(flight_id, passenger_id, cost, seat)
VALUES (1, 1, 10, 'abcd'),
       (2, 1, 10, '235'),
       (3, 1, 20, '5435'),
       (6, 2, 200, '5acc');

-- INSERT INTO distance(airport_a, airport_b, kilometers)
-- VALUES (1, 2, 1000),
--        (2, 3, 4000),
--        (2, 1, 4000);