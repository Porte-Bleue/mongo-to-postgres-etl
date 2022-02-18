with source as (

    select * from {{ source('public', 'visit_events') }}

),

renamed as (

    select
        visit_id,
        operation_ids,
        family_id,
        created_at as visit_at,
        created_at::date as visit_date
    from source

)

select
    *
from renamed
