CREATE OR REPLACE FUNCTION AllFlightStops(id BIGINT)
RETURNS TABLE (index bigint, airport_name varchar(255)) AS $$
BEGIN
RETURN QUERY WITH RECURSIVE cte AS (
    SELECT f.origin, f.destination, f.next_flight, f.departure_time
    FROM Flight f
    WHERE f.flight_id = id
    UNION SELECT f.origin, f.destination, f.next_flight, f.departure_time
    FROM flight f
    INNER JOIN cte ON cte.next_flight = f.flight_id
)
SELECT ROW_NUMBER() OVER () AS index, Airport.name
FROM cte
INNER JOIN Airport ON airport_id = destination;
END $$ LANGUAGE plpgsql;