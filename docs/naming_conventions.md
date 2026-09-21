# Naming Conventions

This document defines the naming conventions used in the **Financial Market Data Warehouse** project for database objects, Python files, variables, and SQL scripts.

---

# 1. General Principles

- **Language:** English only.
- **Database naming:** Use clear, meaningful business names.
- **Gold layer:** Use `dim_`, `fact_`, and `vw_` prefixes where applicable.
- **Python naming:** Follow standard `snake_case` conventions.
- **Avoid:** SQL reserved words, unclear abbreviations, and unnecessary special characters.
- Keep names consistent across SQL Server and Python orchestration.

---

# 2. Database Schema Naming

The warehouse follows a Medallion Architecture.

| Layer | Schema | Purpose |
|---|---|---|
| Bronze | `bronze` | Raw ingested market data |
| Silver | `silver` | Cleaned and standardized data |
| Gold | `gold` | Business-ready dimensional model |

**Pattern:** `<layer>`

Examples:

- `bronze`
- `silver`
- `gold`

---

# 3. Table Naming Conventions

## Bronze Tables

Bronze tables store raw data received from the market-data API.

**Pattern:**

`<descriptive_table_name>`

Bronze names should clearly represent the raw source data.

## Silver Tables

Silver tables contain cleaned, standardized and transformed data.

**Pattern:**

`<business_entity>`

Example used in this project:

- `stock_price`

## Gold Tables

Gold uses a **star schema**.

### Dimension Tables

**Pattern:**

`dim_<entity>`

Examples:

- `dim_company`
- `dim_market`
- `dim_date`

### Fact Tables

**Pattern:**

`fact_<business_process>`

Example:

- `fact_stock_price`

| Pattern | Meaning | Example |
|---|---|---|
| `dim_` | Dimension table | `dim_company` |
| `fact_` | Fact table | `fact_stock_price` |

---

# 4. Column Naming Conventions

Use lowercase `snake_case` for Gold-layer columns.

Examples:

- `company_key`
- `market_key`
- `date_key`
- `stock_price_key`
- `open_price`
- `high_price`
- `low_price`
- `close_price`
- `daily_return`
- `full_date`

## Primary Keys

Surrogate keys use:

`<entity>_key`

Examples:

- `company_key`
- `market_key`
- `date_key`

The fact table's technical primary key follows:

`stock_price_key`

## Foreign Keys

Foreign keys use the same name as the referenced dimension key:

- `company_key`
- `market_key`
- `date_key`

## Measures

Use descriptive business names.

Examples:

- `open_price`
- `close_price`
- `volume`
- `daily_return`

---

# 5. View Naming Conventions

Gold analytical views use the `vw_` prefix.

**Pattern:**

`vw_<business_purpose>`

Examples:

- `vw_stock_daily_performance`
- `vw_company_performance`
- `vw_market_performance`

| Prefix | Meaning | Example |
|---|---|---|
| `vw_` | Analytical view | `vw_company_performance` |

Views should describe the business result they provide rather than the underlying implementation.

---

# 6. Stored Procedure Naming Conventions

Gold loading procedures use:

`usp_load_<object_or_layer>`

Examples:

- `usp_load_dim_company`
- `usp_load_dim_market`
- `usp_load_dim_date`
- `usp_load_fact_stock_price`
- `usp_load_all`

Data-quality procedure:

`usp_run_data_quality_checks`

The `usp_` prefix identifies user-defined stored procedures.

---

# 7. Constraint Naming Conventions

Use descriptive constraint names with the layer and object.

### Primary Key

**Pattern:**

`PK_<schema>_<table>`

Example:

`PK_gold_dim_company`

### Unique Constraint

**Pattern:**

`UQ_<schema>_<table>_<column>`

Examples:

- `UQ_gold_dim_company_symbol`
- `UQ_gold_dim_market_exchange`
- `UQ_gold_dim_date_full_date`

### Foreign Key

**Pattern:**

`FK_<table>_<referenced_table>`

Examples:

- `FK_fact_stock_price_company`
- `FK_fact_stock_price_market`
- `FK_fact_stock_price_date`

---

# 8. Python File Naming Conventions

Python files use lowercase `snake_case`.

Examples:

- `main.py`
- `alpha_vantage.py`
- `bronze_loader.py`
- `warehouse_transform.py`
- `sql_server.py`
- `daily_validation.py`

Use names that describe the responsibility of the module.

---

# 9. Python Naming Conventions

Follow standard Python `snake_case` naming.

### Functions

**Pattern:**

`verb_noun()`

Examples:

- `fetch_stock_data()`
- `load_bronze()`
- `run_gold_load()`
- `run_data_quality_checks()`

### Variables

Examples:

- `ingestion_id`
- `records_received`
- `stock_data`
- `bronze_inserted`
- `validation_results`

### Constants

Use uppercase with underscores when applicable.

Examples:

- `API_URL`
- `SYMBOLS`
- `BATCH_SIZE`

---

# 10. SQL Script Naming Conventions

SQL scripts should use lowercase `snake_case` and describe their purpose.

Examples:

- `create_database.sql`
- `create_schemas.sql`
- `create_bronze_tables.sql`
- `create_silver_tables.sql`
- `create_gold_tables.sql`
- `gold_load_procedures.sql`
- `data_quality_checks.sql`

---

# 11. Documentation Naming Conventions

Markdown documentation uses lowercase `snake_case`.

Examples:

- `data_catalog.md`
- `naming_conventions.md`
- `architecture.md`
- `data_quality.md`

The main repository documentation should remain:

- `README.md`

---

# 12. Summary

| Object | Convention | Example |
|---|---|---|
| Schema | Layer name | `bronze` |
| Bronze table | Descriptive raw-data name | `stock_price` |
| Silver table | Business entity | `stock_price` |
| Gold dimension | `dim_<entity>` | `dim_company` |
| Gold fact | `fact_<process>` | `fact_stock_price` |
| Gold view | `vw_<purpose>` | `vw_company_performance` |
| Primary key | `<entity>_key` | `company_key` |
| Foreign key | `<entity>_key` | `market_key` |
| SQL PK constraint | `PK_<schema>_<table>` | `PK_gold_dim_company` |
| SQL UQ constraint | `UQ_<schema>_<table>_<column>` | `UQ_gold_dim_company_symbol` |
| SQL FK constraint | `FK_<table>_<reference>` | `FK_fact_stock_price_company` |
| Stored procedure | `usp_<action>_<object>` | `usp_load_dim_company` |
| Python file | `snake_case.py` | `bronze_loader.py` |
| Python function | `snake_case()` | `fetch_stock_data()` |
| Documentation | `snake_case.md` | `data_catalog.md` |

---

## Naming Principle

**Names should be consistent, descriptive, and immediately understandable to another data engineer or analyst reviewing the warehouse.**
