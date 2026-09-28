

/*
    Model: int_sales_reasons_bridge.sql
    Layer: Intermediate (Data Transformation Layer)
    Project: AdventureWorks
    
    Description:
    This bridge table resolves the Many-to-Many (N:M) relationship between sales orders (SalesOrderHeader)
    and their respective sales reasons (SalesReason). It maps each key for 'sales_order' to the corresponding
    Surrogate Key of the sales reason ('sk_sales_reason'), ensuring analytical integrity and preventing
    unwanted duplication (fan-out) in BI reporting tools like Power BI.
    
    Lineage:
    - stg_sales_order_header_sales_reason: OLTP associative mapping table
    - stg_sales_reason: Sales reason master catalog
*/

with
    stg_order_reason as (
        select
            pk_sales_order
            , fk_sales_reason
        from {{ ref('stg_sales_order_header_sales_reason') }}
    )

    , stg_reason as (
        select
            pk_sales_reason
            , sales_reason_name
        from {{ ref('stg_sales_reason') }}
    )

    , joined as (
        select

            {{ dbt_utils.generate_surrogate_key([
                'stg_order_reason.pk_sales_order',
                'stg_order_reason.fk_sales_reason'
            ]) }} as sk_sales_reason_bridge

            , stg_order_reason.pk_sales_order

            , {{ dbt_utils.generate_surrogate_key(['stg_order_reason.fk_sales_reason']) }} as sk_sales_reason

        from stg_order_reason
        inner join stg_reason on stg_order_reason.fk_sales_reason = stg_reason.pk_sales_reason
    )

select * from joined
