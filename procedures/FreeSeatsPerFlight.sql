CREATE OR REPLACE FUNCTION FreeSeatsPerFlight()
RETURNS TABLE (
    id BIGINT,
    seats INT,
    free_seats INT,
    taken_seats_percent DECIMAL(3, 3),
    free_seats_percent DECIMAL(3, 3)
) AS $$ BEGIN
    RETURN QUERY
    SELECT
        flight.flight_id,
        aircraft.seats,
        aircraft.seats - tickets,
        tickets::decimal / aircraft.seats * 100,
        (aircraft.seats - tickets)::decimal / aircraft.seats * 100
    FROM flight
    INNER JOIN aircraft USING(aircraft_id)
    INNER JOIN (
        SELECT ticket.flight_id, COUNT(*)::int tickets
        FROM ticket
        GROUP BY flight_id
    ) AS cte USING(flight_id);
END $$ LANGUAGE plpgsql;

SELECT * FROM FreeSeatsPerFlight()