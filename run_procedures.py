from os import listdir
from os.path import isfile, join
from pathlib import Path

from connection import connect;


PROCEDURES_DIR = Path.cwd() / "procedures"


if __name__ == "__main__":
    cursor = connect().cursor()
    for file_name in listdir(PROCEDURES_DIR):
        with open(PROCEDURES_DIR / file_name) as f:
            query = f.read()
            cursor.execute(query)




