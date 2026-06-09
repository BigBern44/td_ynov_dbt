with

source as (

    select * from {{ source('td2_ynov', 'seller') }}

),

renamed as (

    select
        -- clé primaire
        seller_id,

        -- attributs ; le code postal reste en string (peut contenir des zéros à gauche)
        cast(seller_zip_code as string) as seller_zip_code,
        seller_city,
        seller_state

    from source

)

select * from renamed