
with

    source_store as ( 
        select * 
        from {{ source("adventure_works", "sales_store") }}
    ),

    renamed as (
        select
            cast(businessentityid as int) as pk_store_business_entity_id,
            cast(salespersonid as int) as fk_store_sales_person_id,
            cast(name as string) as store_name,
            cast(modifieddate as timestamp) as store_modified_date

        from source_store
    )

select *
from renamed
