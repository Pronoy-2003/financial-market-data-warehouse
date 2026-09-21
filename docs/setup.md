# Setup Guide

## Overview

This guide explains how to set up and run the Financial Market Data Warehouse project locally.

## 1. Prerequisites

Install the following:

- Python 3.x
- SQL Server
- SQL Server Management Studio (SSMS)
- Git

The project also requires an Alpha Vantage API key.

## 2. Clone the Repository

```bash
git clone <repository-url>
cd financial-market-data-warehouse
```

## 3. Create a Python Virtual Environment

From the project root:

```bash
python -m venv venv
```

Activate the environment on Windows:

```bash
venv\Scripts\activate
```

## 4. Install Python Dependencies

Install the project dependencies:

```bash
pip install -r requirements.txt
```

## 5. Configure the Alpha Vantage API Key

Create a `.env` file in the project root:

```text
ALPHA_VANTAGE_API_KEY=your_api_key_here
```

The Python ingestion process reads the API key from the environment rather than hard-coding it in the source code. The ingestion module loads environment variables using `python-dotenv`. fileciteturn18file8L1-L7

Do not commit `.env` to GitHub.

## 6. Create the SQL Server Database

Create the project database in SQL Server:

```text
FinancialMarketWarehouse
```

Then execute the SQL scripts in the project in the required order:

```text
1. Database creation
2. Schema creation
3. Bronze tables
4. Silver tables
5. Gold tables
6. Gold loading procedures
7. Data quality procedure
8. Gold analytical views
```

The database connection used by the Python pipeline should point to the same SQL Server database.

## 7. Configure the SQL Server Connection

Configure the database connection according to the project's database configuration.

The Python modules obtain the SQL Server connection through the project's database connection function:

```python
get_sql_connection()
```

The connection is used by the Silver transformation and warehouse validation processes. fileciteturn18file7L1-L10 fileciteturn18file10L1-L4

## 8. Verify the Database Connection

Run the connection test:

```bash
python src/test_connection.py
```

A successful connection should display the SQL Server database name.

## 9. Run the Complete Pipeline

From the project root:

```bash
python src/main.py
```

The pipeline executes:

```text
Data Extraction
      ↓
Bronze Load
      ↓
Silver Transformation
      ↓
Gold Layer Load
      ↓
Warehouse Data Quality
      ↓
Pipeline SUCCESS / FAILURE
```

## 10. Verify the Output

A successful run displays:

```text
Extraction completed.
Bronze load completed.
Silver transformation completed successfully.
Gold layer load completed successfully.
Overall warehouse validation: PASS
FINANCIAL MARKET DATA PIPELINE COMPLETED
```

The data-quality stage displays detailed validation results rather than only a final PASS/FAIL status. fileciteturn18file10L83-L94

## 11. Troubleshooting

### API Error

Check:

- API key is present in `.env`
- API key is valid
- API request limits have not been exceeded

### SQL Server Connection Error

Check:

- SQL Server is running
- Database name is correct
- SQL Server connection configuration is correct
- Required database objects have been created

### Data Quality Failure

Review the individual validation checks printed in the terminal.

The pipeline reports:

```text
Actual
Expected
Failed rows
Status
```

This identifies which warehouse-quality check caused the failure. fileciteturn18file10L106-L110

## 12. Project Execution

The recommended execution process is:

```text
Setup Environment
       ↓
Configure API Key
       ↓
Create SQL Server Warehouse
       ↓
Run Database Scripts
       ↓
Test Connection
       ↓
Run src/main.py
       ↓
Review Pipeline Output
```

## Security Notes

- Never commit API keys.
- Keep `.env` in `.gitignore`.
- Do not store database passwords directly in source code.
- Use environment variables for sensitive credentials.
