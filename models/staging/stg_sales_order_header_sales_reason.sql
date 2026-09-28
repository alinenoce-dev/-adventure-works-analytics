
with
    
    source_salesorderheadersalesreason as (
        select * 
        from {{ source("adventure_works", "sales_salesorderheadersalesreason") }}
    ),
         
    renamed as (
        select            
            cast(salesorderid as int) as pk_sales_order
            , cast(salesreasonid as int) as fk_sales_reason
            , cast(modifieddate as timestamp) as salesorderheadersalesreason_modified_date
            
        from source_salesorderheadersalesreason
    )

select *
from renamed