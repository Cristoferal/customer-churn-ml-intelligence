
from pathlib import Path

import pandas as pd
import pyodbc

# ==========================================
# 1. Project configuration
# ==========================================

project_root = Path(__file__).resolve().parent.parent
raw_path = project_root / "data" / "raw"

connection_string = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=CustomerChurnDB;"
    "Trusted_Connection=yes;"
)

# Source files and destination tables
datasets = [
    (
        "telecom_customer_churn.csv",
        "stg.CustomerChurn",
        "utf-8-sig",
        7043
    ),
    (
        "telecom_zipcode_population.csv",
        "stg.ZipCodePopulation",
        "utf-8-sig",
        1671
    ),
    (
        "telecom_data_dictionary.csv",
        "stg.DataDictionary",
        "cp1252",
        40
    )
]

# ==========================================
# 2. Connect to SQL Server
# ==========================================

connection = pyodbc.connect(
    connection_string,
    timeout=10,
    autocommit=False
)

try:
    cursor = connection.cursor()

    # ======================================
    # 3. Load datasets
    # ======================================

    for filename, table, encoding, expected_rows in datasets:

        file_path = raw_path / filename

        # Read all columns as text
        df = pd.read_csv(
            file_path,
            encoding=encoding,
            dtype=str,
            keep_default_na=False,
            na_values=[""]
        )

        print(f"\nProcessing: {filename}")

        if len(df) != expected_rows:
            raise ValueError(
                f"Unexpected row count: {filename}"
            )

        # Validate SQL table column structure
        cursor.execute(f"SELECT TOP (0) * FROM {table}")

        sql_columns = [
            column[0] for column in cursor.description
        ]

        if list(df.columns) != sql_columns:
            raise ValueError(
                f"Column mismatch in {table}"
            )

        # Prevent accidental duplicate loads
        cursor.execute(
            f"SELECT COUNT_BIG(*) FROM {table}"
        )

        existing_rows = cursor.fetchone()[0]

        if existing_rows != 0:
            raise RuntimeError(
                f"{table} is not empty. Load cancelled."
            )

        # Build parameterized INSERT statement
        columns = ", ".join(
            "[" + col.replace("]", "]]") + "]"
            for col in df.columns
        )

        placeholders = ", ".join(
            ["?"] * len(df.columns)
        )

        insert_query = (
            f"INSERT INTO {table} ({columns}) "
            f"VALUES ({placeholders})"
        )

        # Convert missing values to SQL NULL
        records = [
            tuple(
                None if pd.isna(value) else str(value)
                for value in row
            )
            for row in df.itertuples(
                index=False,
                name=None
            )
        ]

        # Insert records
        cursor.fast_executemany = True
        cursor.executemany(insert_query, records)

        # Validate inserted rows
        cursor.execute(
            f"SELECT COUNT_BIG(*) FROM {table}"
        )

        inserted_rows = cursor.fetchone()[0]

        if inserted_rows != expected_rows:
            raise ValueError(
                f"Row count mismatch in {table}"
            )

        print(f"Validated: {inserted_rows} rows")

    # Save all inserts together
    connection.commit()

    print("\nAll staging tables loaded successfully!")

except Exception:
    connection.rollback()
    print("\nError detected. Transaction rolled back.")
    raise

finally:
    connection.close()
