# What's left

`dbt build` runs green: 6 seeds, 6 staging models, 2 intermediate models, and
the `dim_date`, `dim_site`, `dim_product`, `fact_sales` marts, with tests on
grain, keys and currency. CI (`.github/workflows/dbt-build.yml`) runs the
same build on every push and PR. What's left is the modelling that separates
this from a tutorial — it should be your SQL, not generated SQL you're
reading for the first time in the interview.

Run `dbt build --profiles-dir .` after each one.

## 1. The inventory mart

- [ ] `fct_inventory_position` — month-end on-hand against min/max, plus a
      `stock_status` of `below_min` / `in_band` / `above_max`. This is the
      model that connects to the forecasting story you tell in interviews.

## 2. Tests that show judgement

Generic tests prove you read the docs. These prove you've thought about the
data.

- [ ] A singular test in `tests/` — a `.sql` file returning rows that
      shouldn't exist. Good candidate: inventory snapshots where
      `min_level > max_level`.
- [ ] A second one: SKUs with sales but no row in `dim_product`. Orphaned facts
      are the failure mode that quietly breaks a semantic model.

## 3. The two things that separate you from people who did a tutorial

- [ ] **A snapshot.** `snapshots/snap_product_costs.sql`, SCD2 on
      `standard_cost` with `strategy='check'`. Cost changes over time and the
      old value matters for historical margin. Be ready to explain why a
      snapshot rather than just recomputing.
- [ ] **An incremental model.** Make `fact_sales` incremental on `sold_date`
      with a sensible `unique_key` and an `{% if is_incremental() %}` filter.
      Then be ready for the follow-up: what happens on a late-arriving invoice,
      and what does `--full-refresh` cost you.

## 4. Ship it

- [ ] `dbt docs generate`, push to GitHub Pages so the lineage graph has a
      public URL.
- [ ] Add the repo link to your CV and LinkedIn.

## Don't

Don't add a BI layer, a Docker setup, or a second adapter. None of it gets
looked at. A small project with real tests, a snapshot, an incremental model
and a clear README beats a sprawling one every time.
