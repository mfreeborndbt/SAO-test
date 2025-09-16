with src as (
    select *
    from {{ ref('stg_west_sales') }}
    where upper(region) = 'WEST'
),

agg as (
    select
        product,
        count(*) as order_count,
        sum(amount) as total_amount
    from src
    group by product
)

select * from agg
