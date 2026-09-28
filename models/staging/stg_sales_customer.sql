
with
    
    source_customer as (
        select * 
        from {{ source("adventure_works", "sales_customer") }}
    ),
         
    renamed as (
        select            
            cast(customerid as int) as pk_customer
            , cast(personid as int) as fk_customer_person
            , cast(storeid as int) as fk_store
            , cast(territoryid as int) as fk_territory
            , cast(modifieddate as timestamp) as customer_modified_date
            
        from source_customer
    )

select *
from renamed

