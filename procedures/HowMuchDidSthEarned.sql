CREATE OR REPLACE FUNCTION KwartalRoku(d TIMESTAMP)
    RETURNS TEXT AS $$ BEGIN
    RETURN (extract(year from d)::text || '.Q' || extract(quarter from d)::text);
END $$ LANGUAGE plpgsql;

/**
  Zwraca sumę kosztów sprzedanych biletów, dla każdego lotu.
**/
CREATE OR REPLACE FUNCTION IleZarobilKazdyLot()
    RETURNS TABLE (
        id      BIGINT,
        zarobek DECIMAL(20, 2),
        kwartal TEXT
    ) AS $$ BEGIN
    RETURN QUERY
        SELECT bilet.lot_id as id, SUM(bilet.cena), KwartalRoku(data_odlotu) as kwartal
        FROM bilet
        INNER JOIN lot USING (lot_id)
        GROUP BY bilet.lot_id, kwartal
        ORDER BY bilet.lot_id;
END $$ LANGUAGE plpgsql;

/**
  Zwraca sumę kosztów sprzedanych biletów, dla każdego samolotu.
**/
CREATE OR REPLACE FUNCTION IleZarobilKazdySamolot()
    RETURNS TABLE (
        id      BIGINT,
        zarobek DECIMAL(20, 2),
        kwartal TEXT
    ) AS $$ BEGIN
    RETURN QUERY
        SELECT lot.samolot_id, SUM(bilet.cena), KwartalRoku(data_odlotu) as kwartal
        FROM bilet
        INNER JOIN lot USING (lot_id)
        GROUP BY lot.samolot_id, kwartal
        ORDER BY lot.samolot_id;
END $$ LANGUAGE plpgsql;

/**
  Zwraca sumę kosztów sprzedanych biletów, dla każdego lotniska.
    - z_pochodzeniem: zalicza odloty do zarobków
    - z_kierunkiem: zalicza przyloty do zarobków
    -- pozwala to na wybranie, czy lotnisko zarabia podczas odlotu, przylotu lub obu
**/
CREATE OR REPLACE FUNCTION IleZarobiloKazdeLotnisko(z_pochodzeniem BOOLEAN default True, z_kierunkiem BOOLEAN default True)
    RETURNS TABLE (
        id      BIGINT,
        zarobek DECIMAL(20, 2),
        kwartal TEXT
    ) AS $$ BEGIN
    RETURN QUERY
        SELECT lotnisko, SUM(bilet.cena), KwartalRoku(data_odlotu) as kwartal
        FROM bilet
        INNER JOIN (
            SELECT lot_id, pochodzenie as lotnisko, data_odlotu
            FROM lot
            WHERE z_pochodzeniem = True
            UNION ALL
            SELECT lot_id, kierunek, data_odlotu
            FROM lot
            WHERE z_kierunkiem = True
        ) lotniska USING (lot_id)
        GROUP BY lotnisko, kwartal
        ORDER BY lotnisko;
END $$ LANGUAGE plpgsql;

SELECT * FROM IleZarobilKazdyLot();
SELECT * FROM IleZarobilKazdySamolot();
SELECT * FROM IleZarobiloKazdeLotnisko(z_kierunkiem := False);