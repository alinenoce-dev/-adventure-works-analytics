
with
    
    source_person as (
        select *
        from {{ source("adventure_works", "person_person") }}
    ),
         
    renamed as (
        select            
            cast(businessentityid as int) as pk_business_entity_id
            , cast(persontype as string) as person_type
            , cast(namestyle as boolean) as person_name_style_inverted
            , cast(title as string) as person_title
            , cast(firstname as string) as person_first_name
            , cast(middlename as string) as person_middle_name
            , cast(lastname as string) as person_last_name
            , trim(concat_ws(' ', firstname, middlename, lastname)) as person_full_name
            , cast(modifieddate as timestamp) as person_modified_date
            
        from source_person
    )

select *
from renamed