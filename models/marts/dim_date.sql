with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2024-01-01' as date)",
        end_date="cast('2026-01-01' as date)"
    ) }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['date_day']) }} as date_key,
        date_day as date_actual,
        year(date_day) as year_actual,
        month(date_day) as month_actual,
        day(date_day) as day_actual,
        weekday(date_day) as day_of_week,
        case when weekday(date_day) in (0, 6) then 1 else 0 end as is_weekend,
        case when month(date_day) in (10, 11, 12) then 1 else 0 end as is_quarter_1,
        case when month(date_day) in (1, 2, 3) then 1 else 0 end as is_quarter_2,
        case when month(date_day) in (4, 5, 6) then 1 else 0 end as is_quarter_3,
        case when month(date_day) in (7, 8, 9) then 1 else 0 end as is_quarter_4,
        case when month(date_day) in (10, 11, 12, 1, 2, 3) then 1 else 0 end as is_half_1,
        case when month(date_day) in (4, 5, 6, 7, 8, 9) then 1 else 0 end as is_half_2,
        case when month(date_day) >= 10 then year(date_day) + 1 else year(date_day) end as fiscal_year,
    from date_spine
)

select * from final