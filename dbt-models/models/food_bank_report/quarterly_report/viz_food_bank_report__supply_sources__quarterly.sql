with supply_source as (

    select * from {{ ref('viz_operations__stock_entries_sources') }}

),

visit_events as (
    
    select * from {{ ref('stg_families__visit_events') }}

),

quarters_calendar as (

    select
        date_trunc('quarter', visit_date)::date as quarter_at
    from visit_events
    group by 1
  
),

distinct_supply_source as (

    select
        source_name
    from supply_source
    group by 1

),

quarter_sources_cross_join as (

    select
        quarters_calendar.quarter_at,
        distinct_supply_source.source_name
    from quarters_calendar
    cross join distinct_supply_source

),

supply_sources_aggregate as (

    select
        date_trunc('quarter', date_at)::date as quarter_at,
        source_name,
        sum(batch_quantity) as batch_quantity,
        sum(monetary_value_eur) as monetary_value_eur
    from supply_source
    group by 1,2

),

final as (

    select
        quarter_sources_cross_join.quarter_at,
        quarter_sources_cross_join.source_name,
        coalesce(supply_sources_aggregate.batch_quantity, 0::numeric) as batch_quantity,
        coalesce(supply_sources_aggregate.monetary_value_eur, 0) as monetary_value_eur
    from quarter_sources_cross_join
    left join supply_sources_aggregate
        on quarter_sources_cross_join.quarter_at = supply_sources_aggregate.quarter_at

)

select * from final
