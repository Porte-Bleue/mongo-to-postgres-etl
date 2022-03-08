with families__family_members_combinations as (

    select * from {{ ref('stg_families__family_members_combinations') }}

),

family_members as (

    select * from {{ ref('stg_family_members') }}

),

families as (

    select * from {{ ref('stg_families') }}

),

dim_families as (

    select * from {{ ref('dim_families') }}

),

family_members_families__joined as (

    select
        family_members.family_member_id,
        family_members.first_name,
        families__family_members_combinations.family_id,
        families.family_name,
        families.city,
        family_members.gender,
        family_members.adult_or_child,
        family_members.birth_date,
        family_members.creation_date,
        family_members.update_date,
        dim_families.first_visit_date,
        families.last_visit_date,
        dim_families.lifetime_visit_count
    from family_members
    left join families__family_members_combinations
        on family_members.family_member_id = families__family_members_combinations.family_member_id
    left join families
        on families__family_members_combinations.family_id = families.family_id
    left join dim_families
        on families.family_id = dim_families.family_id

)

select * from family_members_families__joined
