/**
  Zwraca kolejne przystanki lotu, wraz z ich liczbą porządkową.

**/
CREATE OR REPLACE FUNCTION WszystkiePrzystankiLotu(id BIGINT)
    RETURNS TABLE (
        lp             bigint,
        nazwa_lotniska varchar(255)
    ) AS $$ BEGIN
    RETURN QUERY
        WITH RECURSIVE cte AS (
            -- pierwszy lot (przypadek bazowy, en. base case)
            SELECT f.pochodzenie, f.kierunek, f.nastepny_lot, f.data_odlotu
            FROM lot f
            WHERE f.lot_id = id
            UNION
            -- rekurencyjne połączenie poprzedniego lotu z następnym
            -- do momentu gdy lot nie ma następnego lotu
            SELECT f.pochodzenie, f.kierunek, f.nastepny_lot, f.data_odlotu
            FROM lot f
            INNER JOIN cte ON cte.nastepny_lot = f.lot_id
        )
        -- ROW_NUMBER() OVER () - dla każdego rekordu daje numer wiersza
        SELECT ROW_NUMBER() OVER () AS lp, lotnisko.nazwa
        FROM cte
        INNER JOIN lotnisko ON lotnisko_id = kierunek;
END $$ LANGUAGE plpgsql;

SELECT * FROM WszystkiePrzystankiLotu(1);
