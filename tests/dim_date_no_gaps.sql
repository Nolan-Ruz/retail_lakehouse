with gaps as (
    select
        date_actual,
        lag(date_actual) over (order by date_actual) as prev_date
    from {{ ref('dim_date') }}
)

select *
from gaps
where datediff('day', prev_date, date_actual) > 1