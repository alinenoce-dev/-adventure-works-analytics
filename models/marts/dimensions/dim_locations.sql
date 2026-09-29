

with
    int_location as (
        select *
        from {{ ref('int_location') }}
    )

    , final as (
        select
            sk_location
            , pk_address
            , pk_state_province
            , fk_address_state_province
            , fk_country_region_code
            , address_city
            , address_postal_code
            , state_province_name
            , country_name
            , fk_territory
        from int_location
    )

select * from final
