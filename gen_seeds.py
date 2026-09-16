"""Generate synthetic retail data split across two 'ERP' systems.

ERP A mimics SAP naming (MATNR, WERKS, MENGE...).
ERP B mimics D365 F&O naming (ItemNumber, SiteId, Quantity...).
The two overlap on some products, which is the reconciliation problem.
"""
import csv
import random
from datetime import date, timedelta

random.seed(42)

OUT = "seeds/"

CATEGORIES = [
    ("SEED", "Seed & Crop Inputs", True),
    ("FEED", "Livestock Feed", True),
    ("FUEL", "Bulk Fuel", False),
    ("HDWR", "Farm Hardware", False),
    ("TIRE", "Tires", False),
    ("LUBE", "Lubricants", False),
]

SITES = [
    ("S01", "Calgary North", "AB", "prairie"),
    ("S02", "Lethbridge", "AB", "prairie"),
    ("S03", "Red Deer", "AB", "prairie"),
    ("S04", "Saskatoon", "SK", "prairie"),
    ("S05", "Brandon", "MB", "prairie"),
    ("S06", "Grande Prairie", "AB", "north"),
]

# ---------------------------------------------------------------- products
products = []
for i in range(1, 121):
    cat, _, seasonal = random.choice(CATEGORIES)
    products.append({
        "sku": f"{cat}-{i:04d}",
        "name": f"{cat.title()} Product {i:04d}",
        "category": cat,
        "seasonal": seasonal,
        "unit_cost": round(random.uniform(8, 420), 2),
        # products 1-80 live in ERP A, 61-120 in ERP B -> 61-80 overlap
        "in_a": i <= 80,
        "in_b": i >= 61,
    })

with open(OUT + "erp_a_products.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["MANDT", "MATNR", "MAKTX", "MTART", "MEINS", "STPRS"])
    for p in products:
        if p["in_a"]:
            w.writerow(["100", p["sku"], p["name"], p["category"], "EA", p["unit_cost"]])

with open(OUT + "erp_b_products.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["ItemNumber", "ProductName", "ItemGroup", "UnitOfMeasure", "StandardCost"])
    for p in products:
        if p["in_b"]:
            w.writerow([p["sku"], p["name"], p["category"], "EA", p["unit_cost"]])

# ------------------------------------------------------------------- sites
with open(OUT + "sites.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["site_id", "site_name", "province", "region"])
    for s in SITES:
        w.writerow(list(s))

# ------------------------------------------------------------------- sales
START = date(2024, 1, 1)
END = date(2025, 12, 31)


def seasonal_factor(d: date, seasonal: bool) -> float:
    if not seasonal:
        return 1.0
    # spring seeding peak, autumn secondary peak
    m = d.month
    return {1: .4, 2: .5, 3: .9, 4: 1.9, 5: 2.4, 6: 1.6,
            7: .9, 8: 1.0, 9: 1.5, 10: 1.3, 11: .7, 12: .4}[m]


rows_a, rows_b = [], []
d = START
while d <= END:
    # weekends are quieter
    daily = 14 if d.weekday() < 5 else 5
    for _ in range(daily):
        p = random.choice(products)
        site = random.choice(SITES)
        qty = max(1, int(random.gauss(18, 7) * seasonal_factor(d, p["seasonal"])))
        margin = random.uniform(1.12, 1.48)
        amount = round(qty * p["unit_cost"] * margin, 2)
        if p["in_a"] and (not p["in_b"] or random.random() < 0.5):
            rows_a.append(["100", site[0], p["sku"], d.isoformat(), qty, amount, "CAD"])
        elif p["in_b"]:
            rows_b.append([site[0], p["sku"], d.isoformat(), qty, amount, "CAD"])
    d += timedelta(days=1)

with open(OUT + "erp_a_sales.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["MANDT", "WERKS", "MATNR", "BUDAT", "MENGE", "NETWR", "WAERS"])
    w.writerows(rows_a)

with open(OUT + "erp_b_sales.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["SiteId", "ItemNumber", "InvoiceDate", "Quantity", "LineAmount", "CurrencyCode"])
    w.writerows(rows_b)

# --------------------------------------------------------------- inventory
# month-end on-hand snapshots, plus the business min/max levels
def month_ends(start: date, end: date):
    y, m = start.year, start.month
    while True:
        nxt_y, nxt_m = (y + 1, 1) if m == 12 else (y, m + 1)
        me = date(nxt_y, nxt_m, 1) - timedelta(days=1)
        if me > end:
            return
        yield me
        y, m = nxt_y, nxt_m


inv = []
for d in month_ends(START, END):
    for p in products:
        for site in SITES:
            if random.random() < 0.35:
                continue
            mn = random.randint(5, 40)
            mx = mn + random.randint(30, 160)
            on_hand = max(0, int(random.gauss((mn + mx) / 2, (mx - mn) / 3)))
            inv.append([d.isoformat(), site[0], p["sku"], on_hand, mn, mx])

with open(OUT + "inventory_snapshots.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["snapshot_date", "site_id", "sku", "quantity_on_hand", "min_level", "max_level"])
    w.writerows(inv)

print(f"products  A={sum(p['in_a'] for p in products)} B={sum(p['in_b'] for p in products)} "
      f"overlap={sum(p['in_a'] and p['in_b'] for p in products)}")
print(f"sales     A={len(rows_a)} B={len(rows_b)}")
print(f"inventory {len(inv)}")
