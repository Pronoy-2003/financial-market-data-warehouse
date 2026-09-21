# System Architecture

## Overview

The Financial Market Data Warehouse is an end-to-end data engineering project that collects stock-market data from the **Alpha Vantage API**, processes it through a SQL Server warehouse using **Bronze → Silver → Gold** layers, and exposes business-ready analytical views.

The project is primarily designed to demonstrate **data warehousing, ETL/ELT, SQL Server, Python orchestration, dimensional modelling, and data quality validation**.

## Architecture

![Financial Market Data Warehouse Architecture](images/project_architecture.png)

## End-to-End Flow

```text
Alpha Vantage API
        ↓
Python Pipeline
        ↓
Bronze Layer
        ↓
Silver Layer
        ↓
Gold Layer
        ↓
Analytical Views
```

## Main Components

| Component | Purpose |
|---|---|
| Alpha Vantage API | Source of stock-market data |
| Python | API extraction and pipeline orchestration |
| Bronze | Stores raw ingested market data |
| Silver | Cleans and standardizes market data |
| Gold | Provides a business-ready star schema |
| Analytical Views | Provides simplified reporting/analysis datasets |
| Data Quality | Validates warehouse integrity before pipeline completion |

## Warehouse Layers

### Bronze

Stores raw market data received from the API with ingestion tracking.

### Silver

Contains cleaned and standardized stock-price data used as the source for the Gold layer.

### Gold

Uses a **star schema**:

```text
                    dim_company
                         |
                         |
dim_market ---- fact_stock_price ---- dim_date
```

The fact table stores daily stock measures at the grain of:

**Company × Market × Trading Date**

The Gold layer contains:

- `gold.dim_company`
- `gold.dim_market`
- `gold.dim_date`
- `gold.fact_stock_price`

## Python Orchestration

The main Python pipeline coordinates the complete process:

```text
main.py
   ↓
ingestion.py
   ↓
bronze_loader.py
   ↓
silver_loader.py
   ↓
gold_loader.py
   ↓
warehouse_validation.py
```

The orchestration creates an ingestion ID, extracts the data, loads Bronze, transforms Silver, loads Gold, runs warehouse data-quality checks, and records the final pipeline status.

## Data Quality Gate

The pipeline does not consider the run successful when warehouse validation fails.

```text
Gold Load
    ↓
Data Quality Validation
    ↓
PASS ─────────→ Pipeline Completed
    │
    └─ FAIL ──→ Pipeline Failed
```

## Key Design Principles

- **Layered processing:** Bronze → Silver → Gold
- **Star schema:** Fact table supported by reusable dimensions
- **Idempotent loading:** Existing Bronze and Gold records are not unnecessarily duplicated
- **Python orchestration:** End-to-end pipeline execution from one entry point
- **Data quality gate:** Warehouse validation is part of the pipeline
- **Separation of responsibilities:** Extraction, loading, transformation, validation, and orchestration are handled separately

## Summary

**API → Python → Bronze → Silver → Gold → Analytical Views → Data Quality Validation**
