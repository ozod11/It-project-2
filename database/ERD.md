# ERD – Korzinka Inventory Management

## Main entities

- **products** — product information
- **locations** — stores and warehouses
- **inventory** — current quantity of each product at each location
- **stock_transactions** — incoming and outgoing product movements

## Relationships

```text
PRODUCTS 1 ───────< INVENTORY >─────── 1 LOCATIONS
   │
   │
   └──────────────< STOCK_TRANSACTIONS >────────────── 1 LOCATIONS
```

A product can exist in many locations and a location can contain many products.
The `inventory` table resolves this many-to-many relationship and stores the current quantity.

Each stock transaction belongs to one product and one location and records either an incoming (`IN`) or outgoing (`OUT`) movement.
