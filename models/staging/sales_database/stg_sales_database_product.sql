with

source as (

    select * from {{ source('sales_database', 'product') }}

),

renamed as (

    select
        -- clé primaire
        product_id,

        -- attributs
        product_category,

        -- correction des fautes d'orthographe "lenght" -> "length"
        cast(product_name_lenght as int64)        as product_name_length,
        cast(product_description_lenght as int64) as product_description_length,

        cast(product_photos_qty as int64)         as product_photos_qty,

        -- dimensions / poids
        cast(product_weight_g as numeric)         as product_weight_g,
        cast(product_length_cm as numeric)        as product_length_cm,
        cast(product_height_cm as numeric)        as product_height_cm,
        cast(product_width_cm as numeric)         as product_width_cm

    from source

)

select * from renamed