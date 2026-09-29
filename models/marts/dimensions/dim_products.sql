

with
    int_product as (
        select *
        from {{ ref('int_product') }}
    )

    , final as (
        select 
            sk_product
            , pk_product
            , product_name
            , product_number
        from int_product
    )

select * from int_product