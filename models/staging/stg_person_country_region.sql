
with
    
    source_countryregion as (
        select * 
        from {{ source("adventure_works", "person_countryregion") }}
    ),
         
    renamed as (
        select            
            cast(countryregioncode as string) as pk_country_region_code
            , cast(name as string) as country_region_name
            , cast(modifieddate as timestamp) as country_region_modified_date
            
        from source_countryregion
    )

select *
from renamed
