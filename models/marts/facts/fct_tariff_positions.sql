{{ config(materialized = 'table') }}

-- Daily per-household savings from dynamic tariff vs flat reference tariff.

with daily as (
    select
        interval_date,
        household_id,
        grid_zone,
        tariff_type,
        sum(consumption_kwh)         as total_kwh,
        sum(spot_cost_eur)           as total_spot_cost_eur,
        sum(dynamic_tariff_cost_eur) as total_dynamic_cost_eur
    from {{ ref('fct_consumption_intervals') }}
    group by 1, 2, 3, 4
),

flat_reference as (
    select
        date(interval_start_utc) as interval_date,
        grid_zone,
        avg(price_eur_per_kwh)   as avg_price_eur_per_kwh
    from {{ ref('int_prices_15min') }}
    group by 1, 2
)

select
    d.interval_date,
    d.household_id,
    d.grid_zone,
    d.tariff_type,
    d.total_kwh,
    d.total_spot_cost_eur,
    d.total_dynamic_cost_eur,
    d.total_kwh * (f.avg_price_eur_per_kwh + 0.08) as flat_reference_cost_eur,
    d.total_kwh * (f.avg_price_eur_per_kwh + 0.08) - d.total_dynamic_cost_eur as savings_eur
from daily d
left join flat_reference f using (interval_date, grid_zone)
