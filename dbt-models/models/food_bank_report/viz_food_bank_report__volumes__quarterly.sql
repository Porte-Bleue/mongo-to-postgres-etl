with product_operations as (

    select * from {{ ref('stg_operations__product_operations') }}

),

volumes_distributed_by_quarter as (

    select
        date_trunc('quarter', date_at)::date as quarter_at,
        sum(quantity_in_kilo) as volumes_distributed_kilos,
        sum(quantity_in_kilo)/1000 as volumes_distributed_tonnes
    from product_operations
    where operation_type = 'out'
    and flow_type = 'family-order'
    group by 1

)

select
  *
from volumes_distributed_by_quarter
