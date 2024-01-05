DROP FUNCTION IF EXISTS PopularFlightDestinations();

CREATE OR REPLACE FUNCTION PopularFlightDestinations()
RETURNS TABLE (
    airport VARCHAR(255),
    tickets_sold BIGINT,
    flights_done BIGINT
) AS $$ BEGIN
    RETURN QUERY
    SELECT
        airport.name,
        COUNT(*) tickets_sold,
        COUNT(DISTINCT flight_id) flights_done
    FROM flight
    INNER JOIN airport ON destination = airport.airport_id
    INNER JOIN ticket USING (flight_id)
    GROUP BY airport.name
    ORDER BY flights_done DESC, tickets_sold DESC;
END $$ LANGUAGE plpgsql;

SELECT * FROM PopularFlightDestinations();