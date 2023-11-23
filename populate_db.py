import csv
from connection import connect
from tqdm import tqdm


if __name__ == "__main__":
    cursor = connect().cursor()
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
