/**
 * @brief Funkcja zwraca najpopularniejsze miejsca docelowe na podstawie sprzedanych biletów i wykonanych lotów.
 *
 * Funkcja zwraca listę najpopularniejszych miejsc docelowych na podstawie liczby sprzedanych biletów oraz liczby wykonanych lotów.
 *
 * @return Zestaw danych zawierających nazwę lotniska docelowego, liczbę sprzedanych biletów i liczbę wykonanych lotów.
 */
CREATE OR REPLACE FUNCTION NajpopularniejszeMiejscaDocelowe()
    RETURNS TABLE (
        lotnisko     VARCHAR(255),
        sprzedane_bilety BIGINT,
        wykonane_loty    BIGINT
    ) AS $$ BEGIN
    RETURN QUERY
        SELECT lotnisko.nazwa,
               COUNT(*)               sprzedane_bilety,
               COUNT(DISTINCT lot_id) wykonane_loty
        FROM lot
        INNER JOIN lotnisko ON kierunek = lotnisko.lotnisko_id
        INNER JOIN bilet USING (lot_id)
        GROUP BY lotnisko.nazwa
        ORDER BY wykonane_loty DESC, sprzedane_bilety DESC;
END $$ LANGUAGE plpgsql;

SELECT * FROM NajpopularniejszeMiejscaDocelowe();
