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