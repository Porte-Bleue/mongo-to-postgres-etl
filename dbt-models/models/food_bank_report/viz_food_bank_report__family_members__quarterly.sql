with family_members__visit_events as (

    select * from {{ ref('stg_family_members__visit_events') }}

),

calculate_age as (

    select
        *,
        date_part('year', age(current_date, birth_date))::int as age
    from family_members__visit_events

),

family_members_by_quarter as (

    select
        date_trunc('quarter', visit_date)::date as quarter,
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
        quarter,
        gender,
        age_range,
        count(family_member_id) as unique_people_helped,
        sum(total_people_helped) as total_people_helped
    from family_members_by_quarter
    group by 1,2,3

)

select
  *
from grouped
