import csv
from connection import connect
from tqdm import tqdm


if __name__ == "__main__":
    cursor = connect().cursor()
    cursor.execute("TRUNCATE aircraft, flight, passenger, airport, pilot, ticket CASCADE")
    with open("./data/passengers.csv") as people_csv:
        reader = csv.reader(people_csv, delimiter=";")
        for row in tqdm(reader,desc="passengers",total=sum(1 for _ in open("./data/passengers.csv"))):
            name, surname = row[0].replace("'", "''"), row[1].replace("'", "''")
            cursor.execute(f"INSERT INTO passenger(name,surname) VALUES('{name}', '{surname}')")

    with open("./data/pilots.csv") as people_csv:
        reader = csv.reader(people_csv, delimiter=";")
        for row in tqdm(reader,desc="pilots",total=sum(1 for _ in open("./data/pilots.csv"))):
            name, surname = row[0].replace("'", "''"), row[1].replace("'", "''")
            cursor.execute(f"INSERT INTO pilot(name,surname) VALUES('{name}', '{surname}')")
            


