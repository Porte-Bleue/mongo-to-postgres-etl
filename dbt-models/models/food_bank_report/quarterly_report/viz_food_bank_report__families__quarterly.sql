with family_members__visit_events as (

    select * from {{ ref('stg_families__visit_events') }}

),

metrics_by_quarter as (

    select
        date_trunc('quarter', visit_date)::date as quarter_at,
        count(distinct visit_date) as distribution_count,
        count(distinct family_id) as family_count,
        count(distinct visit_id) as total_visits
    from family_members__visit_events
    group by 1

)

select * from metrics_by_quarter
