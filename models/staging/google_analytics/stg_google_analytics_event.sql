with

source as (

    select * from {{ source('google_analytics_4', 'event_flattened') }}

),

renamed as (

    select
        -- pas de clé primaire dans la source : on en crée une par concaténation
        {{ dbt_utils.generate_surrogate_key([
            'user_pseudo_id',
            'event_timestamp',
            'event_name',
            'ga_session_id',
            'page_location'
        ]) }}                                              as event_pk,

        -- identifiants
        user_pseudo_id,
        cast(ga_session_id as int64)                       as ga_session_id,

        -- événement
        event_name,

        -- event_date : chaîne 'YYYYMMDD' -> vraie DATE
        safe.parse_date('%Y%m%d', event_date)              as event_date,

        -- timestamps GA4 : INTEGER en microsecondes depuis l'epoch -> TIMESTAMP lisible
        timestamp_micros(event_timestamp)                  as event_at,
        timestamp_micros(user_first_touch_timestamp)       as user_first_touch_at,

        -- page
        page_title,
        page_location,

        -- navigateur
        browser,

        -- source de trafic
        traffic_source_medium,
        traffic_source_source,
        traffic_source_name

    from source

),

deduplicated as (

    -- suppression des doublons éventuels sur la clé générée
    select *
    from renamed
    qualify row_number() over (partition by event_pk order by event_at) = 1

)

select * from deduplicated