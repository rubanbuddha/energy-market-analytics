"""dlt pipeline that lands day-ahead EPEX spot prices into BigQuery.

In production, swap `simulated_prices` for the real ENTSO-E Transparency
Platform API. The warehouse layer downstream is identical either way.
"""
from __future__ import annotations

import os
import random
from datetime import datetime, timedelta, timezone

import dlt


GRID_ZONES = ["50Hertz", "Amprion", "TenneT", "TransnetBW"]


@dlt.resource(
    name="day_ahead_prices",
    primary_key=("delivery_hour_utc", "grid_zone"),
    write_disposition="merge",
)
def simulated_prices(start_days_ago: int = 30):
    now = datetime.now(tz=timezone.utc).replace(minute=0, second=0, microsecond=0)
    start = now - timedelta(days=start_days_ago)
    hour = start
    while hour <= now:
        base = 55 + 35 * max(0, hour.hour - 17) / 5 + random.gauss(0, 8)
        for i, zone in enumerate(GRID_ZONES):
            yield {
                "delivery_hour_utc": hour.isoformat(),
                "grid_zone": zone,
                "price_eur_per_mwh": round(max(5.0, base + i * 2.5 + random.gauss(0, 4)), 2),
            }
        hour += timedelta(hours=1)


def run():
    pipeline = dlt.pipeline(
        pipeline_name="epex_day_ahead",
        destination="bigquery",
        dataset_name="raw_epex",
    )
    load_info = pipeline.run(simulated_prices(
        start_days_ago=int(os.getenv("EPEX_WINDOW_DAYS", "30"))
    ))
    print(load_info)


if __name__ == "__main__":
    run()
