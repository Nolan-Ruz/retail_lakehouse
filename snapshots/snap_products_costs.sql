{% snapshot snap_product_costs %}

{{
    config(

    target_schema='snapshots',
    unique_key='sku',
    strategy='check',
    check_cols=['standard_cost'],

)

}}

with products as (

    select * from {{ ref('int_products_unioned') }}

),

snap_products as (

    select
        sku,
        product_name,
        category_code,
        unit_of_measure,
        standard_cost

    from products

)

select * from snap_products

{% endsnapshot %}