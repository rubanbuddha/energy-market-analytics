{{ config(materialized = 'table') }}

with hours as (
    select hour_of_day from unnest(generate_array(0, 23)) as hour_of_day
)

select
    hour_of_day as hour_key,
    hour_of_day,
    case
        when hour_of_day between 0 and 5 then 'Night'
        when hour_of_day between 6 and 9 then 'Morning peak'
        when hour_of_day between 10 and 16 then 'Midday'
        when hour_of_day between 17 and 21 then 'Evening peak'
        else 'Late evening'
    end as daypart,
    hour_of_day between 17 and 21 as is_evening_peak
from hours
