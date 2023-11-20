from csv import reader

from run_queries import get_cursor 

if __name__ == "__main__":
    cursor = get_cursor()
    cursor.execute("TRUNCATE aircraft, flight, passenger, airport, pilot, ticket CASCADE")
    with open("./data/passengers.csv") as people_csv:
        reader = reader(people_csv, delimiter=";")
        for row in reader:
            name, surname = row[0].replace("'", "''"), row[1].replace("'", "''")
            cursor.execute(f"INSERT INTO passenger(name,surname) VALUES('{name}', '{surname}')")
            print(name,surname)


