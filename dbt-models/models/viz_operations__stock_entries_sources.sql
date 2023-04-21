with product_operations as (

    select * from {{ ref('stg_operations__product_operations') }}

),

dates_per_sources as (

    select
        *,
        'Collectes Supermarché' as source
    from {{ ref('seed_collection_dates') }}
    union
    select  
        *,
        'Pleins Courses' as source
    from {{ ref('seed_grocery_shopping_dates') }}
    union
    select
        *,
        'Enlèvements BAPIF' as source
    from {{ ref('seed_bapif_collection_dates') }}

),

operations_dates_joined as (

    select
        product_operations.date_at,
        dates_per_sources.source, 
        product_operations.product_name,
        product_operations.unit_of_measure,
        product_operations.units_per_batch,
        max(product_operations.date_at) over (partition by source) as date_latest_collection,
        sum(product_operations.quantity_in_unit) as unit_entries,
        sum(product_operations.batch_quantity) as batch_quantity,
        sum(product_operations.monetary_value_eur) as monetary_value_eur
    from product_operations
    inner join dates_per_sources
        on product_operations.date_at = dates_per_sources.date_at
    where operation_type = 'in'
    and flow_type = 'inventory'
    group by 1,2,3,4,5

)

select * from operations_dates_joined
