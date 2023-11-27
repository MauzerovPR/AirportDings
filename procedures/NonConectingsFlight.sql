CREATE OR REPLACE FUNCTION NonConectingFlight()
RETURNS INTEGER AS $$
BEGIN
RETURN (
    SELECT COUNT(*) count
    FROM flight prev
    RIGHT JOIN flight ON prev.next_flight = flight.flight_id
    WHERE prev.flight_id IS NULL AND flight.next_flight IS NULL
);
END $$ LANGUAGE plpgsql;