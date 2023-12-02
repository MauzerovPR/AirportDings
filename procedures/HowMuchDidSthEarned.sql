CREATE OR REPLACE FUNCTION HowMuchEachFlightEarned()
RETURNS TABLE (id BIGINT, earning DECIMAL(20, 2)) AS $$ BEGIN
    RETURN QUERY SELECT ticket.flight_id as id, SUM(ticket.cost)
    FROM ticket
    GROUP BY ticket.flight_id
    ORDER BY ticket.flight_id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION HowMuchEachPlaneEarned()
RETURNS TABLE (id BIGINT, earning DECIMAL(20, 2)) AS $$ BEGIN
    RETURN QUERY
    SELECT flight.aircraft_id, SUM(ticket.cost)
    FROM ticket
    INNER JOIN flight USING (flight_id)
    GROUP BY flight.aircraft_id
    ORDER BY flight.aircraft_id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION HowMuchEachAirportEarned(with_origin BOOLEAN default True, with_destination BOOLEAN default True)
RETURNS TABLE (id BIGINT, earning DECIMAL(20, 2)) AS $$ BEGIN
    RETURN QUERY
    SELECT airport, SUM(ticket.cost)
    FROM ticket
    INNER JOIN (
        SELECT flight_id, origin as airport FROM flight WHERE with_origin = True
        UNION ALL SELECT flight_id, destination FROM flight WHERE with_destination = True
    ) airports USING (flight_id) -- ON ticket.flight_id = airport
    GROUP BY airport
    ORDER BY airport;
END $$ LANGUAGE plpgsql;

SELECT * FROM HowMuchEachFlightEarned();
SELECT * FROM HowMuchEachPlaneEarned();
SELECT * FROM HowMuchEachAirportEarned(with_destination := False);