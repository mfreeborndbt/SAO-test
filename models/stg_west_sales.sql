with 

source as (

    select * from {{ source('raw', 'us_west_sales') }}

),

renamed as (

    select
        region,
        amount,
        order_id,
        product

    from source

)

select * from renamed
