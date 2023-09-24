with stg_supply_source as (

    select
        date_at,
        source_name
    from {{ ref('stg_supply_sources') }}
    group by 1,2

),

seed_sources as (

    select
        *,
        'Collectes Supermarché' as source_name
    from {{ ref('seed_collection_dates') }}
    union
    select  
        *,
        'Pleins Courses' as source_name
    from {{ ref('seed_grocery_shopping_dates') }}
    union
    select
        *,
        'Enlèvements BAPIF' as source_name
    from {{ ref('seed_bapif_collection_dates') }}

),

union_seed_supply_table as (

    select
        *
    from seed_sources
    union all
    select
        *
    from stg_supply_source

)

select * from union_seed_supply_table
