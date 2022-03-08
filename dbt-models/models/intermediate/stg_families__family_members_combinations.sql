with families as (

    select * from {{ ref('stg_families') }}

),

unnest_family_members as (

    select
        family_id,
        unnest(family_members_ids) as family_member_id
    from families

)

select * from unnest_family_members
