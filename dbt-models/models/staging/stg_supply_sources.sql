with source as (

    select * from {{ source('public', 'collects') }}

),

renamed as (

    select
        collect_id as source_id,
        collect_type as source_name,
        date_at::date,
        title,
        created_at,
        updated_at,
        created_by,
        updated_by
    from source

)

select * from renamed
