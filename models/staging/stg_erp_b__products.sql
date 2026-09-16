with source as (

    select * from {{ ref('erp_b_products') }}

),

renamed as (

    select
        ItemNumber                          as sku,
        ProductName                         as product_name,
        ItemGroup                           as category_code,
        UnitOfMeasure                       as unit_of_measure,
        cast(StandardCost as decimal(12, 2)) as standard_cost,
        'ERP_B'                             as source_system

    from source

)

select * from renamed
