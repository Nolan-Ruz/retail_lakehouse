select *
from {{ ref('dim_date') }}
where ((date_actual = '2025-09-30' and fiscal_year != 2025) or (date_actual = '2025-10-01' and fiscal_year != 2026))