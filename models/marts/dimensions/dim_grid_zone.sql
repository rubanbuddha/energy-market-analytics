{{ config(materialized = 'table') }}

select * from {{ ref('grid_zones') }}
