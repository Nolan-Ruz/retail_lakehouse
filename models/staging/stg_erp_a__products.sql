-- Staging does three things and nothing else: rename, recast, and drop what
-- the warehouse will never use. No joins, no business logic, no aggregation.

with source as (

    select * from {{ ref('erp_a_products') }}

),

renamed as (

    select
        MATNR                       as sku,
        MAKTX                       as product_name,
        MTART                       as category_code,
        MEINS                       as unit_of_measure,
        cast(STPRS as decimal(12, 2)) as standard_cost,
        'ERP_A'                     as source_system

    from source

)

select * from renamed
