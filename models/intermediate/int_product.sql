

/*
    Model: int_product.sql 
    Layer: Intermediate (Transformation & Dimensional Consolidation)
    Project: AdventureWorks
    
    Description:
    This intermediate model consolidates the product master data, resolving the 
    normalization of the Production schema (Product -> Subcategory -> Category).
    It flattens these structured hierarchy metadata into a single denormalized view,
    ready to feed the final dim_products dimension.
    
    Lineage:
    - stg_production_product: Basic product data (name, number, color, price, etc.)
    - stg_production_product_subcategory: Product subcategory
    - stg_production_product_category: Product macro category
*/

with
    products as (
        select
            pk_product
            , fk_product_subcategory
            , product_name
            , product_number
            , product_color
            , product_size
            , product_standard_cost
            , product_list_price
            , product_line
            , product_class
            , product_style
            , product_sell_start_date
            , product_sell_end_date
            , product_discontinued_date
            , product_modified_date

        from {{ ref('stg_production_product') }}
    )

    , subcategories as (
        select
            pk_product_subcategory
            , fk_product_category
            , product_subcategory_name

        from {{ ref('stg_production_product_subcategory') }}
    )

    , categories as (
        select
            pk_product_category
            , product_category_name
        from {{ ref('stg_production_product_category') }}
    )

    , joined as (
        select
      
            {{ dbt_utils.generate_surrogate_key(['products.pk_product']) }} as sk_product
            , products.pk_product
            , products.fk_product_subcategory
            , subcategories.fk_product_category
            , products.product_number

            , products.product_name
            , products.product_color
            , products.product_size
            , products.product_standard_cost
            , products.product_list_price
            
            , coalesce(subcategories.product_subcategory_name, 'Not Informed') as subcategory_name
            , coalesce(categories.product_category_name, 'Not Informed') as category_name

            , coalesce(products.product_line, 'Not Informed') as product_line
            , coalesce(products.product_class, 'Not Informed') as product_class
            , coalesce(products.product_style, 'Not Informed') as product_style
            
            , products.product_sell_start_date
            , products.product_sell_end_date
            , products.product_discontinued_date
            , products.product_modified_date

        from products
        left join subcategories 
            on products.fk_product_subcategory = subcategories.pk_product_subcategory
        left join categories 
            on subcategories.fk_product_category = categories.pk_product_category
    )

select * from joined
