import requests
import pandas as pd
import random
import string


url = "https://random-data-api.com/api/v2/users?size=100"


def get_person_data() -> (pd.DataFrame, pd.DataFrame):
    all_people = [
        requests.get(url).json() for _ in range(70)
    ]

    people = []
    for thousand in all_people:
        people.extend(thousand)

    for person in people:
        address = person["address"]
        person["address"] =\
            f"{address['street_address']}, {address['city']}, {address['country']}, {address['zip_code']}"

    people = pd.DataFrame(people)
    # people = people[(people["gender"] == "Male") | (people["gender"] == "Female")]
    people = people[["first_name", "last_name", "social_insurance_number", "date_of_birth", "address", "phone_number"]]

    pilots, passengers = people.iloc[:40], people.iloc[40:]
    return pilots, passengers
