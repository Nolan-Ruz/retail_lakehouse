with sites as (

    select * from {{ ref('stg_sites') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['site_id']) }} as site_key,
        site_id,
        site_name,
        province,
        region

    from sites

)

select * from final