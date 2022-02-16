with products as (

    select * from {{ source('public', 'products') }}

)

select
    *
from products