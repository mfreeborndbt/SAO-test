with

us_west as (

    select
        region,
        amount
    from {{ ref('stg_east_sales') }}

),

us_east as (

    select
        region,
        amount
    from {{ ref('stg_west_sales') }}

),

combined as (

    select * from us_west
    union all
    select * from us_east

),

aggregated as (

    select
        region,
        sum(amount) as total_sales_amount
    from combined
    group by region

)

select * from aggregated
