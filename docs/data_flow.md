# Data Flow

## Overview

The Financial Market Data Warehouse follows a **Bronze → Silver → Gold** data flow.

![Data Architecture](images/data_flow.png)

## 1. Data Source

### Alpha Vantage API

The pipeline extracts historical stock-market data for the configured stock symbols.

The current pipeline retrieves data for:

```text
AAPL
MSFT
NVDA
AMZN
GOOGL
META
TSLA
JPM
NFLX
AMD
```

The extraction is handled by the Python ingestion process.

---

## 2. Python Data Extraction

Python initiates the pipeline and retrieves stock data from the API.

```text
Alpha Vantage API
        ↓
Python Extraction
        ↓
DataFrame
```

The pipeline records an `ingestion_id` for each pipeline execution.

---

## 3. Bronze Layer

The extracted data is loaded into the Bronze layer.

```text
Python DataFrame
       ↓
Bronze Load
       ↓
bronze.stock_price
```

The Bronze layer retains the ingested market data and supports incremental loading by identifying new and existing records.

The pipeline reports:

- Records received
- New records inserted
- Existing records skipped
- Ingestion ID

---

## 4. Silver Transformation

Bronze data is transformed into the Silver layer.

```text
Bronze
   ↓
Cleaning
   ↓
Standardization
   ↓
Silver
```

The Silver transformation prepares stock-price data for the Gold warehouse model.

The Silver layer is the source for the Gold loading procedures.

---

## 5. Gold Layer

The Gold layer transforms Silver data into a dimensional warehouse model.

The Gold layer contains:

- `gold.dim_company`
- `gold.dim_market`
- `gold.dim_date`
- `gold.fact_stock_price`

The fact table stores data at the grain:

**Company × Market × Trading Date**

---

## 6. Analytical Views

The Gold star schema is exposed through business-oriented views.

```text
Gold Star Schema
       │
       ├── vw_stock_daily_performance
       ├── vw_company_performance
       └── vw_market_performance
```

These views provide simplified datasets for stock-level, company-level, and market-level analysis.

---

## 7. Data Quality Validation

After the Gold layer load, the Python pipeline executes the warehouse data-quality procedure.

```text
Gold Load
    ↓
Data Quality Checks
    ↓
PASS ─────────→ Pipeline Completed
    │
    └── FAIL ─→ Pipeline Failed
```

The validation checks include:

- Record counts
- Dimension counts
- Duplicate fact records
- NULL foreign keys
- Orphan foreign keys
- Invalid OHLC records
- Invalid volume records
- NULL financial measures

The pipeline displays the actual validation results in the terminal.

---

## 8. Complete Pipeline Flow

![Data Architecture](images/data_flow.png)

## Pipeline Responsibility

| Stage | Main Responsibility |
|---|---|
| API | Provide source market data |
| Python | Extract and orchestrate the pipeline |
| Bronze | Store ingested data |
| Silver | Clean and standardize data |
| Gold | Build the dimensional warehouse |
| Views | Provide analytical datasets |
| Validation | Verify warehouse data quality |
