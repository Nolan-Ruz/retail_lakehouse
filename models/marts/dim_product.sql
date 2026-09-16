with products as (

    select * from {{ ref('int_products_unioned') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['sku']) }} as product_key,
        sku,
        product_name,
        category_code,

        case category_code
            when 'SEED' then 'Seed & Crop Inputs'
            when 'FEED' then 'Livestock Feed'
            when 'FUEL' then 'Bulk Fuel'
            when 'HDWR' then 'Farm Hardware'
            when 'TIRE' then 'Tires'
            when 'LUBE' then 'Lubricants'
            else 'Unclassified'
        end as category_name,

        -- seasonality drives how the demand forecast behaves, so it belongs in
        -- the dimension rather than being re-derived in every report
        case
            when category_code in ('SEED', 'FEED') then true
            else false
        end as is_seasonal,

        unit_of_measure,
        standard_cost,
        source_system

    from products

)

select * from final
