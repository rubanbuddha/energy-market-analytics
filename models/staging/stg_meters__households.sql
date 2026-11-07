{{ config(materialized = 'view') }}

select
    household_id,
    grid_zone,
    tariff_type,
    cast(signed_up_at as timestamp) as signed_up_at,
    postcode,
    building_type
from {{ source('raw_meters', 'households') }}
