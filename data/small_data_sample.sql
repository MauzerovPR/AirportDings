INSERT INTO samolot(model, miejsca)
VALUES ('Boing 737', 400),
       ('Airbus A320', 370);

INSERT INTO Pilot(imie, nazwisko)
VALUES ('Jerry', 'Green'),
       ('Josh', 'Blue'),
       ('Ashley', 'Black'),
       ('Josh', 'White');

INSERT INTO pasazer(imie, nazwisko)
VALUES ('Jerry', 'Green'),
       ('Josh', 'Blue'),
       ('Ashley', 'Black'),
       ('Josh', 'White');

INSERT INTO lotnisko(nazwa, czynny)
VALUES ('Anaa Airport', true),
       ('Arraias Airport', true),
       ('Golfo de Morrosquillo Airport', true),
       ('Upington Airport', true),
       ('Lomlom Airport', true);

INSERT INTO lot(pochodzenie, kierunek, nastepny_lot, samolot_id, pilot_id, drugi_pilot_id, dlugosc_lotu)
VALUES (1, 2, 2, 1, 1, 2, INTERVAL '2 hours'),
       (2, 3, 3, 1, 1, 2, INTERVAL '150 minutes'),
       (3, 4, NULL, 1, 1, 2, INTERVAL '1 hour'),
       (2, 4, 5, 2, 3, 4, INTERVAL '10 hours 45 minutes'),
       (4, 3, NULL, 2, 3, 4, INTERVAL '4 hours 5 minutes'),
       (1, 2, null, 2, 2, 3, INTERVAL '12 hours 20 minutes'),
       (4, 3, null, 2, 1, 3, INTERVAL '8 hours 44 minutes');

INSERT INTO bilet(lot_id, pasazer_id, cena, miejce, klasa)
VALUES (1, 1, 10, 'abcd', 1),
       (1, 2, 10, 'abed', 1),
       (2, 1, 10, '235', 1),
       (3, 1, 20, '5435', 2),
       (6, 2, 200, '5acc', 2);

-- Trigger OgraniczIloscPasazerow test:
DO $$
DECLARE i INT;
BEGIN
    FOR i IN 1..398 LOOP
        INSERT INTO pasazer(imie, nazwisko) VALUES (i::text, i::text);
        INSERT INTO bilet(lot_id, pasazer_id, cena, miejce, klasa)
            VALUES (1, i + 2, (1.5 * i)::int, LEFT((1234 * i)::text, 4), 2);
    END LOOP;
END $$;

-- Trigger UnikajCyklicznychLotów test:

INSERT INTO lot(pochodzenie, kierunek, nastepny_lot, samolot_id, pilot_id, drugi_pilot_id, dlugosc_lotu)
VALUES (1, 2, NULL, 1, 1, 2, INTERVAL '1 hour'), -- 8
       (1, 2, NULL, 1, 1, 2, INTERVAL '1 hour'), -- 9
       (1, 2, NULL, 1, 1, 2, INTERVAL '1 hour'); -- 10
-- also works with UPDATE. change above to NULL for proper test
UPDATE lot SET nastepny_lot = 9 WHERE lot_id = 8;
UPDATE lot SET nastepny_lot = 10 WHERE lot_id = 9;
UPDATE lot SET nastepny_lot = 8 WHERE lot_id = 10;