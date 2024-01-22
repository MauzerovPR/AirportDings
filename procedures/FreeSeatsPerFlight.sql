/**
  Zwraca:
    - ilość miejsc w samolocie
    - ilość wolnych miejsc w samolocie
    - ilość sprzedanyc biletów (zajętych miejsc)
    - procent zapełnienia samolotu
    - procent wolnych miejsc
**/
CREATE OR REPLACE FUNCTION WolneMiejscaKazdegoLotu()
    RETURNS TABLE (
        id                      BIGINT,
        miejsca                 INT,
        wolne_miejsca           INT,
        zajete_miejsca          INT,
        procent_zajetych_miejsc DECIMAL(3, 3),
        procent_wolnych_miejsc  DECIMAL(3, 3)
    ) AS $$ BEGIN
    RETURN QUERY
        SELECT lot.lot_id,
               samolot.miejsca,
               samolot.miejsca - bilety,
               bilety,
               ROUND(bilety::decimal / samolot.miejsca * 100, 3),
               ROUND((samolot.miejsca - bilety)::decimal / samolot.miejsca * 100, 3)
        FROM lot
        INNER JOIN samolot USING (samolot_id)
        INNER JOIN (
            SELECT bilet.lot_id, COUNT(*)::int bilety
            FROM bilet
            GROUP BY lot_id
        ) AS cte USING (lot_id);
END $$ LANGUAGE plpgsql;

SELECT * FROM WolneMiejscaKazdegoLotu()