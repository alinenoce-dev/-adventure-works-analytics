

/*
    Model: int_customer.sql
    Layer: Intermediate (Data Transformation Layer)
    Project: Adventure Works
    
    Description:
    This intermediate model consolidates the customer registry, unifying information
    from individual consumers (B2C) and retail stores (B2B). It resolves the complex
    normalization of the AdventureWorks OLTP database, delivering unified columns 
    such as 'customer_name' and 'customer_type'.
    
    Lineage:
    - stg_sales_customer: Association keys (pk_person, pk_store)
    - stg_person_person: Registration details for individual physical consumers (B2C)
    - stg_sales_store: Commercial/store names for retail stores (B2B)
*/

with
    customers as (
        select
            pk_customer
            , fk_customer_person
            , fk_store
            , fk_territory
        from {{ ref('stg_sales_customer') }}
    )

    , persons as (
        select
            pk_business_entity_id
            , person_first_name
            , person_middle_name
            , person_last_name
        from {{ ref('stg_person_person') }}
    )

    , stores as (
        select
            pk_store_business_entity_id
            , store_name
        from {{ ref('stg_sales_store') }}
    )

    , joined as (
        select

            customers.pk_customer
            , customers.fk_customer_person
            , customers.fk_store
            , customers.fk_territory
            , case
                when customers.fk_store is not null and customers.fk_customer_person is null then 'B2B'
                when customers.fk_customer_person is not null and customers.fk_store is null then 'B2C'
                when customers.fk_customer_person is not null and customers.fk_store is not null then 'B2B' -- Case of individual store owner
                else 'Not Informed'
            end as customer_type

            , case
                when customers.fk_customer_person is not null then
                    trim(
                        coalesce(persons.person_first_name, '') || ' ' ||
                        case 
                            when persons.person_middle_name is not null and persons.person_middle_name != '' 
                            then persons.person_middle_name || ' ' 
                            else '' 
                        end ||
                        coalesce(persons.person_last_name, '')
                    )
                when customers.fk_store is not null then stores.store_name
                else 'Not Informed'
            end as customer_name

        from customers
        left join persons on customers.fk_customer_person = persons.pk_business_entity_id
        left join stores on customers.fk_store = stores.pk_store_business_entity_id
    )

select * from joined

