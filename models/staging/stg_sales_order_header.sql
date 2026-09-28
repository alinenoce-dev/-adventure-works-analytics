
with
    
    source_salesorderheader as (
        select * 
        from {{ source("adventure_works", "sales_salesorderheader") }}
    ),
         
    renamed as (
        select            
            cast(salesorderid as int) as pk_sales_order
            , cast(customerid as int) as fk_customer
            , cast(salespersonid as int) as fk_salesperson
            , cast(territoryid as int) as fk_territory
            , cast(billtoaddressid as int) as fk_bill_to_address_id
            , cast(shiptoaddressid as int) as fk_ship_to_address_id
            , cast(shipmethodid as int) as fk_ship_method_id
            , cast(creditcardid as int) as fk_credit_card_id
            , cast(currencyrateid as int) as fk_currency_rate_id
            , cast(revisionnumber as int) as revision_number
            , cast(purchaseordernumber as string) as purchase_order_number
            , cast(accountnumber as string) as account_number
            , cast(status as int) as sales_order_status
            , cast(onlineorderflag as boolean) as sales_online_order
            , cast(orderdate as timestamp) as order_date
            , cast(duedate as timestamp) as order_due_date
            , cast(shipdate as timestamp) as oreder_hip_date
            , cast(subtotal as numeric(18,4)) as order_subtotal
            , cast(taxamt as numeric(18,4)) as order_tax_amount
            , cast(freight as numeric(18,4)) as order_freight_amount
            , cast(totaldue as numeric(18,4)) as order_total_due
            , cast(modifieddate as timestamp) as order_modified_date
            
        from source_salesorderheader
    )

select *
from renamed
