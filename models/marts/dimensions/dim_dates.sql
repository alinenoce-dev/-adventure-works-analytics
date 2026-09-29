

with
    date_spine as (
        select
            cast(date_add('2005-01-01', seq) as date) as date_value
        from (
            select row_number() over (order by (select null)) - 1 as seq
            from (select 1 from {{ ref('stg_sales_order_header') }} limit 4018)
        )
    )

    , enriched as (
        select
            cast(date_format(date_value, 'yyyyMMdd') as int) as sk_date

            , date_value
            , year(date_value) as year
            , quarter(date_value) as quarter
            , month(date_value) as month
            , day(date_value) as day_of_month
            , dayofweek(date_value) as day_of_week

            , case when month(date_value) <= 6 then 1 else 2 end as semester
            , concat(cast(year(date_value) as string), 'Q', cast(quarter(date_value) as string)) as year_quarter

            , case month(date_value)
                when 1 then 'January'
                when 2 then 'February'
                when 3 then 'March'
                when 4 then 'April'
                when 5 then 'May'
                when 6 then 'June'
                when 7 then 'July'
                when 8 then 'August'
                when 9 then 'September'
                when 10 then 'October'
                when 11 then 'November'
                when 12 then 'December'
            end as month_name
            
            , case month(date_value)
                when 1 then 'Jan'
                when 2 then 'Feb'
                when 3 then 'Mar'
                when 4 then 'Apr'
                when 5 then 'May'
                when 6 then 'Jun'
                when 7 then 'Jul'
                when 8 then 'Aug'
                when 9 then 'Sep'
                when 10 then 'Oct'
                when 11 then 'Nov'
                when 12 then 'Dec'
            end as month_name_short
            
            , case dayofweek(date_value)
                when 1 then 'Sunday'
                when 2 then 'Monday'
                when 3 then 'Tuesday'
                when 4 then 'Wednesday'
                when 5 then 'Thursday'
                when 6 then 'Friday'
                when 7 then 'Saturday'
            end as day_name
            
            , case when dayofweek(date_value) in (1, 7) then true else false end as is_weekend
        from date_spine
    )

select * from enriched