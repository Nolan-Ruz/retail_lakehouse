-- Inventory snapshots where the min level exceeds the max level. That's a
-- contradiction in the supply chain team's own reorder policy, not a valid
-- state, so any row here is a data entry error to flag upstream.

select *
from {{ ref('stg_inventory_snapshots') }}
where min_level > max_level
