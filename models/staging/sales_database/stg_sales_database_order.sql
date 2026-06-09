with

source as (

    select * from {{ source('sales_database', 'order') }}

),

renamed as (

    select
        -- clés
        order_id,
        user_name               as customer_id,

        -- attributs
        order_status,

        -- dates : déjà en TIMESTAMP dans la source -> sélection directe (renommage)
        order_date              as ordered_at,
        order_approved_date     as approved_at,
        pickup_date             as picked_up_at,
        delivered_date          as delivered_at,
        estimated_time_delivery as estimated_delivery_at

    from source

)

select * from renamed