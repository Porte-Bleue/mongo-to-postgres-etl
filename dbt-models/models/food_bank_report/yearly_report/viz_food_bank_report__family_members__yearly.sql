with family_members__visit_events as (

    select * from {{ ref('stg_family_members__visit_events') }}

),

last_day_year as (

    select
        *,
        (date_trunc('year', visit_date)::date + interval '1 year')::date-1 as visit_last_day_of_year
    from family_members__visit_events

),

calculate_age as (

    select
        *,
        date_part('year', age(visit_last_day_of_year, birth_date))::int as age
    from last_day_year

),

family_members_yearly as (

    select
        date_trunc('year', visit_date)::date as year_at,
        family_id,
        family_member_id,
        gender,
        case
            when age >= 0 and age <= 3 then '0 to 3'
            when age >= 4 and age <= 14 then '4 to 14'
            when age >= 15 and age <= 25 then '15 to 25'
            when age >= 26 and age <= 64 then '16 to 64'
            when age >= 65 then '65+'
        end as age_range,
        count(family_member_id) as total_people_helped
    from calculate_age
    group by 1,2,3,4,5

),

grouped as (

    select
        year_at,
        gender,
        age_range,
        count(family_member_id) as unique_people_helped,
        sum(total_people_helped) as total_people_helped
    from family_members_yearly
    group by 1,2,3

)

select
  *
from grouped
