select count(*) as actual_days
from {{ ref('dim_date') }}
having count(*) != datediff('day', cast('2024-01-01' as date), cast('2026-01-01' as date))