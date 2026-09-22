with inventory as (

    select * from {{ ref('stg_inventory_snapshots') }}

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

inventory_joined as (

    select
        products.product_key as product_key,
        sites.site_key as site_key,
        dates.date_key as date_key,
        dates.date_actual as snapshot_date,
        inventory.quantity_on_hand,
        case
            when inventory.quantity_on_hand < inventory.min_level then 'below_min'
            when inventory.quantity_on_hand > inventory.max_level then 'above_max'
            else 'in_band'
        end as stock_status
    from
        inventory
            left join products on inventory.sku = products.sku
            left join sites on inventory.site_id = sites.site_id
            left join dates on inventory.snapshot_date = dates.date_actual
)

select * from inventory_joined
