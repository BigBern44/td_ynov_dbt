with

source as (

    select * from {{ source('sales_database', 'payment') }}

),

renamed as (

    select
        -- pas de clé primaire unique : un order_id a plusieurs paiements
        -- -> clé créée par concaténation order_id + payment_sequential
        {{ dbt_utils.generate_surrogate_key(['order_id', 'payment_sequential']) }} as payment_id,

        -- clé étrangère
        order_id,

        -- attributs
        cast(payment_sequential as int64)                                          as payment_sequential,
        payment_type,
        cast(payment_installments as int64)                                        as payment_installments,
        cast(payment_value as numeric)                                             as payment_value

    from source

)

select * from renamed