with source as (

    select * from {{ source('public', 'collects') }}

),

renamed as (

    select
        collect_id as supply_id,
        case
            when collect_type = 'collect' then 'Collectes Supermarché'
            when collect_type = 'shopping' then 'Pleins Courses'
            when collect_type like '%BAPIF%' then 'Enlèvements BAPIF'
            else collect_type
        end as source_name,
        date_at::date,
        title,
        created_at,
        updated_at,
        created_by,
        updated_by
    from source

)

select * from renamed
