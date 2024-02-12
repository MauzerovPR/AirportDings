DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

CREATE TABLE IF NOT EXISTS lotnisko
(
    lotnisko_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nazwa       VARCHAR(255) NOT NULL,
    czynny      BOOL         NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS samolot
(
    samolot_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    model      VARCHAR(255),
    miejsca    INT NOT NULL CHECK ( miejsca > 0 )
);

CREATE TABLE IF NOT EXISTS pilot
(
    pilot_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    imie     VARCHAR(255) NOT NULL,
    nazwisko VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS lot
(
    lot_id         BIGINT    PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    pochodzenie    BIGINT    NOT NULL,
    kierunek       BIGINT    NOT NULL,
    nastepny_lot   BIGINT    NULL     DEFAULT NULL,
    samolot_id     BIGINT    NOT NULL,
    pilot_id       BIGINT    NOT NULL,
    drugi_pilot_id BIGINT    NOT NULL,
    data_odlotu    timestamp NOT NULL DEFAULT current_timestamp,
    dlugosc_lotu   interval  NOT NULL,
    opoznienia     interval  NOT NULL DEFAULT '0 minutes',
    FOREIGN KEY (pochodzenie) REFERENCES lotnisko (lotnisko_id),
    FOREIGN KEY (kierunek) REFERENCES lotnisko (lotnisko_id),
    FOREIGN KEY (nastepny_lot) REFERENCES lot (lot_id),
    FOREIGN KEY (pilot_id) REFERENCES Pilot (pilot_id),
    FOREIGN KEY (drugi_pilot_id) REFERENCES Pilot (pilot_id),
    FOREIGN KEY (samolot_id) REFERENCES samolot (samolot_id),
    CHECK ( pochodzenie <> kierunek ),
    CHECK ( drugi_pilot_id <> pilot_id )
);

CREATE TABLE IF NOT EXISTS pasazer
(
    pasazer_id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    imie       VARCHAR(255) NOT NULL,
    nazwisko   VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS bilet
(
    lot_id      BIGINT         NOT NULL,
    pasazer_id  BIGINT         NOT NULL,
    cena        decimal(20, 2) NOT NULL DEFAULT 0 CHECK ( cena >= 0 ),
    miejce      VARCHAR(4)     NOT NULL,
    klasa       int            NOT NULL,
    data_zakupu timestamp      NOT NULL DEFAULT current_timestamp,
    PRIMARY KEY (lot_id, pasazer_id),
    FOREIGN KEY (lot_id) REFERENCES lot (lot_id),
    FOREIGN KEY (pasazer_id) REFERENCES pasazer (pasazer_id)
);


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


/**
 * @brief Funkcja zwraca liczbę lotów bezpośrednich.
 *
 * Funkcja zwraca liczbę lotów, które nie mają żadnego poprzedniego ani następnego lotu, co oznacza, że są lotami bezpośrednimi.
 *
 * @return Liczba lotów bezpośrednich.
 */
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


/**
 * @brief Funkcja zwraca wszystkie przystanki dla danego lotu.
 *
 * Funkcja zwraca zestaw danych zawierający kolejne przystanki dla danego lotu na podstawie jego identyfikatora.
 
 * @param id Identyfikator lotu, dla którego mają zostać zwrócone przystanki.
 * @return Zestaw danych zawierający kolejne przystanki dla danego lotu.
 */
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


/**
 * @brief Funkcja zwraca informacje o dostępnych miejscach dla każdego lotu.
 *
 * Funkcja zwraca zestaw danych zawierających identyfikator lotu, 
 * liczbę wszystkich miejsc w samolocie, liczbę wolnych miejsc, 
 * liczbę zajętych miejsc, procent zajętych miejsc oraz procent wolnych miejsc.
 *
 * @return Zestaw danych zawierający informacje o dostępnych miejscach dla każdego lotu.
 */
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


/**
 * @brief Funkcja zwraca loty wylatujące w ciągu określonego czasu.
 *
 * Funkcja zwraca listę lotów wylatujących w ciągu zadanego czasu. 
 * Możliwe jest filtrowanie wyników, aby zwrócić tylko te loty, 
 * dla których pozostały jeszcze wolne miejsca na pokładzie.
 *
 * @param czas      Czas w jakim chcemy wyszukać loty wylatujące, 
 *                  domyślnie ustawione na 0 minut.
 * @param czy_pelne Parametr określający, czy zwrócone loty mogą 
 *                  być pełne, czy też należy zwrócić tylko te, 
 *                  dla których są jeszcze dostępne miejsca.
 *                  Domyślnie ustawione na False.
 *
 * @return Zestaw danych zawierających informacje o lotach wylatujących 
 *         w zadanym czasie.
 */
CREATE OR REPLACE FUNCTION LotyWylatujaceZa(czas INTERVAL DEFAULT Interval '0 minutes', czy_pelne BOOL DEFAULT False)
RETURNS SETOF lot AS $$ BEGIN
	RETURN QUERY
	SELECT lot.* FROM lot
	INNER JOIN samolot USING (samolot_id)
	WHERE data_odlotu BETWEEN current_timestamp AND current_timestamp + czas
      AND (
		  samolot.miejsca > (SELECT COUNT(*) FROM bilet WHERE lot_id = lot.lot_id)
		  OR NOT czy_pelne
	  );
END $$ LANGUAGE plpgsql;

