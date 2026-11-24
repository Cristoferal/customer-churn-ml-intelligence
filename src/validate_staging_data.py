
from pathlib import Path
from collections import Counter
import csv
import pyodbc

# ==========================================
# 1. Configuration
# ==========================================

project_root = Path(__file__).resolve().parent.parent
raw_path = project_root / "data" / "raw"

connection_string = (
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost;"
    "DATABASE=CustomerChurnDB;"
    "Trusted_Connection=yes;"
)

datasets = [
    (
        "telecom_customer_churn.csv",
        "stg.CustomerChurn",
        "utf-8-sig"
    ),
    (
        "telecom_zipcode_population.csv",
        "stg.ZipCodePopulation",
        "utf-8-sig"
    ),
    (
        "telecom_data_dictionary.csv",
        "stg.DataDictionary",
        "cp1252"
    )
]

# ==========================================
# 2. Read original CSV as text
# ==========================================

def read_csv_records(file_path, encoding):

    with open(
        file_path,
        "r",
        encoding=encoding,
        newline=""
    ) as file:

        reader = csv.reader(file)
        columns = next(reader)

        records = [
            tuple(
                None if value == "" else value
                for value in row
            )
            for row in reader
        ]

    return columns, records


# ==========================================
# 3. Compare CSV and SQL Server
# ==========================================

connection = pyodbc.connect(
    connection_string,
    timeout=10
)

all_valid = True

try:
    cursor = connection.cursor()

    for filename, table, encoding in datasets:

        print(f"\nValidating: {table}")

        csv_columns, csv_records = read_csv_records(
            raw_path / filename,
            encoding
        )

        cursor.execute(f"SELECT * FROM {table}")

        sql_columns = [
            col[0] for col in cursor.description
        ]

        sql_records = [
            tuple(row)
            for row in cursor.fetchall()
        ]

        # Validate column structure
        columns_match = csv_columns == sql_columns

        # Compare complete rows without relying
        # on their physical order
        csv_counter = Counter(csv_records)
        sql_counter = Counter(sql_records)

        missing_in_sql = sum(
            (csv_counter - sql_counter).values()
        )

        extra_in_sql = sum(
            (sql_counter - csv_counter).values()
        )

        valid = (
            columns_match
            and missing_in_sql == 0
            and extra_in_sql == 0
        )

        print("CSV rows:", len(csv_records))
        print("SQL rows:", len(sql_records))
        print("Columns match:", columns_match)
        print("Missing in SQL:", missing_in_sql)
        print("Extra in SQL:", extra_in_sql)
        print("Validation passed:", valid)

        if not valid:
            all_valid = False

finally:
    connection.close()

# ==========================================
# 4. Final result
# ==========================================

if all_valid:
    print("\nSUCCESS: All datasets match exactly!")
else:
    raise RuntimeError(
        "Data validation failed. Review differences."
    )
