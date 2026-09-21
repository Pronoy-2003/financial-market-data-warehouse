"""
File: warehouse_validation.py

Purpose:
Executes the warehouse data-quality validation procedure and
displays detailed check results in the terminal, including actual,
expected, failed-row counts, and overall PASS/FAIL status.
"""


from database import get_sql_connection


def run_warehouse_validation():
    """
    Execute the SQL Server warehouse data quality procedure
    and display detailed validation results in the terminal.

    SQL procedure executed:
        gold.usp_run_data_quality_checks

    Expected result columns:
        check_id
        check_name
        actual_value
        expected_value
        failed_rows
        status
    """

    connection = get_sql_connection()

    try:
        cursor = connection.cursor()

        print("\n" + "=" * 80)
        print("WAREHOUSE DATA QUALITY VALIDATION")
        print("=" * 80)

        print("\nExecuting SQL data quality procedure...")
        print("Procedure: gold.usp_run_data_quality_checks")

        # ------------------------------------------------------
        # Execute Data Quality Stored Procedure
        # ------------------------------------------------------

        cursor.execute(
            "EXEC gold.usp_run_data_quality_checks;"
        )

        # ------------------------------------------------------
        # Find the result set returned by the procedure
        # ------------------------------------------------------

        result_rows = None

        while True:

            if cursor.description is not None:
                columns = [
                    column[0]
                    for column in cursor.description
                ]

                expected_columns = {
                    "check_id",
                    "check_name",
                    "actual_value",
                    "expected_value",
                    "failed_rows",
                    "status"
                }

                if expected_columns.issubset(
                    set(columns)
                ):
                    result_rows = cursor.fetchall()
                    break

            if not cursor.nextset():
                break

        if result_rows is None:
            raise RuntimeError(
                "Data quality procedure did not return "
                "the expected result set."
            )

        # ------------------------------------------------------
        # Display column header
        # ------------------------------------------------------

        print("\n" + "-" * 110)

        print(
            f"{'ID':<5}"
            f"{'CHECK NAME':<35}"
            f"{'ACTUAL':<15}"
            f"{'EXPECTED':<15}"
            f"{'FAILED':<10}"
            f"{'STATUS':<10}"
        )

        print("-" * 110)

        # ------------------------------------------------------
        # Process validation results
        # ------------------------------------------------------

        total_checks = len(result_rows)
        passed_checks = 0
        failed_checks = 0

        for row in result_rows:

            check_id = row.check_id
            check_name = row.check_name
            actual_value = row.actual_value
            expected_value = row.expected_value
            failed_rows = row.failed_rows
            status = row.status

            # Convert None into readable terminal value
            actual_display = (
                "-"
                if actual_value is None
                else str(actual_value)
            )

            expected_display = (
                "-"
                if expected_value is None
                else str(expected_value)
            )

            failed_display = (
                0
                if failed_rows is None
                else failed_rows
            )

            # Count PASS / FAIL
            if str(status).upper() == "PASS":
                passed_checks += 1
            else:
                failed_checks += 1

            # --------------------------------------------------
            # Print detailed result
            # --------------------------------------------------

            print(
                f"{check_id:<5}"
                f"{str(check_name)[:33]:<35}"
                f"{actual_display:<15}"
                f"{expected_display:<15}"
                f"{failed_display:<10}"
                f"{status:<10}"
            )

        print("-" * 110)

        # ------------------------------------------------------
        # Validation Summary
        # ------------------------------------------------------

        print("\nVALIDATION SUMMARY")
        print("-" * 40)

        print(f"Total checks : {total_checks}")
        print(f"Passed checks: {passed_checks}")
        print(f"Failed checks: {failed_checks}")

        # ------------------------------------------------------
        # Determine overall status
        # ------------------------------------------------------

        if failed_checks == 0:

            print("\nOverall warehouse validation: PASS")

            return True

        else:

            print("\nOverall warehouse validation: FAIL")

            return False

    except Exception as error:

        print("\nWarehouse validation failed.")
        print(f"Error: {error}")

        raise

    finally:

        connection.close()