
with
    stg_sales_reason as (
        select *
        from {{ ref('stg_sales_reason') }}
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['pk_sales_reason']) }} as sk_sales_reason
            , pk_sales_reason
            , sales_reason_name -- e.g., 'Price', 'On Promotion', 'Quality', 'Review'
            , sales_reason_type -- e.g., 'Marketing', 'Other', 'Promotion'
        from stg_sales_reason
    )

select * from final
