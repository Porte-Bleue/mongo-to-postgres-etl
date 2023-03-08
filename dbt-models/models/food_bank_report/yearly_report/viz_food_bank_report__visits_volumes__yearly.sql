with volumes as (

    select * from {{ ref('viz_food_bank_report__volumes__yearly') }}

),

visits as (

    select * from {{ ref('viz_food_bank_report__families__yearly') }}

),

joined as (

    select
        visits.year_at,
        visits.distribution_count,
        visits.family_count,
        visits.total_visits,
        visits.total_product_distributed,
        volumes.volumes_distributed_kilos,
        volumes.total_monetary_value_eur
    from visits
    left join volumes
        on visits.year_at = volumes.year_at

)

select * from joined
