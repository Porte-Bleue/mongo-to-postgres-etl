with source as (

    select * from {{ source('public', 'operations') }}

),

renamed as (

    select
        operation_id,
        operation_type,
        quantity,
        product_id,
        from_flow as flow_type,
        created_at,
        created_at::date as creation_date,
        updated_at,
        updated_at::date as update_date
    from source

)

select * from renamed
