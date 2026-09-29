with
    
    source_salesorderdetail as (
        select * 
        from {{ source("adventure_works", "sales_salesorderdetail") }}
    ),
         
    renamed as (
        select            
            cast(salesorderdetailid as int) as pk_sales_order_detail
            , cast(salesorderid as int) as fk_sales_order
            , cast(productid as int) as fk_product
            , cast(specialofferid as int) as fk_special_offer_id
            , cast(carriertrackingnumber as string) as carrier_tracking_number
            , cast(orderqty as int) as sales_order_quantity
            , cast(unitprice as numeric(18,4)) as sales_unit_price
            , cast(unitpricediscount as numeric(18,4)) as sales_unit_price_discount
            , cast(modifieddate as timestamp) sales_order_detail_modified_date
            
        from source_salesorderdetail
    )

select *
from renamed
