{{
    config({
        "materialized": "incremental",
        "dist": "auto",
        "unique_key": "product_operations_id",
        "sort": 'date_at'
    })
}}

with operations as (

    select * from {{ ref('stg_operations') }}

),

products as (

    select * from {{ ref('stg_products') }}

),

product_aggregate as (

    select
        operations.creation_date as date_at,
        operations.product_id,
        products.product_name,
        products.unit_of_measure,
        products.units_per_batch,
        products.product_weight_kg,
        operations.operation_type,
        operations.flow_type,
        sum(operations.quantity) as quantity_in_unit,
        sum(operations.quantity) * coalesce(products.product_weight_kg, 0) as quantity_in_kilo,
        sum(operations.quantity)/max(products.units_per_batch)::numeric as batch_quantity
    from operations
    inner join products
        on operations.product_id = products.product_id
    group by 1,2,3,4,5,6,7,8

)

select
    {{
        dbt_utils.surrogate_key([
            'date_at',
            'product_id',
            'operation_type',
            'flow_type'
        ])
    }} as product_operations_id,
    *
from product_aggregate
