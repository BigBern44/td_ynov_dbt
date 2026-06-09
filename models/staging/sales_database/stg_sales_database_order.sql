with

source as (

    select * from {{ source('td2_ynov', 'order') }}

),

renamed as (

    select
        -- clés
        order_id,
        user_name                                                   as customer_id,

        -- attributs
        order_status,

        -- dates : format source "M/D/YYYY H:MM" -> timestamp
        safe.parse_timestamp('%m/%d/%Y %H:%M', order_date)          as ordered_at,
        safe.parse_timestamp('%m/%d/%Y %H:%M', order_approved_date) as approved_at,
        safe.parse_timestamp('%m/%d/%Y %H:%M', pickup_date)         as picked_up_at,
        safe.parse_timestamp('%m/%d/%Y %H:%M', delivered_date)      as delivered_at,
        safe.parse_timestamp('%m/%d/%Y %H:%M', estimated_time_delivery) as estimated_delivery_at

    from source

)

select * from renamed