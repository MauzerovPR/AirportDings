
# CHEAT SHEAT
docker run -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d --name postgres postgres \
psql -h 127.0.0.1 -p 5432 -U postgres -f airline.sql

