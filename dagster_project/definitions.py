"""Dagster entrypoint wiring dlt ingestion + dbt build + hourly schedule."""
from __future__ import annotations

from pathlib import Path

from dagster import Definitions, ScheduleDefinition, define_asset_job, asset
from dagster_dbt import DbtCliResource, dbt_assets


DBT_PROJECT_DIR = Path(__file__).resolve().parent.parent
MANIFEST_PATH = DBT_PROJECT_DIR / "target" / "manifest.json"


@asset(compute_kind="dlt")
def raw_epex_prices() -> None:
    from dlt_pipelines.epex_pipeline import run
    run()


@asset(compute_kind="dlt")
def raw_meter_readings() -> None:
    from dlt_pipelines.meters_pipeline import run
    run()


@dbt_assets(manifest=MANIFEST_PATH)
def dbt_project_assets(context, dbt: DbtCliResource):
    yield from dbt.cli(["build"], context=context).stream()


all_assets_job = define_asset_job("all_assets_job", selection="*")
hourly_schedule = ScheduleDefinition(job=all_assets_job, cron_schedule="15 * * * *")

defs = Definitions(
    assets=[raw_epex_prices, raw_meter_readings, dbt_project_assets],
    jobs=[all_assets_job],
    schedules=[hourly_schedule],
    resources={"dbt": DbtCliResource(project_dir=str(DBT_PROJECT_DIR))},
)
