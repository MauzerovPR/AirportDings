CREATE OR REPLACE FUNCTION IloscLotowBezposrednich()
    RETURNS INTEGER
    AS $$ BEGIN
    RETURN (
        SELECT COUNT(*) ilosc
        FROM lot poprzedni
        RIGHT JOIN lot ON poprzedni.nastepny_lot = lot.lot_id
        WHERE poprzedni.lot_id IS NULL
          AND lot.nastepny_lot IS NULL
    );
END $$ LANGUAGE plpgsql;

SELECT IloscLotowBezposrednich() as ilosc;