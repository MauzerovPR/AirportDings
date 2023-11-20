import psycopg2;

queries = {
        "get_all_passengers": "SELECT * FROM passenger JOIN ticket USING(passenger_id) JOIN flight USING(flight_id) WHERE flight_id = {0}",
        "is_tickets_flight_departed": "SELECT  FROM ticket JOIN flight USING(flight_id) WHERE flight.departure_time > CURRENT_TIMESTAMP AND ticket_id = {0}",
        }

if __name__ == "__main__":
    conn = psycopg2.connect("dbname=LINIE_CHLODNICZE user=postgres password=postgres")
    cursor = conn.cursor()
    ans = cursor.execute(queries["get_all_passengers"].format("1"))
    print(ans)




