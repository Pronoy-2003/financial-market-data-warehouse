"""
File: main.py

Purpose:
Main orchestration script for the Financial Market Data Warehouse.
Runs extraction, Bronze loading, Silver transformation, Gold loading,
data-quality validation, and ingestion-status tracking.
"""


import uuid

from ingestion import ingest_stock_data

from bronze_loader import (
    start_ingestion_log,
    update_ingestion_log,
    load_to_bronze
)

from silver_loader import load_to_silver
from gold_loader import load_to_gold
from warehouse_validation import run_warehouse_validation


def main():

    # ----------------------------------------------------------
    # CREATE INGESTION ID
    # ----------------------------------------------------------

    ingestion_id = str(uuid.uuid4())

    records_received = 0

    inserted_count = 0
    skipped_count = 0

    print("=" * 60)
    print("STARTING FINANCIAL MARKET DATA PIPELINE")
    print("=" * 60)

    print(f"Ingestion ID: {ingestion_id}")

    # ----------------------------------------------------------
    # START INGESTION LOG
    # ----------------------------------------------------------

    start_ingestion_log(ingestion_id)

    try:

        # ======================================================
        # 1. EXTRACT
        # ======================================================

        print("\n" + "=" * 60)
        print("STEP 1 - DATA EXTRACTION")
        print("=" * 60)

        df = ingest_stock_data()

        records_received = len(df)

        print("\nExtraction completed.")
        print(
            f"Total records retrieved: "
            f"{records_received}"
        )

        # ======================================================
        # 2. BRONZE
        # ======================================================

        print("\n" + "=" * 60)
        print("STEP 2 - BRONZE LOAD")
        print("=" * 60)

        inserted_count, skipped_count = load_to_bronze(
            df,
            ingestion_id
        )

        print("\nBronze load completed.")

        print(
            f"New records inserted: "
            f"{inserted_count}"
        )

        print(
            f"Existing records skipped: "
            f"{skipped_count}"
        )

        # ======================================================
        # 3. SILVER
        # ======================================================

        print("\n" + "=" * 60)
        print("STEP 3 - SILVER TRANSFORMATION")
        print("=" * 60)

        load_to_silver()

        # ======================================================
        # 4. GOLD
        # ======================================================

        print("\n" + "=" * 60)
        print("STEP 4 - GOLD LAYER LOAD")
        print("=" * 60)

        load_to_gold()

        # ======================================================
        # 5. DATA QUALITY VALIDATION
        # ======================================================

        print("\n" + "=" * 60)
        print("STEP 5 - WAREHOUSE DATA QUALITY")
        print("=" * 60)

        validation_passed = run_warehouse_validation()

        # ------------------------------------------------------
        # Stop pipeline if validation fails
        # ------------------------------------------------------

        if not validation_passed:

            raise RuntimeError(
                "Warehouse data quality validation failed."
            )

        # ======================================================
        # 6. UPDATE INGESTION LOG
        # ======================================================

        update_ingestion_log(
            ingestion_id=ingestion_id,
            status="SUCCESS",
            records_received=records_received
        )

        # ======================================================
        # FINAL SUCCESS SUMMARY
        # ======================================================

        print("\n")
        print("=" * 60)
        print("FINANCIAL MARKET DATA PIPELINE COMPLETED")
        print("=" * 60)

        print(
            f"Ingestion ID           : "
            f"{ingestion_id}"
        )

        print(
            f"Records received       : "
            f"{records_received}"
        )

        print(
            f"New Bronze records     : "
            f"{inserted_count}"
        )

        print(
            f"Existing Bronze skipped: "
            f"{skipped_count}"
        )

        print(
            "Silver transformation  : SUCCESS"
        )

        print(
            "Gold transformation    : SUCCESS"
        )

        print(
            "Data quality validation: PASS"
        )

        print("=" * 60)

    except Exception as error:

        # ======================================================
        # UPDATE INGESTION LOG AS FAILED
        # ======================================================

        update_ingestion_log(
            ingestion_id=ingestion_id,
            status="FAILED",
            records_received=records_received,
            error_message=str(error)
        )

        # ======================================================
        # FAILURE SUMMARY
        # ======================================================

        print("\n")
        print("=" * 60)
        print("FINANCIAL MARKET DATA PIPELINE FAILED")
        print("=" * 60)

        print(
            f"Ingestion ID: "
            f"{ingestion_id}"
        )

        print(
            f"Records received: "
            f"{records_received}"
        )

        print(
            f"Error: "
            f"{error}"
        )

        print("=" * 60)

        raise


if __name__ == "__main__":
    main()