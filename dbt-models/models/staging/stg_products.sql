with source as (

    select * from {{ source('public', 'products') }}

),

renamed as (

    select
        product_id,
        name as product_name,
        unit_of_measure,
        quantity_for_one_foodstuff as units_per_batch,
        created_at,
        created_at::date as creation_date,
        updated_at,
        updated_at::date as update_date,
        category as category_id,
        current_stock,
        nullif(weight_in_kg, 'NaN')::numeric as product_weight_kg
    from source

)

select * from renamed
