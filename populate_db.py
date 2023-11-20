import csv
from connection import connect
from tqdm import tqdm


if __name__ == "__main__":
    cursor = connect().cursor()
    cursor.execute("TRUNCATE aircraft, flight, passenger, airport, pilot, ticket CASCADE")
    with open("./data/passengers.csv") as f:
        reader = csv.reader(f, delimiter=";")
        for row in tqdm(reader,desc="passengers",total=sum(1 for _ in open("./data/passengers.csv"))):
            name, surname = row[0].replace("'", "''"), row[1].replace("'", "''")
            cursor.execute(f"INSERT INTO passenger(name,surname) VALUES('{name}', '{surname}')")

    with open("./data/pilots.csv") as f:
        reader = csv.reader(f, delimiter=";")
        for row in tqdm(reader,desc="pilots",total=sum(1 for _ in open("./data/pilots.csv"))):
            name, surname = row[0].replace("'", "''"), row[1].replace("'", "''")
            cursor.execute(f"INSERT INTO pilot(name,surname) VALUES('{name}', '{surname}')")
            

    with open("./data/airports.csv") as f:
        reader = csv.reader(f, delimiter=";")
        for row in tqdm(reader,desc="airports",total=sum(1 for _ in open("./data/airports.csv"))):
            name = row[2].replace("'", "''")
            cursor.execute(f"INSERT INTO airport(name,valid) VALUES('{name}', true)")

    with open("./data/aircrafts.csv") as f:
        reader = csv.reader(f, delimiter=";")
        for row in tqdm(reader,desc="aircrafts",total=sum(1 for _ in open("./data/aircrafts.csv"))):
            name, seats= row[0].replace("'", "''"), row[2].replace("'", "''")
            cursor.execute(f"INSERT INTO aircraft(type,seats) VALUES('{name}', '{seats}')")


