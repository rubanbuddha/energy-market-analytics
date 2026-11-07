-- SCD Type 2 view of tariff versions.

with versions as (
    select * from {{ ref('stg_meters__tariff_versions') }}
),

with_end_dates as (
    select
        tariff_id,
        tariff_name,
        tariff_type,
        base_fee_eur,
        markup_eur_per_kwh,
        effective_from_utc,
        coalesce(
            lead(effective_from_utc) over (partition by tariff_id order by effective_from_utc),
            timestamp('9999-12-31')
        ) as effective_to_utc
    from versions
)

select
    {{ dbt_utils.generate_surrogate_key(['tariff_id', 'effective_from_utc']) }} as tariff_version_sk,
    tariff_id,
    tariff_name,
    tariff_type,
    base_fee_eur,
    markup_eur_per_kwh,
    effective_from_utc,
    effective_to_utc,
    current_timestamp() between effective_from_utc and effective_to_utc as is_current
from with_end_dates
