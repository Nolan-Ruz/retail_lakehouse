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
    group by sales.sku,
        sales.site_id,
        products.product_key,
        sites.site_key,
        dates.date_key,
        dates.date_actual,
        sales.currency_code
)

select * from sales_joined