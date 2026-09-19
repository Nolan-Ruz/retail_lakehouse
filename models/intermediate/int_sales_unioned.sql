-- ERP A and ERP B sales are mostly disjoint, so this is a plain union with one
-- exception. If an ERP A row is an exact match of an ERP B row (same site, sku,
-- date, quantity, amount and currency), it is the same sale recorded twice and
-- ERP B wins, consistent with int_products_unioned.
--
-- Rows that share a site/sku/date but differ in quantity or amount are NOT
-- treated as duplicates: both are kept. source_system stays on every row.
--
-- Conflicts are flagged, not resolved. A row is flagged needs_review when
-- another row matches it on site, sku, date, quantity and currency but has a
-- different net_amount. Nothing in the data says whether that is one sale
-- reported twice or two separate sales, so the business decides. Rows that
-- differ in quantity are treated as separate transactions and not flagged.

with erp_a as (

    select * from {{ ref('stg_erp_a__sales') }}

),

erp_b as (

    select * from {{ ref('stg_erp_b__sales') }}

),

erp_a_not_in_b as (

    select a.*

    from erp_a as a
    where not exists (
        select 1
        from erp_b as b
        where a.site_id       = b.site_id
          and a.sku           = b.sku
          and a.sold_date     = b.sold_date
          and a.quantity      = b.quantity
          and a.net_amount    = b.net_amount
          and a.currency_code = b.currency_code
    )

),

unioned as (

    select * from erp_a_not_in_b
    union all
    select * from erp_b

),

flagged as (

    select
        *,
        count(*) over conflict_window > 1
            and min(net_amount) over conflict_window
                <> max(net_amount) over conflict_window
            as needs_review,
        min(source_system) over conflict_window
            <> max(source_system) over conflict_window
            as spans_systems

    from unioned
    window conflict_window as (
        partition by site_id, sku, sold_date, quantity, currency_code
    )

)

select
    site_id,
    sku,
    sold_date,
    quantity,
    net_amount,
    currency_code,
    source_system,
    needs_review,

    case
        when not needs_review then null
        when spans_systems then 'across_systems'
        else 'within_system'
    end as review_scope,

    case
        when needs_review then {{ dbt_utils.generate_surrogate_key([
            'site_id', 'sku', 'sold_date', 'quantity', 'currency_code'
        ]) }}
    end as review_group_key

from flagged
