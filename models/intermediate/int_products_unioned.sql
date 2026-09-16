-- The reconciliation problem in miniature.
--
-- The business is mid-migration from ERP A to ERP B, so ~20 SKUs exist in both
-- systems. A naive union double-counts them. ERP B is the go-forward system, so
-- it wins on conflict; we keep source_system on the row so anyone reading the
-- mart can see which master a product came from.

with erp_a as (

    select * from {{ ref('stg_erp_a__products') }}

),

erp_b as (

    select * from {{ ref('stg_erp_b__products') }}

),

unioned as (

    select *, 2 as source_precedence from erp_a
    union all
    select *, 1 as source_precedence from erp_b

),

deduplicated as (

    select
        *,
        row_number() over (
            partition by sku
            order by source_precedence
        ) as rn

    from unioned

)

select
    sku,
    product_name,
    category_code,
    unit_of_measure,
    standard_cost,
    source_system

from deduplicated
where rn = 1
