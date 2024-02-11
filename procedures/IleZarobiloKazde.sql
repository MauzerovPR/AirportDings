/**
 * @brief Funkcja zwraca kwartał roku na podstawie podanej daty.
 *
 * Funkcja zwraca kwartał roku na podstawie daty podanej jako argument.
 *
 * @param d Data, dla której ma zostać określony kwartał roku.
 * @return Tekstowa reprezentacja kwartału roku w formacie "RRRR.Q", gdzie RRRR to rok, a Q to numer kwartału.
 */
CREATE OR REPLACE FUNCTION KwartalRoku(d TIMESTAMP)
    RETURNS TEXT AS $$ BEGIN
    RETURN (extract(year from d)::text || '.Q' || extract(quarter from d)::text);
END $$ LANGUAGE plpgsql;


/**
 * @brief Funkcja zwraca informacje o zarobkach dla każdego lotu.
 *
 * Funkcja zwraca zestaw danych zawierających identyfikator lotu, 
 * łączny zarobek ze sprzedaży biletów oraz kwartał, w którym odbył się lot.
 *
 * @return Zestaw danych zawierający informacje o zarobkach dla każdego lotu.
 */
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
 * @brief Funkcja zwraca informacje o zarobkach dla każdego samolotu.
 *
 * Funkcja zwraca zestaw danych zawierających identyfikator samolotu, 
 * łączny zarobek ze sprzedaży biletów oraz kwartał, w którym odbyły się loty obsługiwane przez ten samolot.
 *
 * @return Zestaw danych zawierający informacje o zarobkach dla każdego samolotu.
 */
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
 * @brief Funkcja zwraca informacje o zarobkach dla każdego lotniska.
 *
 * Funkcja zwraca zestaw danych zawierających nazwę lotniska, 
 * łączny zarobek ze sprzedaży biletów oraz kwartał, w którym odbyły się loty z i do tego lotniska.
 *
 * @param z_pochodzeniem Określa, czy uwzględniać loty wychodzące z danego lotniska. Domyślnie True.
 * @param z_kierunkiem Określa, czy uwzględniać loty kierujące się do danego lotniska. Domyślnie True.
 * @return Zestaw danych zawierający informacje o zarobkach dla każdego lotniska.
 */
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
