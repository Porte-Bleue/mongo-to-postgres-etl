with visit_events as (

    select * from {{ ref('stg_visit_events') }}

),

dim_family_members as (

    select * from {{ ref('dim_family_members') }}

),

visit_events_family_members__joined as (

    select
        visit_events.visit_id,
        visit_events.visit_date,
        visit_events.family_id,
        dim_family_members.family_name,
        dim_family_members.city,
        dim_family_members.family_member_id,
        dim_family_members.first_name,
        dim_family_members.gender,
        dim_family_members.adult_or_child,
        dim_family_members.birth_date,
        visit_events.visit_date = dim_family_members.first_visit_date as is_first_visit,
        visit_events.visit_date = dim_family_members.last_visit_date as is_latest_visit
    from visit_events
    left join dim_family_members
        on visit_events.family_id = dim_family_members.family_id

)

select * from visit_events_family_members__joined
