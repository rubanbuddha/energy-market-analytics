{{ config(materialized = 'view') }}

select
    tariff_id,
    tariff_name,
    tariff_type,
    cast(effective_from_utc as timestamp) as effective_from_utc,
    cast(base_fee_eur as numeric)         as base_fee_eur,
    cast(markup_eur_per_kwh as numeric)   as markup_eur_per_kwh
from {{ source('raw_meters', 'tariff_versions') }}
