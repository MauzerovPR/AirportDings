DROP DATABASE IF EXISTS AirLine;
CREATE DATABASE IF NOT EXISTS AirLine;

USE AirLine;

CREATE TABLE IF NOT EXISTS Airport
(
    airport_id bigint primary key generated always as identity,
    name       varchar(255) not null,
    valid      bool         not null default false
);

CREATE TABLE IF NOT EXISTS Aircraft
(
    aircraft_id bigint primary key generated always as identity,
    type        varchar(255),
    seats       int not null check ( seats > 0 )
);

CREATE TABLE IF NOT EXISTS Pilot
(
    pilot_id bigint primary key generated always as identity,
    name     varchar(255) not null,
    surname  varchar(255)
);

CREATE TABLE IF NOT EXISTS Flight
(
    flight_id       bigint primary key generated always as identity,
    origin          bigint    not null,
    destination     bigint    not null,
    next_flight     bigint    null     default null,
    aircraft_id     bigint    not null,
    pilot_id        bigint    not null,
    copilot_id      bigint    not null,
    departure_time  timestamp not null default current_timestamp,
    approx_duration timestamp not null,
    foreign key (origin) references Airport (airport_id),
    foreign key (destination) references Airport (airport_id),
    foreign key (next_flight) references Airport (airport_id),
    foreign key (pilot_id) references Pilot (pilot_id),
    foreign key (copilot_id) references Pilot (pilot_id),
    foreign key (aircraft_id) references Aircraft (aircraft_id),
    check ( origin <> destination ),
    check ( copilot_id <> pilot_id )
);

CREATE TABLE IF NOT EXISTS Passenger
(
    passenger_id bigint primary key generated always as identity,
    name         varchar(255) not null,
    surname      varchar(255)
);

CREATE TABLE IF NOT EXISTS Ticket
(
    flight_id    bigint         not null,
    passenger_id bigint         not null,
    cost         decimal(20, 2) not null default 0 check ( cost >= 0 ),
    seat         varchar(4)     not null,
    primary key (flight_id, passenger_id),
    foreign key (flight_id) references Flight (flight_id),
    foreign key (passenger_id) references Passenger (passenger_id)
);