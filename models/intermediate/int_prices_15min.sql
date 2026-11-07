-- Forward-fills hourly EPEX prices to 15-minute intervals so they can
-- be joined directly to meter readings on their own grain.

with hourly as (
    select * from {{ ref('stg_epex__day_ahead_prices') }}
),

quarters as (
    select
        delivery_hour_utc,
        grid_zone,
        price_eur_per_mwh,
        price_eur_per_kwh,
        timestamp_add(delivery_hour_utc, interval offset_min minute) as interval_start_utc
    from hourly,
    unnest([0, 15, 30, 45]) as offset_min
)

select * from quarters
