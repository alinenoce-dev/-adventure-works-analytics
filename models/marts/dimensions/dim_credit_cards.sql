

with
    stg_credit_card as (
        select *
        from {{ ref('stg_sales_credit_card') }}
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['pk_credit_card']) }} as sk_credit_card
            , pk_credit_card
            , coalesce(nullif(trim(credit_card_type), ''), 'No credit card') as credit_card_type -- e.g., 'Vista', 'SuperiorCard', 'Distinguish', 'ColonialVoice'
            , credit_card_expiration_month
            , credit_card_expiration_year
        from stg_credit_card
    )

select * from final
