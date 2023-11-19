import requests
import pandas as pd
from typing import Any, Dict, List, Optional, Union
from string import ascii_uppercase
import lxml


def get_airport_data() -> list[pd.DataFrame]:
    frames = []

    base_url = "https://en.wikipedia.org/wiki/List_of_airports_by_IATA_airport_code:_"

    for char in ascii_uppercase[0:]:
        url = base_url + char

        table = pd.read_html(url, header=0)[0]
        table = table.iloc[:, :6]
        # Remove rows where each cell has the same value
        table = table[table["IATA"] != table["ICAO"]]

        # replace [\d+] with "" in each cell
        table = table.replace(to_replace=r"\[\d+\]", value="", regex=True)

        frames.append(table.copy())

    return frames
