with distribution_metrics as (

    select * from {{ ref('stg_products__distribution_metrics') }}

),

stocks as (

    select * from {{ ref('stg_products__stock_timeseries') }}

),

joined as (

    select
        distribution_metrics.date_at,
        distribution_metrics.product_id,
        distribution_metrics.product_name,
        distribution_metrics.quantity_distributed_moving_average_last_4_distributions,
        distribution_metrics.visits_moving_average_last_4_distributions,
        distribution_metrics.average_quantity_per_family,
        stocks.stock_at_date,
        -- To improve the model, `visits_moving_average_last_4_distributions` should be replaced by a prediction of the upcoming number of visits
        round(case when stock_at_date > 0 then stock_at_date/(average_quantity_per_family*visits_moving_average_last_4_distributions) else 0 end, 2) as count_distributions_available,
        max(distribution_metrics.date_at) over () as date_latest_distribution
    from distribution_metrics
    inner join stocks
        on distribution_metrics.date_at = stocks.date_at
        and distribution_metrics.product_id = stocks.product_id

)

select * from joined
