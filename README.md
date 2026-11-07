# Energy Market Analytics Platform — Dynamic Tariff Modelling

End-to-end analytics engineering project modelling **EPEX day-ahead spot prices**, **household smart-meter consumption**, and **simulated dynamic-tariff positions** on BigQuery with dbt, MetricFlow, Dagster, and dlt.

## Stack

| Layer | Tool |
|---|---|
| Ingestion | **dlt** → BigQuery raw |
| Warehouse | **BigQuery** |
| Modelling | **dbt** (staging / intermediate / marts) |
| Semantic layer | **MetricFlow** |
| Orchestration | **Dagster** |
| BI | **Metabase** |
| CI | **GitHub Actions** |
| Authoring | **Claude Code** |

## Data model

**Grain:** 15-minute consumption intervals per household.

**Facts**
- `fct_consumption_intervals` — 15-min meter readings joined with price + tariff context
- `fct_tariff_positions` — simulated dynamic-tariff savings vs flat tariff

**Dimensions**
- `dim_date`, `dim_hour`, `dim_household`, `dim_grid_zone`
- `dim_tariff` — **SCD Type 2** (effective_from / effective_to / is_current)

## Metrics (MetricFlow)

Defined in `semantic_models/` and exposed through MetricFlow so Metabase and ad-hoc queries share one definition:
`total_consumption_kwh`, `active_households`, `avg_consumption_per_household_kwh`, `avg_household_bill_eur`, `avg_price_eur_per_kwh`, and more.

## Local setup

```bash
git clone https://github.com/rubanbuddha/energy-market-analytics.git
cd energy-market-analytics
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp profiles.yml.example ~/.dbt/profiles.yml
cp .env.example .env
dbt deps && dbt seed && dbt build
dbt docs generate && dbt docs serve
```

## CI

Every PR runs `dbt deps` → `dbt build --select state:modified+` → `sqlfluff lint`.

## License

MIT
