
with
    
    source_productsubcategory as (
        select * 
        from {{ source("adventure_works", "production_productsubcategory") }}
    ),
         
    renamed as (
        select            
            cast(productsubcategoryid as int) as pk_product_subcategory
            , cast(productcategoryid as int) as fk_product_category
            , cast(name as string) as product_subcategory_name
            , cast(modifieddate as timestamp) as product_subcategory_modified_date
            
          from source_productsubcategory
    )

select *
from renamed
