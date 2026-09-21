# ETL Pipeline

## Overview

The pipeline is orchestrated through a single Python entry point, `main.py`. It executes extraction, Bronze loading, Silver transformation, Gold loading, and warehouse data-quality validation in sequence. fileciteturn18file6L29-L39

```text
Alpha Vantage API
        ↓
   Data Extraction
        ↓
    Bronze Load
        ↓
 Silver Transformation
        ↓
     Gold Load
        ↓
 Data Quality Validation
        ↓
     PASS / FAIL
```

## 1. Extract

Stock-market data is retrieved from Alpha Vantage through the Python ingestion module.

The API configuration uses the `TIME_SERIES_DAILY` function and retrieves daily stock data. fileciteturn18file8L7-L18

The pipeline stores the number of records received for the current execution.

```text
API
 ↓
ingest_stock_data()
 ↓
DataFrame
```

## 2. Bronze Load

The extracted DataFrame is loaded into the Bronze layer through `load_to_bronze()`.

The pipeline passes the generated `ingestion_id` to the Bronze loader and reports both newly inserted and previously existing records. fileciteturn18file6L61-L84

```text
DataFrame
    ↓
Bronze Loader
    ↓
bronze.stock_price
```

The pipeline also starts and updates an ingestion log for execution tracking. fileciteturn18file6L35-L39

## 3. Silver Transformation

The Silver stage executes the SQL Server procedure:

```text
silver.usp_load_stock_price
```

The Python Silver loader opens a SQL Server connection, executes the procedure, commits the transaction, and rolls back if an error occurs. fileciteturn18file7L4-L26

```text
Bronze
   ↓
silver.usp_load_stock_price
   ↓
Silver
```

## 4. Gold Load

The Gold stage executes the Gold loading process through:

```text
load_to_gold()
```

The Gold layer contains the dimensional model:

```text
dim_company
dim_market
dim_date
      ↓
fact_stock_price
```

Gold loading occurs after the Silver transformation. fileciteturn18file6L96-L104

## 5. Data Quality Validation

After the Gold load, the pipeline executes:

```text
gold.usp_run_data_quality_checks
```

The validation module retrieves the returned result set and displays each check with:

- Actual value
- Expected value
- Failed rows
- Status

It also calculates total, passed, and failed checks. fileciteturn18file10L26-L40 fileciteturn18file10L100-L110

```text
Gold
  ↓
Data Quality Procedure
  ↓
Detailed Validation Results
```

## 6. Data Quality Gate

The validation result controls whether the pipeline is considered successful.

```text
Validation
     │
     ├── PASS → Continue → SUCCESS
     │
     └── FAIL → Stop → FAILED
```

If validation fails, `main.py` raises a runtime error and the pipeline enters the failure-handling block. fileciteturn18file6L114-L124

## 7. Ingestion Logging

Each pipeline execution receives a unique UUID-based `ingestion_id`. fileciteturn18file6L18-L27

On successful completion, the ingestion log is updated with:

```text
ingestion_id
status = SUCCESS
records_received
```

On failure, it records:

```text
ingestion_id
status = FAILED
records_received
error_message
```

This provides traceability for individual pipeline executions. fileciteturn18file6L126-L135 fileciteturn18file6L179-L190

## 8. Pipeline Failure Handling

Each major stage is executed inside a `try/except` block.

If an exception occurs:

1. The ingestion log is updated as `FAILED`.
2. The error message is recorded.
3. A failure summary is printed.
4. The exception is raised again.

This prevents a failed pipeline from being reported as a successful run. fileciteturn18file6L179-L220

## 9. End-to-End Execution

The final orchestration is:

```text
Create Ingestion ID
        ↓
Start Ingestion Log
        ↓
Extract API Data
        ↓
Load Bronze
        ↓
Transform Silver
        ↓
Load Gold
        ↓
Run Data Quality Checks
        ↓
   ┌────┴────┐
   ↓         ↓
 PASS       FAIL
   ↓         ↓
SUCCESS    FAILED
```

## Pipeline Characteristics

| Characteristic | Implementation |
|---|---|
| Orchestration | Python |
| Source | Alpha Vantage API |
| Raw layer | Bronze |
| Transformation layer | Silver |
| Business layer | Gold |
| Validation | SQL Server procedure + Python |
| Execution tracking | Ingestion ID + ingestion log |
| Failure handling | Exception handling + rollback |
| Idempotency | Existing records are skipped where applicable |
