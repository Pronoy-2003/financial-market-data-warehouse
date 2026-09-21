# Data Model

## Overview

The Gold layer uses a **star schema** designed for historical stock-market analysis.

The model contains:

- **1 fact table:** `gold.fact_stock_price`
- **3 dimension tables:** `gold.dim_company`, `gold.dim_market`, `gold.dim_date`

## Star Schema

![Data Architecture](images/data_model.png)

## Fact Table

### `gold.fact_stock_price`

Stores daily stock-market measures.

**Grain:**

> One row represents one company × market × trading date.

| Column | Type | Key | Description |
|---|---|---|---|
| `stock_price_key` | BIGINT | PK | Unique fact record identifier |
| `company_key` | INT | FK | Company dimension reference |
| `market_key` | INT | FK | Market dimension reference |
| `date_key` | INT | FK | Date dimension reference |
| `open_price` | DECIMAL(18,4) | — | Opening price |
| `high_price` | DECIMAL(18,4) | — | Highest price during the trading day |
| `low_price` | DECIMAL(18,4) | — | Lowest price during the trading day |
| `close_price` | DECIMAL(18,4) | — | Closing price |
| `volume` | BIGINT | — | Trading volume |
| `daily_return` | DECIMAL(18,6) | — | Daily return |

### Fact Table Constraint

The combination below is unique:

```text
(company_key, market_key, date_key)
```

This prevents duplicate fact records for the same company, market, and trading date.

---

## Dimension Tables

### `gold.dim_company`

Stores company-level information.

| Column | Type | Key | Description |
|---|---|---|---|
| `company_key` | INT | PK | Surrogate company key |
| `symbol` | VARCHAR(20) | UQ | Stock ticker symbol |
| `company_name` | VARCHAR(100) | — | Company name |
| `sector` | VARCHAR(100) | — | Business sector |
| `industry` | VARCHAR(150) | — | Business industry |
| `exchange` | VARCHAR(50) | — | Stock exchange |

**Relationship:**

```text
dim_company.company_key
        ↓
fact_stock_price.company_key
```

---

### `gold.dim_market`

Stores market/exchange information.

| Column | Type | Key | Description |
|---|---|---|---|
| `market_key` | INT | PK | Surrogate market key |
| `exchange` | VARCHAR(50) | UQ | Exchange identifier |
| `market_name` | VARCHAR(100) | — | Market name |
| `country` | VARCHAR(100) | — | Market country |
| `currency` | VARCHAR(10) | — | Market currency |
| `timezone` | VARCHAR(50) | — | Market timezone |

**Relationship:**

```text
dim_market.market_key
        ↓
fact_stock_price.market_key
```

---

### `gold.dim_date`

Stores calendar attributes used for time-based analysis.

| Column | Type | Key | Description |
|---|---|---|---|
| `date_key` | INT | PK | Date key in YYYYMMDD format |
| `full_date` | DATE | UQ | Calendar date |
| `year` | INT | — | Calendar year |
| `quarter` | INT | — | Calendar quarter |
| `month` | INT | — | Month number |
| `month_name` | VARCHAR(20) | — | Month name |
| `day` | INT | — | Day of month |
| `day_of_week` | INT | — | Day-of-week number |
| `day_name` | VARCHAR(20) | — | Day name |
| `is_weekend` | BIT | — | Weekend indicator |

**Relationship:**

```text
dim_date.date_key
        ↓
fact_stock_price.date_key
```

---

## Relationships

| Parent Dimension | Key | Fact Table | Foreign Key |
|---|---|---|---|
| `dim_company` | `company_key` | `fact_stock_price` | `company_key` |
| `dim_market` | `market_key` | `fact_stock_price` | `market_key` |
| `dim_date` | `date_key` | `fact_stock_price` | `date_key` |

All three dimensions have a **one-to-many relationship** with the fact table.



## Analytical Views

The Gold layer also provides three views built from the star schema:

| View | Purpose |
|---|---|
| `gold.vw_stock_daily_performance` | Daily stock-level performance |
| `gold.vw_company_performance` | Aggregated company-level performance |
| `gold.vw_market_performance` | Daily market-level performance |

```text
Gold Star Schema
       |
       +── vw_stock_daily_performance
       |
       +── vw_company_performance
       |
       +── vw_market_performance
```

## Design Summary

| Element | Design |
|---|---|
| Model | Star Schema |
| Fact | `fact_stock_price` |
| Dimensions | Company, Market, Date |
| Fact Grain | Company × Market × Trading Date |
| Surrogate Keys | Company and Market dimensions |
| Date Key | `YYYYMMDD` integer |
| Fact Measures | OHLC, Volume, Daily Return |
| Analytical Layer | Gold views |
