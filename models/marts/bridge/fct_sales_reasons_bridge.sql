
with
    int_bridge as (
        select *
        from {{ ref('int_sales_reasons_bridge') }}
    )

select * from int_bridge