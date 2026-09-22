{{
    config(
        materialized='incremental',
        unique_key=['product_key', 'site_key', 'date_key'],
        incremental_strategy='merge'
    )
}}

with sales as (
    select * from {{ ref('int_sales_unioned') }}
),

products as ( 
    select * from {{ ref('dim_product') }} 
),

sites as (
    select * from {{ ref('dim_site') }}
),

dates as (
    select * from {{ ref('dim_date') }}
),

sales_joined as (
    select 
        products.product_key as product_key,
        sites.site_key as site_key,
        dates.date_key as date_key,
        dates.date_actual as sold_date,
        sum(sales.quantity) quantity,
        sum(sales.net_amount) net_amount,
        sum(
            net_amount - (quantity * products.standard_cost) 
        ) as gross_total_margin,
        sales.currency_code as currency_code
    from sales
        left join products on sales.sku = products.sku
        left join sites on sales.site_id = sites.site_id
        left join dates on sales.sold_date = dates.date_actual

    {% if is_incremental() %}
    -- Only reprocess source rows newer than what's already in the table,
    -- so a normal run aggregates just the new day(s) instead of rescanning
    -- and re-summing the full sales history.
    where sales.sold_date > (select max(sold_date) from {{ this }})
    {% endif %}

    group by sales.sku,
        sales.site_id,
        products.product_key,
        sites.site_key,
        dates.date_key,
        dates.date_actual,
        sales.currency_code
)

select * from sales_joined