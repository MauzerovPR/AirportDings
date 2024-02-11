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

SELECT * FROM LotyWylatujaceZa(interval '1 day');
