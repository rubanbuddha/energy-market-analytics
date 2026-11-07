{{ config(
    materialized = 'incremental',
    unique_key = 'consumption_sk',
    partition_by = {'field': 'interval_date', 'data_type': 'date'},
    cluster_by = ['household_id', 'grid_zone']
) }}

with readings as (
    select
        reading_ts_utc                  as interval_start_utc,
        household_id,
        consumption_kwh
    from {{ ref('stg_meters__readings') }}

    {% if is_incremental() %}
      where reading_ts_utc > (select max(interval_start_utc) from {{ this }})
    {% endif %}
),

households as (
    select household_id, grid_zone, tariff_type from {{ ref('dim_household') }}
),

prices as (
    select interval_start_utc, grid_zone, price_eur_per_kwh
    from {{ ref('int_prices_15min') }}
),

tariff as (
    select tariff_key, tariff_id, base_fee_eur, markup_eur_per_kwh, effective_from_utc, effective_to_utc
    from {{ ref('dim_tariff') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['r.household_id', 'r.interval_start_utc']) }} as consumption_sk,
    r.interval_start_utc,
    date(r.interval_start_utc)              as interval_date,
    extract(hour from r.interval_start_utc) as hour_of_day,
    r.household_id,
    h.grid_zone,
    h.tariff_type,
    r.consumption_kwh,
    p.price_eur_per_kwh,
    r.consumption_kwh * p.price_eur_per_kwh                                   as spot_cost_eur,
    r.consumption_kwh * (p.price_eur_per_kwh + coalesce(t.markup_eur_per_kwh, 0.08)) as dynamic_tariff_cost_eur,
    t.tariff_key
from readings r
left join households h using (household_id)
left join prices p
    on r.interval_start_utc = p.interval_start_utc
   and h.grid_zone = p.grid_zone
left join tariff t
    on r.interval_start_utc between t.effective_from_utc and t.effective_to_utc
   and h.tariff_type = 'dynamic'
