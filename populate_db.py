import csv
from connection import connect
from tqdm import tqdm
from random import randint


if __name__ == "__main__":
    conn = connect()
    cursor = conn.cursor()
    cursor.execute(
        "TRUNCATE aircraft, flight, passenger, airport, pilot, ticket CASCADE")
    data = [
        ["passengers",
         lambda row:
         cursor.execute(
             "INSERT INTO passenger(name,surname) VALUES('{}', '{}')".format(row[0].replace(
                 "'", "''"), row[1].replace("'", "''")))
         ],
        ["pilots",
         lambda row:
         cursor.execute(
             "INSERT INTO pilot(name,surname) VALUES('{}', '{}')".format(row[0].replace(
                 "'", "''"), row[1].replace("'", "''")))
         ],
        ["airports",
         lambda row:
         cursor.execute(
             "INSERT INTO airport(name,valid) VALUES('{}', true)".format(row[2].replace("'", "''")))
         ],
        ["aircrafts",
         lambda row:
         cursor.execute(
             "INSERT INTO aircraft(type,seats) VALUES('{}', '{}')".format(row[0].replace("'", "''"), row[2].replace("'", "''")))
         ]
    ]

    for x in data:
        file_name = f"./data/{x[0]}.csv"
        with open(file_name) as f:
            reader = csv.reader(f, delimiter=";")
            for row in tqdm(reader, desc=x[0], total=sum(1 for _ in open(file_name))):
                x[1](row)

    conn.commit()

    cursor.execute("SELECT airport_id FROM airport")
    airport_ids = cursor.fetchall()
    cursor.execute("SELECT aircraft_id FROM aircraft")
    aircraft_ids = cursor.fetchall()
    cursor.execute("SELECT pilot_id FROM pilot")
    pilot_ids = cursor.fetchall()

    for x in tqdm(range(100000), desc="flights"):
        origin_id = airport_ids[randint(0, len(airport_ids)-1)][0]
        while True:
            dest_id = airport_ids[randint(0, len(airport_ids)-1)][0]
            if dest_id != origin_id:
                break
        aircraft_id = aircraft_ids[randint(0, len(aircraft_ids)-1)][0]
        pilot_id = pilot_ids[randint(0, len(pilot_ids)-1)][0]
        while True:
            copilot_id = pilot_ids[randint(0, len(pilot_ids)-1)][0]
            if copilot_id != pilot_id:
                break

        cursor.execute(f"""
        INSERT INTO flight(origin,destination,next_flight,aircraft_id,pilot_id,copilot_id,approx_duration)
        VALUES({origin_id},{dest_id},NULL,{aircraft_id},{pilot_id},{copilot_id},CURRENT_TIMESTAMP)
        """)

    cursor.execute(
        "SELECT passenger_id FROM passenger")
    passenger_ids = cursor.fetchall()
    cursor.execute(
        "SELECT flight_id FROM flight")
    flight_ids = cursor.fetchall()
    for x in tqdm(range(1000000), desc="tickets"):
        while True:
            try:
                passenger_id = passenger_ids[randint(
                    0, len(passenger_ids)-1)][0]
                flight_id = flight_ids[randint(0, len(flight_ids)-1)][0]
                seat = "".join([chr(randint(0x41, 0x5A))
                               for _ in range(randint(1, 4))])
                price = randint(0, 10000)/10
                cursor.execute(f"""
                INSERT INTO ticket(passenger_id, flight_id,cost,seat)
                VALUES({passenger_id},{flight_id},{price},'{seat}')
                """)
                break
            except Exception as e:
                print(e)
                exit()

    conn.commit()
