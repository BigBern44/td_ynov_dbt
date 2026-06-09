with

source as (

    select * from {{ source('td2_ynov', 'order_item') }}

),

renamed as (

    select
        -- pas de clé primaire dans la source : on en crée une par concaténation
        {{ dbt_utils.generate_surrogate_key(['order_id', 'product_id', 'seller_id']) }} as order_item_id,

        -- clés étrangères
        order_id,
        product_id,
        seller_id,

        -- attributs
        cast(quantity as int64)                                                          as quantity,
        cast(price as numeric)                                                           as item_price,
        cast(shipping_cost as numeric)                                                   as shipping_cost,

        -- date : format source "YYYY-MM-DD HH:MM:SS.ffffff UTC" -> timestamp
        safe.parse_timestamp('%Y-%m-%d %H:%M:%E*S %Z', pickup_limit_date)                as pickup_limit_at

    from source

)

select * from renamed