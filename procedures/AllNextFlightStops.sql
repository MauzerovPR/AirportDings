CREATE OR REPLACE FUNCTION WszystkiePrzystankiLotu(id BIGINT)
    RETURNS TABLE (
        lp             bigint,
        nazwa_lotniska varchar(255)
    ) AS $$ BEGIN
    RETURN QUERY
        WITH RECURSIVE cte AS (
            SELECT f.pochodzenie, f.kierunek, f.nastepny_lot, f.data_odlotu
            FROM lot f
            WHERE f.lot_id = id
            UNION
            SELECT f.pochodzenie, f.kierunek, f.nastepny_lot, f.data_odlotu
            FROM lot f
            INNER JOIN cte ON cte.nastepny_lot = f.lot_id
        )
        SELECT ROW_NUMBER() OVER () AS index, lotnisko.nazwa
        FROM cte
        INNER JOIN lotnisko ON lotnisko_id = kierunek;
END $$ LANGUAGE plpgsql;

SELECT * FROM WszystkiePrzystankiLotu(1);
