with source as (

    select * from {{ ref('inventory_snapshots') }}

),

renamed as (

    select
        cast(snapshot_date as date)        as snapshot_date,
        site_id,
        sku,
        cast(quantity_on_hand as integer)  as quantity_on_hand,
        cast(min_level as integer)         as min_level,
        cast(max_level as integer)         as max_level

    from source

)

select * from renamed
