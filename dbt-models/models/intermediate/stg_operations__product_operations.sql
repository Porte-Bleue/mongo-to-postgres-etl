{{
    config({
        "materialized": "incremental",
        "dist": "auto",
        "unique_key": "product_operations_id",
        "sort": 'date_at'
    })
}}

with last_run as (

    select
        max(date_at) as max_date_at
    from {{ this }}
    
),

operations as (

    select
        product_id, 
        operation_type, 
        flow_type, 
        quantity, 
        creation_date
    from {{ ref('stg_operations') }}
    {% if is_incremental() %}
    where (creation_date >= (select max_date_at from last_run)
    or updated_at > created_at)
    {% endif %}
),

products as (

    select
        product_id, 
        product_name, 
        unit_of_measure, 
        units_per_batch, 
        product_weight_kg, 
        price_per_unit_eur
    from {{ ref('stg_products') }}

),

product_aggregate as (

    select
        operations.creation_date as date_at,
        operations.product_id,
        products.product_name,
        products.unit_of_measure,
        products.units_per_batch,
        products.product_weight_kg,
        products.price_per_unit_eur,
        operations.operation_type,
        operations.flow_type,
        sum(operations.quantity) as quantity_in_unit,
        sum(operations.quantity) * coalesce(products.product_weight_kg, 0) as quantity_in_kilo,
        sum(operations.quantity)/max(products.units_per_batch)::numeric as batch_quantity,
        sum(operations.quantity) * products.price_per_unit_eur as monetary_value_eur
    from operations
    inner join products
        on operations.product_id = products.product_id
    group by 1,2,3,4,5,6,7,8,9

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
