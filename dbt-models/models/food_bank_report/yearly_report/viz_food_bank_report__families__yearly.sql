with family_members__visit_events as (

    select * from {{ ref('stg_families__visit_events') }}

),

families_by_year as (

    select
        date_trunc('year', visit_date)::date as year_at,
        family_id,
        count(visit_id) as visit_count
    from family_members__visit_events
    group by 1,2

),

grouped as (

    select
        year_at,
        count(family_id) as family_count,
        sum(visit_count) as visit_count
    from families_by_year
    group by 1

)

select
  *
from grouped
