
with
    order_header as (
        select
            pk_sales_order
            , fk_customer
            , fk_salesperson
            , fk_territory
            , fk_bill_to_address_id
            , fk_ship_to_address_id
            , fk_ship_method_id
            , fk_credit_card_id
            , fk_currency_rate_id
            , purchase_order_number
            , purchase_order_number
            , sales_order_status
            , sales_online_order
            , order_date
            , order_due_date
            , order_ship_date
            , order_subtotal
            , order_tax_amount
            , order_freight_amount
            , order_total_due
            , order_modified_date
        from {{ ref('stg_sales_order_header') }}
    )

    , order_detail as (
        select
            pk_sales_order_detail
            , fk_sales_order
            , fk_product
            , fk_special_offer_id
            , sales_order_quantity
            , sales_unit_price
            , sales_unit_price_discount
        from {{ ref('stg_sales_order_detail') }}
    )

    , joined as (
        select
            {{ dbt_utils.generate_surrogate_key([
                'order_detail.fk_sales_order', 
                'order_detail.pk_sales_order_detail'
            ]) }} as sk_sales

            , order_detail.fk_sales_order as pk_sales_order
            , order_detail.pk_sales_order_detail
            , order_header.purchase_order_number
            
            , coalesce(
                {{ dbt_utils.generate_surrogate_key(['order_detail.fk_product']) }},
                'not_informed'
            ) as sk_product

            , coalesce(
                {{ dbt_utils.generate_surrogate_key(['order_header.fk_customer']) }},
                'not_informed'
            ) as sk_customer

            , coalesce(
                {{ dbt_utils.generate_surrogate_key(['order_header.fk_ship_to_address_id']) }},
                'not_informed'
            ) as sk_location

            , coalesce(
                {{ dbt_utils.generate_surrogate_key(['order_header.fk_bill_to_address_id']) }},
                'not_informed'
            ) as sk_bill_to_address

            , case 
                when order_header.fk_credit_card_id is null then 'not_informed'
                else {{ dbt_utils.generate_surrogate_key(['order_header.fk_credit_card_id']) }}
            end as sk_credit_card

            , coalesce(cast(date_format(order_header.order_date, 'yyyyMMdd') as int), 19000101) as sk_order_date
            , coalesce(cast(date_format(order_header.order_due_date, 'yyyyMMdd') as int), 19000101) as sk_due_date
            , coalesce(cast(date_format(order_header.order_ship_date, 'yyyyMMdd') as int), 19000101) as sk_ship_date

            , order_header.sales_order_status
            , order_header.sales_online_order
            , order_header.fk_salesperson
            , order_header.fk_territory
            , order_detail.fk_special_offer_id

            , order_detail.sales_order_quantity
            , order_detail.sales_unit_price
            , order_detail.sales_unit_price_discount

            , (order_detail.sales_order_quantity * order_detail.sales_unit_price) as gross_revenue
            
            , (order_detail.sales_order_quantity * order_detail.sales_unit_price * order_detail.sales_unit_price_discount) as discount_amount
            
            , (order_detail.sales_order_quantity * order_detail.sales_unit_price * (1.0 - order_detail.sales_unit_price_discount)) as net_revenue

        from order_detail
        inner join order_header
            on order_detail.fk_sales_order = order_header.pk_sales_order
    )

select * from joined