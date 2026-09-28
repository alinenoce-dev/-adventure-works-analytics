
with
    
    source_creditcard as (
        select * 
        from {{ source("adventure_works", "sales_creditcard") }}
    ),
         
    renamed as (
        select            
            cast(creditcardid as int) as pk_credit_card
            , cast(cardtype as string) as credit_card_type
            , cast(cardnumber as string) as credit_card_number
            , cast(expmonth as int) as credit_card_expiration_month
            , cast(expyear as int) as credit_card_expiration_year
            , cast(modifieddate as timestamp) as credit_card_modified_date
            
        from source_creditcard
    )

select *
from renamed
