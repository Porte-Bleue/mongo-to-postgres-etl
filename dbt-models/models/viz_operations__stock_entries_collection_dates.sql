with product_operations as (

    select * from {{ ref('stg_operations__product_operations') }}

),

collection_dates as (

    select * from {{ ref('seed_collection_dates') }}

),

operations_collection_dates as (

    select
        product_operations.date_at,
        product_operations.product_name,
        product_operations.unit_of_measure,
        product_operations.units_per_batch,
        sum(product_operations.quantity) as unit_entries,
        sum(product_operations.quantity)/sum(units_per_batch) as batch_quantity
    from product_operations
    inner join collection_dates
        on product_operations.date_at = collection_dates.date_at
    where operation_type = 'in'
    and flow_type = 'inventory'
    group by 1,2,3,4

)

select * from operations_collection_dates
