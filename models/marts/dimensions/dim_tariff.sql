{{ config(materialized = 'table') }}

-- Slowly Changing Dimension Type 2 on tariff.

select
    tariff_version_sk as tariff_key,
    tariff_id,
    tariff_name,
    tariff_type,
    base_fee_eur,
    markup_eur_per_kwh,
    effective_from_utc,
    effective_to_utc,
    is_current
from {{ ref('int_tariff_scd2') }}
