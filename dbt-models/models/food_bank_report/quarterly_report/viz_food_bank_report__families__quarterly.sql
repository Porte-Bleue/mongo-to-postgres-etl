with family_members__visit_events as (

    select * from {{ ref('stg_families__visit_events') }}

),

families_by_quarter as (

    select
        date_trunc('quarter', visit_date)::date as quarter_at,
        family_id,
        count(visit_id) as visit_count
    from family_members__visit_events
    group by 1,2

),

grouped as (

    select
        quarter_at,
        count(family_id) as family_count,
        sum(visit_count) as visit_count
    from families_by_quarter
    group by 1

)

select
  *
from grouped
