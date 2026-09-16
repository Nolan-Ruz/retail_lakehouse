# What's yours to build

The scaffold is done and `dbt build` runs green: 6 seeds, 6 staging models,
1 intermediate, 1 mart, 35 tests. What's left is the modelling — which is the
part you'd have to defend in a technical screen, so it should be your SQL, not
generated SQL you're reading for the first time in the interview.

Work down the list. Run `dbt build --profiles-dir .` after each one.

## 1. Finish the dimensions

- [ ] `dim_site` — from `stg_sites`. Surrogate key, tests mirroring
      `dim_product`. Twenty minutes.
- [ ] `dim_date` — a date spine covering 2024-01-01 to 2025-12-31. Year,
      quarter, month, month name, day of week, is_weekend, and a
      `fiscal_year` on whatever fiscal calendar you invent. `dbt_utils.date_spine`
      generates the spine; you write the attributes.

## 2. The fact table

- [ ] `int_sales_unioned` — same reconciliation pattern as products, but think
      about whether it's actually the same. Product overlap means duplicate
      *master records*. Does sales overlap mean duplicate *transactions*?
      Check the data before you assume. Whichever answer you land on, write
      the reasoning as a comment — that comment is the interview answer.
- [ ] `fct_sales` — grain: one row per site / SKU / day. State the grain in the
      model description. Foreign keys to all three dimensions, `quantity`,
      `net_amount`, and a `gross_margin` using `standard_cost` from
      `dim_product`.
- [ ] Test the grain: `dbt_utils.unique_combination_of_columns` on the three
      keys. If it fails, your grain claim was wrong — fix the model, not the
      test.

## 3. The inventory mart

- [ ] `fct_inventory_position` — month-end on-hand against min/max, plus a
      `stock_status` of `below_min` / `in_band` / `above_max`. This is the
      model that connects to the forecasting story you tell in interviews.

## 4. Tests that show judgement

Generic tests prove you read the docs. These prove you've thought about the
data.

- [ ] A singular test in `tests/` — a `.sql` file returning rows that
      shouldn't exist. Good candidate: inventory snapshots where
      `min_level > max_level`.
- [ ] A second one: SKUs with sales but no row in `dim_product`. Orphaned facts
      are the failure mode that quietly breaks a semantic model.

## 5. The two things that separate you from people who did a tutorial

- [ ] **A snapshot.** `snapshots/snap_product_costs.sql`, SCD2 on
      `standard_cost` with `strategy='check'`. Cost changes over time and the
      old value matters for historical margin. Be ready to explain why a
      snapshot rather than just recomputing.
- [ ] **An incremental model.** Make `fct_sales` incremental on `sold_date`
      with a sensible `unique_key` and an `{% if is_incremental() %}` filter.
      Then be ready for the follow-up: what happens on a late-arriving invoice,
      and what does `--full-refresh` cost you.

## 6. Ship it

- [ ] `dbt docs generate`, push to GitHub Pages so the lineage graph has a
      public URL.
- [ ] Rewrite the README opening in your own words. The framing that does the
      work in an application is: *this is the Bronze/Silver/Gold pattern I ran
      in Fabric at UFA, rebuilt in dbt's conventions.* That sentence closes the
      tooling gap without claiming years you don't have.
- [ ] Add the repo link to your CV and LinkedIn.

## Don't

Don't add a BI layer, a Docker setup, CI, or a second adapter. None of it gets
looked at. A small project with real tests, a snapshot, an incremental model
and a clear README beats a sprawling one every time.
