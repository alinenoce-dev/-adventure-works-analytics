

/*
    Model: int_location.sql
    Layer: Intermediate (Transformation Layer)
    Project: AdventureWorks
    
    Description:
    This intermediate model consolidates geographic data by joining addresses,
    states/provinces, and country/regions. It pre-calculates the surrogate key (sk_location)
    via MD5 hash for downstream use in dim_location.
    
    Lineage:
    - stg_person_address: Base address records (city, postal code, state province ID)
    - stg_person_state_province: State and province metadata (names, country codes)
    - stg_person_country_region: Country and region names
*/

with
    stg_address as (
        select *
        from {{ ref('stg_person_address') }}
    )

    , stg_state_province as (
        select *
        from {{ ref('stg_person_state_province') }}
    )

    , stg_country_region as (
        select *
        from {{ ref('stg_person_country_region') }}
    )

    , joined as (
        select
            {{ dbt_utils.generate_surrogate_key(['address.pk_address']) }} as sk_location
            , address.pk_address
            , address.fk_address_state_province
            , state.fk_country_region_code
            , address.address_line1
            , address.address_line2
            , address.address_city
            , state.pk_state_province
            , state.state_province_name
            , country.country_region_name as country_name
            , address.address_postal_code
            , state.fk_territory
            , address.adress_modified_date
        from stg_address address
        left join stg_state_province state 
            on address.fk_address_state_province = state.pk_state_province
        left join stg_country_region country 
            on state.fk_country_region_code = country.pk_country_region_code
    )

select * from joined