/**
  Zwraca nazwy lotnisk, do których sprzedano najwiecej biletów,
  oraz wykonano najwięcej lotów.
**/
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