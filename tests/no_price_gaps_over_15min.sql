-- Fails if any grid zone is missing an hourly price.

with observed as (
    select delivery_hour_utc, grid_zone from {{ ref('stg_epex__day_ahead_prices') }}
),

bounds as (
    select
        min(delivery_hour_utc) as min_hour,
        timestamp_diff(max(delivery_hour_utc), min(delivery_hour_utc), hour) as hour_range,
        grid_zone
    from observed
    group by grid_zone
),

expected as (
    select
        timestamp_add(min_hour, interval n hour) as expected_hour,
        grid_zone
    from bounds, unnest(generate_array(0, hour_range)) as n
)

select e.*
from expected e
left join observed o
    on e.expected_hour = o.delivery_hour_utc
   and e.grid_zone = o.grid_zone
where o.delivery_hour_utc is null
