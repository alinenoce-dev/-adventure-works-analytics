
with
    
    source_stateprovince as (
        select * 
        from {{ source("adventure_works", "person_stateprovince") }}
    ),
         
    renamed as (
        select            
            cast(stateprovinceid as int) as pk_state_province
            , cast(countryregioncode as string) as fk_country_region_code
            , cast(territoryid as int) as fk_territory
            , cast(stateprovincecode as string) as state_province_code
            , cast(isonlystateprovinceflag as boolean) as is_only_state_province
            , cast(name as string) as state_province_name
            , cast(modifieddate as timestamp) as state_province_modified_date
            
        from source_stateprovince
    )

select *
from renamed
