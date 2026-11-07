"""dlt pipeline landing simulated smart-meter readings, households
and tariff versions into BigQuery."""
from __future__ import annotations

import random
from datetime import datetime, timedelta, timezone

import dlt


GRID_ZONES = ["50Hertz", "Amprion", "TenneT", "TransnetBW"]
BUILDING_TYPES = ["apartment", "detached_house", "semi_detached", "terraced"]
random.seed(42)


@dlt.resource(name="households", primary_key="household_id", write_disposition="replace")
def households(n: int = 250):
    for i in range(n):
        yield {
            "household_id": f"hh_{i:05d}",
            "grid_zone": random.choice(GRID_ZONES),
            "tariff_type": random.choices(["flat", "dynamic"], weights=[0.3, 0.7])[0],
            "signed_up_at": (
                datetime.now(tz=timezone.utc) - timedelta(days=random.randint(30, 900))
            ).isoformat(),
            "postcode": f"{random.randint(10000, 99999)}",
            "building_type": random.choice(BUILDING_TYPES),
        }


@dlt.resource(
    name="meter_readings",
    primary_key=("household_id", "reading_ts_utc"),
    write_disposition="merge",
)
def meter_readings(days_back: int = 14):
    now = datetime.now(tz=timezone.utc).replace(minute=0, second=0, microsecond=0)
    start = now - timedelta(days=days_back)
    household_ids = [f"hh_{i:05d}" for i in range(250)]
    ts = start
    while ts <= now:
        base_kwh = 0.08 + 0.12 * max(0, ts.hour - 17) / 5 + 0.05 * (ts.hour in (7, 8))
        for hid in household_ids:
            yield {
                "household_id": hid,
                "reading_ts_utc": ts.isoformat(),
                "consumption_kwh": round(max(0.0, base_kwh + random.gauss(0, 0.04)), 4),
            }
        ts += timedelta(minutes=15)


@dlt.resource(name="tariff_versions", primary_key=("tariff_id", "effective_from_utc"), write_disposition="merge")
def tariff_versions():
    base = datetime.now(tz=timezone.utc) - timedelta(days=400)
    for tariff_id, offset in [("dyn_v1", 0), ("dyn_v2", 180), ("dyn_v3", 340)]:
        yield {
            "tariff_id": tariff_id,
            "tariff_name": f"Dynamic Tariff {tariff_id[-1]}",
            "tariff_type": "dynamic",
            "effective_from_utc": (base + timedelta(days=offset)).isoformat(),
            "base_fee_eur": round(8.0 + random.random(), 2),
            "markup_eur_per_kwh": round(0.06 + 0.01 * random.random(), 4),
        }


def run():
    pipeline = dlt.pipeline(
        pipeline_name="meters",
        destination="bigquery",
        dataset_name="raw_meters",
    )
    load_info = pipeline.run([households(), meter_readings(), tariff_versions()])
    print(load_info)


if __name__ == "__main__":
    run()
