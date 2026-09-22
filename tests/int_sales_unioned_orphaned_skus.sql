-- SKUs that have sales but no row in dim_product. This is the failure mode
-- that quietly breaks downstream reporting: fact_sales still builds (the join
-- to dim_product is a left join), but the row's product_key comes back null
-- and it silently drops out of anything sliced by category or cost.

select distinct sales.sku
from {{ ref('int_sales_unioned') }} as sales
left join {{ ref('dim_product') }} as products
    on sales.sku = products.sku
where products.sku is null
