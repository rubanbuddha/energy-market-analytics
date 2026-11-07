{{ config(materialized = 'view') }}

with source as (
    select * from {{ source('raw_epex', 'day_ahead_prices') }}
),

renamed as (
    select
        cast(delivery_hour_utc as timestamp)      as delivery_hour_utc,
        grid_zone,
        cast(price_eur_per_mwh as numeric)        as price_eur_per_mwh,
        cast(price_eur_per_mwh as numeric) / 1000 as price_eur_per_kwh
    from source
    where delivery_hour_utc >= timestamp('{{ var("start_date") }}')
)

select * from renamed
