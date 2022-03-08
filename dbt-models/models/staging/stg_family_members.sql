with source as (

    select * from {{ source('public', 'family_members') }}

),

renamed as (

    select
        family_member_id,
        nullif(surname, '') as first_name,
        gender,
        adult_or_child,
        cast(to_date(birth_date, 'DD/MM/YYYY') as date) as birth_date,
        created_at,
        created_at::date as creation_date,
        updated_at,
        updated_at::date as update_date
    from source

)

select * from renamed
