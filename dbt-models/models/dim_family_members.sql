with families__family_members_combinations as (

    select * from {{ ref('stg_families__family_members_combinations') }}

),

family_members as (

    select * from {{ ref('stg_family_members') }}

),

family_members_families__joined as (

    select
        family_members.family_member_id,
        family_members.first_name,
        families__family_members_combinations.family_id,
        families__family_members_combinations.family_name,
        family_members.gender,
        family_members.adult_or_child,
        family_members.birth_date,
        family_members.creation_date,
        family_members.update_date
    from family_members
    left join families__family_members_combinations
        on family_members.family_member_id = families__family_members_combinations.family_member_id

)

select * from family_members_families__joined
