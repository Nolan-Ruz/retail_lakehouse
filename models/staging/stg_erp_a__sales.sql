with source as (

    select * from {{ ref('erp_a_sales') }}

),

renamed as (

    select
        WERKS                        as site_id,
        MATNR                        as sku,
        cast(BUDAT as date)          as sold_date,
        cast(MENGE as integer)       as quantity,
        cast(NETWR as decimal(14, 2)) as net_amount,
        WAERS                        as currency_code,
        'ERP_A'                      as source_system

    from source

)

select * from renamed
