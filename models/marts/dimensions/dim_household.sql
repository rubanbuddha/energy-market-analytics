{{ config(materialized = 'table') }}

select
    household_id as household_key,
    household_id,
    grid_zone,
    tariff_type,
    postcode,
    building_type,
    signed_up_at,
    date_diff(current_date(), date(signed_up_at), day) as days_as_customer
from {{ ref('stg_meters__households') }}
