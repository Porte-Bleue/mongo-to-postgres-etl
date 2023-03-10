with product_operations as (

    select * from {{ ref('stg_operations__product_operations') }}

),

shopping_dates as (

    select * from {{ ref('seed_grocery_shopping_dates') }}

),

operations_shopping_dates as (

    select
        product_operations.date_at,
        product_operations.product_name,
        product_operations.unit_of_measure,
        product_operations.units_per_batch,
        max(product_operations.date_at) over () as date_latest_shopping,
        sum(product_operations.quantity_in_unit) as unit_entries,
        sum(product_operations.batch_quantity) as batch_quantity,
        sum(product_operations.monetary_value_eur) as monetary_value_eur
    from product_operations
    inner join shopping_dates
        on product_operations.date_at = shopping_dates.date_at
    where operation_type = 'in'
    and flow_type = 'inventory'
    group by 1,2,3,4

)

select * from operations_shopping_dates
