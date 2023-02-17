with family_members__visit_events as (

    select * from {{ ref('stg_families__visit_events') }}

),

metrics_yearly as (

    select
        date_trunc('year', visit_date)::date as year_at,
        count(distinct visit_date) as distribution_count,
        count(distinct family_id) as family_count,
        count(distinct visit_id) as total_visits,
        sum(number_of_operations) as total_product_distributed
    from family_members__visit_events
    group by 1

)

select * from metrics_yearly
