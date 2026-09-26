
with
    
    source_products as (
        select * 
        from {{ source("adventure_works", "production_product") }}
    ),
         
    renamed as (
        select            
            cast(productid as int) as pk_product
            , cast(productsubcategoryid as int) as fk_product_subcategory
            , cast(productmodelid as int) as fk_product_model
            , cast(name as string) as product_name
            , cast(productnumber as string) as product_number
            , cast(color as string) as product_color
            , cast(size as string) as product_size
            , cast(sizeunitmeasurecode as string) as size_unit_measure_code
            , cast(weightunitmeasurecode as string) as weight_unit_measure_code
            , cast(weight as numeric(18,4)) as product_weight
            , cast(safetystocklevel as int) as product_safety_stock_level
            , cast(reorderpoint as int) as product_reorder_point
            , cast(standardcost as numeric(18,4)) as product_standard_cost
            , cast(listprice as numeric(18,4)) as product_list_price
            , cast(daystomanufacture as int) as product_days_to_manufacture
            , cast(productline as string) as product_line
            , cast(class as string) as product_class
            , cast(style as string) as product_style
            , cast(sellstartdate as timestamp) as product_sell_start_date
            , cast(sellenddate as timestamp) as product_sell_end_date
            , cast(discontinueddate as timestamp) as product_discontinued_date
            , cast(modifieddate as timestamp) as product_modified_date   
            , cast(makeflag as boolean) as product_is_manufactured_in_house
            , cast(FinishedGoodsFlag as boolean) as product_is_finished_good
            
            
        from source_products
    )

select *
from renamed
