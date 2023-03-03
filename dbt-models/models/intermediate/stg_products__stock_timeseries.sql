{{
    config({
        "materialized": "incremental",
        "dist": "auto",
        "unique_key": "product_stock_id",
        "sort": 'date_at'
    })
}}

with products as (

    select * from {{ ref('stg_products') }}

),

daily_stock as (

    select
        current_date as date_at,
        product_id,
        product_name,
        current_stock as stock_at_date
    from products

)

select
    {{
        dbt_utils.surrogate_key([
            'date_at',
            'product_id'
        ])
    }} as product_stock_id,
    *
from daily_stock
