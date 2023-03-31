with families_visit_events as (

    select * from {{ ref('stg_families__visit_events') }}

),

weekly_visits as (

    select
        date_trunc('quarter', visit_date)::date as quarter_at,
        date_trunc('week', visit_date)::date as week_at,
        count(visit_id) as total_visits
    from families_visit_events
    group by 1,2
),

max_weekly_visits_by_quarter as (

    select
        quarter_at,
        max(total_visits) as max_weekly_visits
    from weekly_visits
    group by 1

),

metrics_by_quarter as (

    select
        date_trunc('quarter', visit_date)::date as quarter_at,
        count(distinct visit_date) as distribution_count,
        count(distinct family_id) as family_count,
        count(distinct visit_id) as total_visits,
        sum(number_of_operations) as total_product_distributed
    from families_visit_events
    group by 1

),

joined as (

    select
        metrics_by_quarter.*,
        max_weekly_visits
    from metrics_by_quarter
    left join max_weekly_visits_by_quarter
        on metrics_by_quarter.quarter_at = max_weekly_visits_by_quarter.quarter_at

)

select * from joined
