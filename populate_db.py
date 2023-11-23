import csv
from connection import connect
from tqdm import tqdm


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

    for x in tqdm(range(1000), desc="flights"):
        cursor.execute(
            "SELECT airport_id FROM airport ORDER BY RANDOM() LIMIT 1")
        dest_id = cursor.fetchone()[0]
        cursor.execute(
            "SELECT airport_id FROM airport  WHERE NOT airport_id = {} ORDER BY RANDOM() LIMIT 1".format(dest_id))
        origin_id = cursor.fetchone()[0]
        cursor.execute(
            "SELECT aircraft_id FROM aircraft ORDER BY RANDOM() LIMIT 1")
        aircraft_id = cursor.fetchone()[0]
        cursor.execute("SELECT pilot_id FROM pilot ORDER BY RANDOM() LIMIT 1")
        pilot_id = cursor.fetchone()[0]
        cursor.execute(
            "SELECT pilot_id FROM pilot WHERE NOT pilot_id = {} ORDER BY RANDOM() LIMIT 1".format(pilot_id))
        copilot_id = cursor.fetchone()[0]
        cursor.execute(f"""
        INSERT INTO flight(origin,destination,next_flight,aircraft_id,pilot_id,copilot_id,approx_duration) 
        VALUES({origin_id},{dest_id},NULL,{aircraft_id},{pilot_id},{copilot_id},CURRENT_TIMESTAMP)
        """)

    conn.commit()
