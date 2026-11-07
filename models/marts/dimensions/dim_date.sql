{{ config(materialized = 'table') }}

with dates as (
    {{ dbt_utils.date_spine(
        datepart = "day",
        start_date = "cast('" ~ var('start_date') ~ "' as date)",
        end_date = "date_add(current_date(), interval 365 day)"
    ) }}
)

select
    date_day                                   as date_key,
    date_day,
    extract(year from date_day)                as year,
    extract(quarter from date_day)             as quarter,
    extract(month from date_day)               as month,
    format_date('%B', date_day)                as month_name,
    extract(week from date_day)                as iso_week,
    extract(dayofweek from date_day)           as day_of_week,
    format_date('%A', date_day)                as day_name,
    extract(dayofweek from date_day) in (1, 7) as is_weekend
from dates
