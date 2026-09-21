# Data Quality

## Overview

Data quality validation is the final control stage of the Financial Market Data Warehouse pipeline.

After the Gold layer is loaded, Python executes:

```text
gold.usp_run_data_quality_checks
```

The procedure returns detailed results that Python displays directly in the terminal, including actual values, expected values, failed rows, and status. fileciteturn18file10L5-L18

## Validation Flow

```text
Bronze
   ↓
Silver
   ↓
Gold
   ↓
Data Quality Procedure
   ↓
16 Validation Checks
   ↓
PASS / FAIL
```

If all checks pass, the pipeline completes successfully. If one or more checks fail, the pipeline is marked as failed.

## Validation Checks

The warehouse validation contains **16 checks** grouped into four areas.

### 1. Record & Dimension Counts

| Check | Purpose |
|---|---|
| Bronze Record Count | Verifies Bronze data volume |
| Silver Record Count | Verifies Silver data volume |
| Gold Fact Record Count | Verifies Gold fact data volume |
| Company Dimension Count | Verifies company dimension population |
| Market Dimension Count | Verifies market dimension population |
| Date Dimension Count | Verifies date dimension population |

### 2. Duplicate & Key Integrity

| Check | Purpose |
|---|---|
| Duplicate Gold Fact Records | Detects duplicate fact records |
| NULL Company Keys | Detects missing company foreign keys |
| NULL Market Keys | Detects missing market foreign keys |
| NULL Date Keys | Detects missing date foreign keys |
| Orphan Company Keys | Detects invalid company references |
| Orphan Market Keys | Detects invalid market references |
| Orphan Date Keys | Detects invalid date references |

### 3. Financial Data Validation

| Check | Purpose |
|---|---|
| Invalid OHLC Records | Detects invalid Open/High/Low/Close relationships |
| Invalid Volume Records | Detects invalid trading-volume values |
| NULL Financial Measures | Detects missing financial measures |

## Validation Output

Python retrieves the result set returned by the SQL procedure and expects these fields:

```text
check_id
check_name
actual_value
expected_value
failed_rows
status
```

The validation process then displays each check in the terminal and calculates:

```text
Total checks
Passed checks
Failed checks
Overall warehouse validation
```

fileciteturn18file10L45-L70 fileciteturn18file10L100-L110

## Example Terminal Output

```text
--------------------------------------------------------------------------------
ID   CHECK NAME                         ACTUAL    EXPECTED    FAILED    STATUS
--------------------------------------------------------------------------------
1    Bronze Record Count                1020      -           0         PASS
2    Silver Record Count                1020      -           0         PASS
3    Gold Fact Record Count             1020      -           0         PASS
...
16   NULL Financial Measures            0         0           0         PASS
--------------------------------------------------------------------------------

VALIDATION SUMMARY
----------------------------------------
Total checks : 16
Passed checks: 16
Failed checks: 0

Overall warehouse validation: PASS
```

The implementation intentionally displays the **actual data values**, rather than only showing a generic PASS/FAIL result. fileciteturn18file10L83-L94 fileciteturn18file10L142-L148

## Quality Gate

The validation result is used as a pipeline gate.

```text
Failed checks = 0
       ↓
     PASS
       ↓
Pipeline Completed
```

```text
Failed checks > 0
       ↓
     FAIL
       ↓
Pipeline Failed
```

The validation function returns `True` when there are no failed checks and `False` otherwise. fileciteturn18file10L157-L178

## Failure Handling

When validation fails, the pipeline raises:

```text
Warehouse data quality validation failed.
```

The pipeline therefore does not silently continue after a failed warehouse validation.

## Data Quality Design

| Principle | Implementation |
|---|---|
| Automated | Checks execute through a SQL procedure |
| Orchestrated | Python executes the validation |
| Detailed | Actual and expected values are displayed |
| Traceable | Individual checks have IDs and names |
| Fail-safe | Failed validation causes pipeline failure |
| Repeatable | Checks can be executed on every pipeline run |

## Result

Data quality validation provides a final control between **warehouse processing** and a **successful pipeline run**, helping ensure that the Bronze, Silver, and Gold layers maintain the expected record volumes, relationships, and financial-data integrity.
