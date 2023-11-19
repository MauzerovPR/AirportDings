import airport
import pandas as pd
import aircraft
import people


if __name__ == '__main__':
    airports = airport.get_airport_data()
    airports = pd.concat(airports)
    airports = airports[airports["IATA"] != airports["ICAO"]]

    airports.to_csv("airports.csv", index=False, sep=";", header=False)

    aircrafts = aircraft.get_aircraft_data()
    aircrafts.to_csv("aircrafts.csv", index=False, sep=";", header=False)

    pilots, passengers = people.get_person_data()
    pilots.to_csv("pilots.csv", index=False, sep=";", header=False)
    passengers.to_csv("passengers.csv", index=False, sep=";", header=False)
