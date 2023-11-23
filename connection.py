import psycopg2


def connect():
    return psycopg2.connect("host=127.0.0.1 dbname=airline user=postgres password=postgres")
