with visit_events as (

    select * from {{ ref('stg_visit_events') }}

),

families as (

    select * from {{ ref('stg_families') }}

),

first_visit_date as (

    select
        family_id,
        min(visit_date) as first_visit_date
    from visit_events
    group by 1

),

visit_events_families__joined as (

    select
        visit_events.visit_id,
        visit_events.visit_date,
        visit_events.family_id,
        families.family_name,
        families.city,
        families.housing_details,
        visit_events.visit_date = families.last_visit_date as is_latest_visit,
        visit_events.visit_date = first_visit_date.first_visit_date as is_first_visit,
        case when visit_events.visit_date = first_visit_date.first_visit_date then 'new' else 'returning' end as family_type,
        array_length(visit_events.operation_ids, 1) as number_of_operations
    from visit_events
    left join families
        on visit_events.family_id = families.family_id
    left join first_visit_date
        on visit_events.family_id = first_visit_date.family_id

)

select * from visit_events_families__joined
