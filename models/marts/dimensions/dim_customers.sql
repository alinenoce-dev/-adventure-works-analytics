

with
    int_customer as (
        select *
        from {{ ref('int_curtomer') }}
    )

    , final as (
        select
            {{ dbt_utils.generate_surrogate_key(['pk_customer']) }} as sk_customer
            , pk_customer
            , fk_customer_person
            , fk_store
            , fk_territory
            , customer_type -- 'B2B' or 'B2C'
            , customer_name
        from int_customer
    )

select * from final