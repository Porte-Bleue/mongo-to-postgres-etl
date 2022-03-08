with visit_events as (

    select * from {{ ref('stg_visit_events') }}

),

unnest_operations as (

    select
        visit_id,
        unnest(operation_ids::varchar[]) as operation_id
    from visit_events

)

select * from unnest_operations
