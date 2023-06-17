with families__visit_events as (

    select * from {{ ref('stg_families__visit_events') }}

),

dim_families as (

    select * from {{ ref('dim_families') }}
   
),

family_members_by_quarter as (

    select
        date_trunc('quarter', families__visit_events.visit_date)::date as quarter_at,
        families__visit_events.family_id,
        dim_families.number_of_family_members
    from families__visit_events
    left join dim_families
        on families__visit_events.family_id = dim_families.family_id
    group by 1,2,3

),

grouped as (

    select
        quarter_at,
        number_of_family_members,
        count(family_id) as family_count
    from family_members_by_quarter
    group by 1,2

)

select
  *
from grouped
