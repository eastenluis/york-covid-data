import csv
import sys
import requests
from collections import defaultdict
from datetime import datetime

from pytz import timezone

CASE_DATA_URL = "https://ww4.yorkmaps.ca/COVID19/Data/YR_CaseData.csv"


def handler(event, context):
    response = requests.get(CASE_DATA_URL)
    response.raise_for_status()

    csv_text = response.text.splitlines()
    reader = csv.reader(csv_text, delimiter=",")
    # Skip header
    next(reader)

    today = datetime.now(timezone("America/Toronto")).date()
    case_map_by_age_group = defaultdict(int)
    case_map_by_municipality = defaultdict(int)

    for row in reader:
        age_group = row[2]
        municipality = row[3]
        try:
            date_reported = datetime.strptime(row[5], "%m/%d/%Y").date()
        except Exception as e:
            continue
        status = row[8]

        # Filter out resolved/deceased case and cases reported > 2 days
        if date_reported != today or status.lower() in [
            "resolved",
            "deceased",
        ]:
            continue

        case_map_by_age_group[age_group] += 1
        case_map_by_municipality[municipality] += 1

    print(case_map_by_municipality)
