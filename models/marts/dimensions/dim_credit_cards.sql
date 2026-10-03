
with
    stg_credit_card as (
        select *
        from {{ ref('stg_sales_credit_card') }}
    )

    , transformed as (
        select
            {{ dbt_utils.generate_surrogate_key(['pk_credit_card']) }} as sk_credit_card
            , pk_credit_card
            , credit_card_type
            , credit_card_expiration_month
            , credit_card_expiration_year
        from stg_credit_card
    )

    , fallback as (
        select
            'not_informed' as sk_credit_card              
            , -1 as pk_credit_card                        
            , 'No Credit Card' as credit_card_type              
            , 0 as credit_card_expiration_month
            , 0 as credit_card_expiration_year
    )

select * from transformed
union all
select * from fallback