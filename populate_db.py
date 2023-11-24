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
     lambda row, acc:
     acc.append("('{}', '{}')".format(row[0].replace(
         "'", "''"), row[1].replace("'", "''"))),
     lambda acc:
     cursor.execute(
         f"INSERT INTO passenger(name,surname) VALUES {','.join(acc)}")
     ],
    ["pilots",
     lambda row, acc:
     acc.append("('{}', '{}')".format(row[0].replace(
         "'", "''"), row[1].replace("'", "''"))),
     lambda acc:
     cursor.execute(
         f"INSERT INTO pilot(name,surname) VALUES {','.join(acc)}")
    ],
    ["airports",
     lambda row, acc:
     acc.append("('{}', true)".format(row[2].replace("'", "''"))),
     lambda acc:
     cursor.execute(
         f"INSERT INTO airport(name, valid) VALUES {','.join(acc)}")
     ],
    ["aircrafts",
     lambda row, acc:
     acc.append("('{}', '{}')".format(row[0].replace(
         "'", "''"), row[2].replace("'", "''"))),
     lambda acc:
     cursor.execute(f"INSERT INTO aircraft(type,seats) VALUES {','.join(acc)}")
     ]
    ]

    for x in data:
        file_name= f"./data/{x[0]}.csv"
        with open(file_name) as f:
            reader= csv.reader(f, delimiter=";")
            acc= []
            for row in tqdm(reader, desc=x[0], total=sum(1 for _ in open(file_name))):
                x[1](row, acc)
            x[2](acc)

    conn.commit()

    cursor.execute("SELECT airport_id FROM airport")
    airport_ids= cursor.fetchall()
    cursor.execute("SELECT aircraft_id FROM aircraft")
    aircraft_ids= cursor.fetchall()
    cursor.execute("SELECT pilot_id FROM pilot")
    pilot_ids= cursor.fetchall()

    values= []
    for x in tqdm(range(100000), desc="flights"):
        origin_id= airport_ids[randint(0, len(airport_ids)-1)][0]
        while True:
            dest_id= airport_ids[randint(0, len(airport_ids)-1)][0]
            if dest_id != origin_id:
                break
        aircraft_id= aircraft_ids[randint(0, len(aircraft_ids)-1)][0]
        pilot_id= pilot_ids[randint(0, len(pilot_ids)-1)][0]
        while True:
            copilot_id= pilot_ids[randint(0, len(pilot_ids)-1)][0]
            if copilot_id != pilot_id:
                break

        duration= f'0 {randint(0,3)}:{randint(0,59)}:00'
        values.append(
            f"({origin_id},{dest_id},NULL,{aircraft_id},{pilot_id},{copilot_id}, '{duration}')")
    print("executing insert... \nthis may take a while")
    cursor.execute(
        f"INSERT INTO flight(origin,destination,next_flight,aircraft_id,pilot_id,copilot_id,approx_duration) VALUES {','.join(values)}")

    cursor.execute(
        "SELECT passenger_id FROM passenger")
    passenger_ids= cursor.fetchall()
    cursor.execute(
        "SELECT flight_id FROM flight")
    flight_ids= cursor.fetchall()

    pi, fi= 0, 0

    values= []
    for x in tqdm(range(1000000), desc="tickets"):
        pi= (pi + 1) % len(passenger_ids)
        fi= (fi + 1) % len(flight_ids)
        passenger_id= passenger_ids[pi][0]
        flight_id= flight_ids[fi][0]

        seat= "".join([chr(randint(ord('a'), ord('z')))
                       for _ in range(randint(1, 4))])
        price= randint(0, 10000)/10
        values.append(f"({passenger_id},{flight_id},{price},'{seat}')")

    print("executing insert... \nthis may take a while")
    query= f"INSERT INTO ticket(passenger_id, flight_id,cost,seat) VALUES {','.join(values)}"
    cursor.execute(query)
    conn.commit()
