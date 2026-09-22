# What's left

`dbt build` runs green: 6 seeds, 6 staging models, 2 intermediate models, and
the `dim_date`, `dim_site`, `dim_product`, `fact_sales`, `fact_inventory_position`
marts, with tests on grain, keys, currency and stock status. Two singular
tests catch bad reorder policy and orphaned SKUs. `snap_product_costs`
snapshots `standard_cost` SCD2. `fact_sales` is incremental on `sold_date`.
CI (`.github/workflows/dbt-build.yml`) runs the full build on every push and
PR; `.github/workflows/dbt-docs.yml` publishes the lineage graph to
[GitHub Pages](https://nolan-ruz.github.io/retail_lakehouse/) on every push
to master.

## Left

- [ ] Add the repo link to your CV and LinkedIn.

## Don't

Don't add a BI layer, a Docker setup, or a second adapter. None of it gets
looked at. A small project with real tests, a snapshot, an incremental model
and a clear README beats a sprawling one every time.
