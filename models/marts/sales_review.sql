-- Sales rows the business needs to rule on. Each review_group_key is a set of
-- rows that match on site, sku, date, quantity and currency but disagree on
-- net_amount: either one sale reported twice with different amounts, or
-- separate sales. Both rows are kept in the sales data until that is decided.

with sales as (

    select * from {{ ref('int_sales_unioned') }}

)

select
    review_group_key,
    review_scope,
    site_id,
    sku,
    sold_date,
    quantity,
    net_amount,
    currency_code,
    source_system

from sales
where needs_review
order by review_group_key, source_system, net_amount
