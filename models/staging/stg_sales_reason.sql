
with
    
    source_salesreason as (
        select * 
        from {{ source("adventure_works", "sales_salesreason") }}
    ),
         
    renamed as (
        select            
            cast(salesreasonid as int) as pk_sales_reason
            , cast(name as string) as sales_reason_name
            , cast(reasontype as string) as sales_reason_type
            , cast(modifieddate as timestamp) as salesreason_modified_date
            
        from source_salesreason
    )

select *
from renamed
