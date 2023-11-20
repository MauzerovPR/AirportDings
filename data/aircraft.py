import requests
import pandas as pd
import random


def get_aircraft_data() -> pd.DataFrame:
    frames = pd.read_html("https://en.wikipedia.org/wiki/List_of_commercial_jet_airliners")

    planes = frames[0], #frames[2]
    for plane in planes:
        plane.columns = list(range(1, 9))
    planes = pd.concat(planes)

    planes = planes.replace(to_replace=r"\[.+?\]", value="", regex=True)
    planes[9] = pd.Series((random.randint(20, 40) * 10 for _ in range(len(planes))), index=planes.index)

    return planes[[1, 3, 9, 2]]
