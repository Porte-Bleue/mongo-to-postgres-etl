with product_operations as (

    select * from {{ ref('stg_operations__product_operations') }}

),

visits as (

    select * from {{ ref('stg_families__visit_events') }}

),

products_distributed_by_distribution as (

    select
        date_at,
        product_id,
        product_name,
        sum(batch_quantity) as batch_quantity
    from product_operations
    where operation_type = 'out'
    and flow_type = 'family-order'
    group by 1,2,3

),

visits_by_distribution as (

    select
        visit_date as date_at,
        count(distinct family_id) as visit_count
    from visits
    group by 1

),

visits_moving_average as (
    
    select
        date_at,
        avg(visit_count) over (order by date_at rows between 3 preceding and current row) as visits_moving_average_last_4_distributions
    from visits_by_distribution

),

joined as (

    select
        products_distributed_by_distribution.date_at,
        products_distributed_by_distribution.product_id,
        products_distributed_by_distribution.product_name,
        products_distributed_by_distribution.batch_quantity,
        visits_moving_average.visits_moving_average_last_4_distributions
    from products_distributed_by_distribution
    inner join visits_moving_average
        on products_distributed_by_distribution.date_at = visits_moving_average.date_at

),

products_grouped as (

    select
        date_at,
        product_id,
        product_name,
        visits_moving_average_last_4_distributions,
        avg(sum(batch_quantity)) over (partition by product_id order by date_at rows between 3 preceding and current row) as quantity_distributed_moving_average_last_4_distributions
    from joined
    group by 1,2,3,4

),

final as (

    select
        date_at,
        product_id,
        product_name,
        quantity_distributed_moving_average_last_4_distributions,
        visits_moving_average_last_4_distributions,
        quantity_distributed_moving_average_last_4_distributions/visits_moving_average_last_4_distributions::numeric as average_quantity_per_family
    from products_grouped

)

select * from final
