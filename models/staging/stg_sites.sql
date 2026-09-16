with source as (

    select * from {{ ref('sites') }}

),

renamed as (

    select
        site_id,
        site_name,
        province,
        region

    from source

)

select * from renamed
