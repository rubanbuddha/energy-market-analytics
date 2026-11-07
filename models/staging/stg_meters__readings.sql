{{ config(materialized = 'view') }}

select
    cast(reading_ts_utc as timestamp)      as reading_ts_utc,
    household_id,
    cast(consumption_kwh as numeric)       as consumption_kwh,
    timestamp_trunc(reading_ts_utc, hour)  as delivery_hour_utc,
    extract(hour from reading_ts_utc)      as hour_of_day,
    extract(dayofweek from reading_ts_utc) as day_of_week
from {{ source('raw_meters', 'meter_readings') }}
where reading_ts_utc >= timestamp('{{ var("start_date") }}')
  and consumption_kwh >= 0
