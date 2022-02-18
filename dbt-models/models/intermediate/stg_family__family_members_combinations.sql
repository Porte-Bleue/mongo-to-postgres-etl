with families as (

    select * from {{ ref('stg_families') }}

),

unnest_family_members as (

    select
        family_id,
        family_name,
        unnest(family_members_ids::varchar[]) as family_member_id
    from families

)

select
    *
from unnest_family_members
