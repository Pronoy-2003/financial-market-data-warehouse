# Data Catalog — Financial Market Data Warehouse

## Overview

The **Gold Layer** is the business-ready layer of the Financial Market Data Warehouse. It uses a **star schema** with three dimensions and one fact table for historical stock-market analysis.

### Gold Objects

| Object | Type | Purpose |
|---|---|---|
| `gold.dim_company` | Dimension | Company and stock identification |
| `gold.dim_market` | Dimension | Market/exchange information |
| `gold.dim_date` | Dimension | Trading date attributes |
| `gold.fact_stock_price` | Fact | Daily OHLCV and return measures |
| `gold.vw_stock_daily_performance` | View | Daily stock-level performance |
| `gold.vw_company_performance` | View | Company-level aggregated performance |
| `gold.vw_market_performance` | View | Market-level daily performance |

---

# 1. Dimension Tables

## 1.1 `gold.dim_company`

**Purpose:** Stores company-level reference information used to identify and analyze individual stocks.

| Column | Data Type | Key | Description |
|---|---|---|---|
| `company_key` | INT | PK | Surrogate key for the company |
| `symbol` | VARCHAR(20) | UQ | Stock ticker symbol |
| `company_name` | VARCHAR(100) | — | Company name |
| `sector` | VARCHAR(100) | — | Business sector |
| `industry` | VARCHAR(150) | — | Business industry |
| `exchange` | VARCHAR(50) | — | Stock exchange |

**Business usage:** Company identification, stock-level analysis, sector/industry reporting.

---

## 1.2 `gold.dim_market`

**Purpose:** Stores stock-market and exchange reference information.

| Column | Data Type | Key | Description |
|---|---|---|---|
| `market_key` | INT | PK | Surrogate key for the market |
| `exchange` | VARCHAR(50) | UQ | Exchange code/name |
| `market_name` | VARCHAR(100) | — | Market name |
| `country` | VARCHAR(100) | — | Market country |
| `currency` | VARCHAR(10) | — | Trading currency |
| `timezone` | VARCHAR(50) | — | Market timezone |

**Business usage:** Market identification, exchange-level analysis, currency and timezone context.

---

## 1.3 `gold.dim_date`

**Purpose:** Provides calendar attributes for time-based stock-market analysis.

| Column | Data Type | Key | Description |
|---|---|---|---|
| `date_key` | INT | PK | Date key in YYYYMMDD format |
| `full_date` | DATE | UQ | Calendar/trading date |
| `year` | INT | — | Calendar year |
| `quarter` | INT | — | Calendar quarter |
| `month` | INT | — | Month number |
| `month_name` | VARCHAR(20) | — | Month name |
| `day` | INT | — | Day of month |
| `day_of_week` | INT | — | Day-of-week number |
| `day_name` | VARCHAR(20) | — | Day name |
| `is_weekend` | BIT | — | Indicates whether the date is a weekend |

**Business usage:** Daily, monthly, quarterly and yearly trend analysis.

---

# 2. Fact Table

## 2.1 `gold.fact_stock_price`

**Purpose:** Stores daily stock-market measures for each company, market and trading date.

| Column | Data Type | Key | Description |
|---|---|---|---|
| `stock_price_key` | BIGINT | PK | Unique fact record identifier |
| `company_key` | INT | FK | References `dim_company` |
| `market_key` | INT | FK | References `dim_market` |
| `date_key` | INT | FK | References `dim_date` |
| `open_price` | DECIMAL(18,4) | — | Opening stock price |
| `high_price` | DECIMAL(18,4) | — | Highest price during the trading day |
| `low_price` | DECIMAL(18,4) | — | Lowest price during the trading day |
| `close_price` | DECIMAL(18,4) | — | Closing stock price |
| `volume` | BIGINT | — | Number of shares traded |
| `daily_return` | DECIMAL(18,6) | — | Daily return measure |

### Grain

**One row represents one company × market × trading date.**

### Constraints

- Primary key: `stock_price_key`
- Unique key: `(company_key, market_key, date_key)`
- Foreign keys:
  - `company_key → gold.dim_company.company_key`
  - `market_key → gold.dim_market.market_key`
  - `date_key → gold.dim_date.date_key`

**Business usage:** OHLC analysis, trading-volume analysis, daily return analysis and historical stock performance.

---

# 3. Gold Views

## 3.1 `gold.vw_stock_daily_performance`

**Purpose:** Provides daily stock performance by joining the fact table with company, market and date dimensions.

| Column | Source |
|---|---|
| `symbol` | `dim_company` |
| `company_name` | `dim_company` |
| `market_name` | `dim_market` |
| `full_date` | `dim_date` |
| `open_price` | `fact_stock_price` |
| `high_price` | `fact_stock_price` |
| `low_price` | `fact_stock_price` |
| `close_price` | `fact_stock_price` |
| `volume` | `fact_stock_price` |
| `daily_return` | `fact_stock_price` |

**Business usage:** Daily stock performance, price trends and trading-volume analysis.

---

## 3.2 `gold.vw_company_performance`

**Purpose:** Provides aggregated historical performance metrics for each company.

| Column | Description |
|---|---|
| `symbol` | Stock ticker symbol |
| `company_name` | Company name |
| `trading_days` | Number of trading-day records |
| `first_trading_date` | Earliest available trading date |
| `latest_trading_date` | Latest available trading date |
| `avg_close_price` | Average closing price |
| `min_close_price` | Minimum closing price |
| `max_close_price` | Maximum closing price |
| `total_volume` | Total trading volume |
| `avg_daily_return` | Average daily return |

**Business usage:** Company performance comparison, historical price analysis and trading activity analysis.

---

## 3.3 `gold.vw_market_performance`

**Purpose:** Provides daily aggregated performance metrics at the market level.

| Column | Description |
|---|---|
| `full_date` | Trading date |
| `market_name` | Market name |
| `stocks_traded` | Number of distinct companies traded |
| `avg_close_price` | Average closing price across stocks |
| `avg_daily_return` | Average daily return across stocks |
| `total_volume` | Total trading volume |

**Business usage:** Market-level trend analysis, trading activity and daily market performance.

---

# 4. Gold Layer Relationships

```text
                    gold.dim_company
                           |
                           |
                           v
gold.dim_market ---> gold.fact_stock_price <--- gold.dim_date
                           |
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
   vw_stock_daily   vw_company_      vw_market_
    _performance    performance      performance
```

### Star Schema

- **Fact table:** `gold.fact_stock_price`
- **Dimensions:** `gold.dim_company`, `gold.dim_market`, `gold.dim_date`
- **Fact grain:** Company × Market × Trading Date
- **Measures:** Open, High, Low, Close, Volume, Daily Return

---

# 5. Data Lineage

```text
Alpha Vantage API
       |
       v
Bronze Layer
Raw Market Data
       |
       v
Silver Layer
Cleaned & Standardized Data
       |
       v
Gold Layer
Star Schema
       |
       +---- dim_company
       +---- dim_market
       +---- dim_date
       |
       +---- fact_stock_price
              |
              +---- Gold analytical views
```

The Gold layer is loaded through stored procedures and orchestrated by the Python pipeline. Data quality validation is executed as part of the pipeline before the final run is considered successful.

---

# 6. Data Warehouse Purpose

The warehouse is primarily designed to demonstrate:

- **ETL/ELT pipeline development**
- **Medallion architecture**
- **Star schema data modelling**
- **Dimension and fact table design**
- **SQL stored procedures**
- **Python pipeline orchestration**
- **Incremental/idempotent loading**
- **Data quality and warehouse validation**
- **Business-ready analytical views**
