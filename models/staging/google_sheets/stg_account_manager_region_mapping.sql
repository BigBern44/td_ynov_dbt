with

source as (

    select * from {{ source('google_sheets', 'account_manager_region') }}

),

renamed as (

    select
        -- pas de clé primaire métier : on en crée une (un account manager par État)
        {{ dbt_utils.generate_surrogate_key(['State']) }} as region_mapping_id,

        -- colonnes métier (renommées en snake_case)
        State                                             as state,
        Account_Manager                                   as account_manager,

        -- date de chargement Airbyte conservée (utile pour la fraîcheur / le suivi)
        _airbyte_extracted_at                             as loaded_at

        -- colonnes techniques Airbyte ignorées :
        -- _airbyte_raw_id, _airbyte_meta, _airbyte_generation_id

    from source

),

deduplicated as (

    -- une seule ligne par État ; en cas de doublon, on garde le chargement le plus récent
    select *
    from renamed
    qualify row_number() over (
        partition by region_mapping_id
        order by loaded_at desc
    ) = 1

)

select * from deduplicated