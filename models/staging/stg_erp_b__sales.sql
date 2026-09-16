with source as (

    select * from {{ ref('erp_b_sales') }}

),

renamed as (

    select
        SiteId                            as site_id,
        ItemNumber                        as sku,
        cast(InvoiceDate as date)         as sold_date,
        cast(Quantity as integer)         as quantity,
        cast(LineAmount as decimal(14, 2)) as net_amount,
        CurrencyCode                      as currency_code,
        'ERP_B'                           as source_system

    from source

)

select * from renamed
