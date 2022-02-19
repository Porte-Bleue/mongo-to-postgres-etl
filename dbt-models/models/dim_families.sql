with families as (

    select * from {{ ref('stg_families') }}

),

family_visits_events as (

    select * from {{ ref('stg_families__visit_events') }}

),

families_lifetime_metrics as (

    select
        family_id,
        min(visit_date) as first_visit_date,
        sum(number_of_operations) as lifetime_operation_count,
        count(visit_id) as lifetime_visit_count
    from family_visits_events
    group by 1

),

final as (

    select
        families.family_id,
        families.family_name,
        array_length(families.family_members_ids, 1) as number_of_family_members,
        families.city,
        families.housing_details,
        families.creation_date,
        families.update_date,
        families_lifetime_metrics.first_visit_date,
        families.last_visit_date,
        coalesce(families_lifetime_metrics.lifetime_visit_count, 0) as lifetime_visit_count,
        coalesce(families_lifetime_metrics.lifetime_operation_count, 0) as lifetime_operation_count
    from families
    left join families_lifetime_metrics
        on families.family_id = families_lifetime_metrics.family_id

)

select * from final
