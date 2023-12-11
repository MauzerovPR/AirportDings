CREATE OR REPLACE FUNCTION QuarterYear(d TIMESTAMP)
RETURNS TEXT AS $$ BEGIN
	RETURN (extract(year from d)::text || '.Q' || extract(quarter from d)::text);
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION HowMuchEachFlightEarned()
RETURNS TABLE (id BIGINT, earning DECIMAL(20, 2), quarter TEXT) AS $$ BEGIN
    RETURN QUERY
    SELECT ticket.flight_id as id, SUM(ticket.cost), QuarterYear(departure_time) as quarter
    FROM ticket
	INNER JOIN flight USING (flight_id)
    GROUP BY ticket.flight_id, quarter
    ORDER BY ticket.flight_id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION HowMuchEachPlaneEarned()
RETURNS TABLE (id BIGINT, earning DECIMAL(20, 2), quarter TEXT) AS $$ BEGIN
    RETURN QUERY
    SELECT flight.aircraft_id, SUM(ticket.cost), QuarterYear(departure_time) as quarter
    FROM ticket
    INNER JOIN flight USING (flight_id)
    GROUP BY flight.aircraft_id, quarter
    ORDER BY flight.aircraft_id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION HowMuchEachAirportEarned(with_origin BOOLEAN default True, with_destination BOOLEAN default True)
RETURNS TABLE (id BIGINT, earning DECIMAL(20, 2), quarter TEXT) AS $$ BEGIN
    RETURN QUERY
    SELECT airport, SUM(ticket.cost), QuarterYear(departure_time) as quarter
    FROM ticket
    INNER JOIN (
        SELECT flight_id, origin as airport, departure_time  FROM flight WHERE with_origin = True
        UNION ALL SELECT flight_id, destination, departure_time FROM flight WHERE with_destination = True
    ) airports USING (flight_id)
    GROUP BY airport, quarter
    ORDER BY airport;
END $$ LANGUAGE plpgsql;

SELECT * FROM HowMuchEachFlightEarned();
SELECT * FROM HowMuchEachPlaneEarned();
SELECT * FROM HowMuchEachAirportEarned(with_destination := False);