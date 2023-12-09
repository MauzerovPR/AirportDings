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

INSERT INTO Ticket(flight_id, passenger_id, cost, seat, class)
VALUES (1, 1, 10, 'abcd', 1),
       (2, 1, 10, '235', 1),
       (3, 1, 20, '5435', 2),
       (6, 2, 200, '5acc', 2);