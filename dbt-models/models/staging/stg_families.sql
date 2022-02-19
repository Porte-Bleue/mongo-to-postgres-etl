with source as (

    select * from {{ source('public', 'families') }}

),

renamed as (

    select
        family_id,
        name as family_name,
        family_members_ids::varchar[] as family_members_ids,
        nullif(city, '') as city,
        nullif(housing_details, '') as housing_details,
        created_at,
        created_at::date as creation_date,
        updated_at,
        updated_at::date as update_date,
        last_visit_at,
        last_visit_at::date as last_visit_date
    from source

)

select * from renamed
