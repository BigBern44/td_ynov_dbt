with

source as (

    select * from {{ source('sales_database', 'user') }}

),

renamed as (

    select
        -- "user_name" est en réalité l'identifiant client -> on le renomme
        user_name                       as customer_id,

        -- attributs ; le code postal reste en string
        cast(customer_zip_code as string) as customer_zip_code,
        customer_city,
        customer_state

        -- la colonne "row_num" est un artefact technique : on ne la garde pas

    from source

),

deduplicated as (

    -- suppression des éventuels doublons sur la clé client
    select *
    from renamed
    qualify row_number() over (partition by customer_id order by customer_id) = 1

)

select * from deduplicated