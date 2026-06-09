with

source as (

    select * from {{ source('sales_database', 'feedback') }}

),

renamed as (

    select
        -- feedback_id n'est PAS unique (un même avis couvre plusieurs commandes)
        -- la vraie granularité est feedback_id + order_id -> clé composée
        {{ dbt_utils.generate_surrogate_key(['feedback_id', 'order_id']) }} as feedback_pk,

        feedback_id,
        order_id,

        -- attributs
        cast(feedback_score as int64)                  as feedback_score,

        -- "form_sent" est une date (heure toujours 00:00:00) ; "answer" est un vrai timestamp
        cast(feedback_form_sent_date as date)          as feedback_form_sent_date,
        cast(feedback_answer_date as timestamp)        as feedback_answered_at

    from source

),

deduplicated as (

    -- suppression des doublons éventuels sur la clé (feedback_id, order_id)
    select *
    from renamed
    qualify row_number() over (
        partition by feedback_pk
        order by feedback_answered_at desc
    ) = 1

)

select * from deduplicated