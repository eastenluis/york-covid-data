import csv
import os
import requests
from collections import defaultdict
from datetime import datetime

from jinja2 import Template
from pytz import timezone

CASE_DATA_URL = "https://ww4.yorkmaps.ca/COVID19/Data/YR_CaseData.csv"
API_KEY = os.environ["MAILGUN_API_KEY"]
EMAIL_DOMAIN = os.environ["MAILGUN_EMAIL_DOMAIN"]


def send_email_by_mailgun(message_date, message_content, recipients):
    date_str = message_date.strftime("%Y-%m-%d")
    return requests.post(
        f"https://api.mailgun.net/v3/{EMAIL_DOMAIN}/messages",
        auth=("api", API_KEY),
        data={
            "from": f"Covid Newsletter <newsletter@{EMAIL_DOMAIN}>",
            "to": recipients,
            "subject": f"York Region Covid Update: {date_str}",
            "html": message_content,
        },
    )


def handler(event, context):
    response = requests.get(CASE_DATA_URL)
    response.raise_for_status()

    csv_text = response.text.splitlines()
    reader = csv.reader(csv_text, delimiter=",")
    # Skip header
    next(reader)

    today = datetime.now(timezone("America/Toronto")).date()
    total = 0
    case_map_by_age_group = defaultdict(int)
    case_map_by_municipality = defaultdict(int)
    case_map_by_status = defaultdict(int)

    for row in reader:
        age_group = row[2]
        municipality = row[3]
        try:
            date_reported = datetime.strptime(row[5], "%m/%d/%Y").date()
        except Exception as e:
            continue
        status = row[8]

        # Filter out cases reported > 2 days
        if date_reported != today:
            continue
        case_map_by_age_group[age_group] += 1
        case_map_by_municipality[municipality] += 1
        case_map_by_status[status] += 1
        total += 1

    # Load Email Template
    with open("template.html.j2") as template_file:
        template = Template(template_file.read())

    message = template.render(
        news_date=today.strftime("%Y-%m-%d"),
        municipalities=sorted(
            case_map_by_municipality.items(),
            key=lambda item: item[1],
            reverse=True,
        ),
        age_groups=sorted(
            case_map_by_age_group.items(),
            key=lambda item: "00s"
            if item[0].lower() == "under 20"
            else item[0],
        ),
        statuses=case_map_by_status.items(),
        total=total,
    )

    response = send_email_by_mailgun(
        message_date=today,
        message_content=message,
        recipients=event["recipients"],
    )
    return {
        "status": response.status_code,
        "message": response.text,
    }
