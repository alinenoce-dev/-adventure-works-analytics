
with
    
    source_address as (
        select * 
        from {{ source("adventure_works", "person_address") }}
    ),
         
    renamed as (
        select            
            cast(addressid as int) as pk_address
            , cast(stateprovinceid as int) as fk_address_state_province
            , cast(addressline1 as string) as address_line1
            , cast(addressline2 as string) as address_line2
            , cast(city as string) as address_city
            , cast(postalcode as string) as address_postal_code
            , cast(modifieddate as timestamp) as adress_modified_date
            
        from source_address
    )

select *
from renamed
