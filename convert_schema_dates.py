#!/usr/bin/env python3
"""
Convert CREATE_SCHEMA_invest_portfolio.txt to fix date format issues.

This script:
1. Reads the original CREATE_SCHEMA_invest_portfolio.txt file
2. Replaces all INSERT statements to use STR_TO_DATE() for proper date parsing
3. Outputs corrected SQL to CORRECTED_SCHEMA_FULL.sql

Usage:
    python3 convert_schema_dates.py /path/to/CREATE_SCHEMA_invest_portfolio.txt
"""

import re
import sys
from pathlib import Path


def convert_insert_statement(line):
    """
    Convert an INSERT statement to use STR_TO_DATE() for date conversion.

    Before: INSERT INTO pricing_daily_new(date,ticker,price_type,value) VALUES ('12-06-26','IXN','Open',138.5);
    After:  INSERT INTO pricing_daily(date,ticker,price_type,value) VALUES (STR_TO_DATE('12-06-26','%d-%m-%y'),'IXN','Open',138.5);
    """

    # Match the pattern: VALUES ('DD-MM-YY','...')
    # Replace pricing_daily_new with pricing_daily
    # Replace ('DD-MM-YY', with (STR_TO_DATE('DD-MM-YY','%d-%m-%y'),

    pattern = r"VALUES \('([0-9]{2}-[0-9]{2}-[0-9]{2})'"
    replacement = r"VALUES (STR_TO_DATE('\1','%d-%m-%y')"

    line = line.replace('pricing_daily_new', 'pricing_daily')
    line = re.sub(pattern, replacement, line)

    return line


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 convert_schema_dates.py <path_to_CREATE_SCHEMA_invest_portfolio.txt>")
        sys.exit(1)

    input_file = Path(sys.argv[1])
    if not input_file.exists():
        print(f"Error: File not found: {input_file}")
        sys.exit(1)

    output_file = input_file.parent / "CORRECTED_SCHEMA_FULL.sql"

    print(f"Converting {input_file.name}...")
    print(f"Output will be saved to: {output_file.name}")

    insert_count = 0
    converted_count = 0

    with open(input_file, 'r') as f_in, open(output_file, 'w') as f_out:
        # Write header
        f_out.write("-- ===================================\n")
        f_out.write("-- CORRECTED SCHEMA - AUTO-GENERATED\n")
        f_out.write("-- Date format issue fixed: DD-MM-YY properly converted with STR_TO_DATE()\n")
        f_out.write("-- ===================================\n\n")

        for line_num, line in enumerate(f_in, 1):
            # Process INSERT statements
            if 'INSERT INTO pricing_daily' in line:
                insert_count += 1

                # Skip table creation for pricing_daily_new, use pricing_daily
                if 'CREATE TABLE' in line:
                    line = line.replace('pricing_daily_new', 'pricing_daily')
                    f_out.write(line)
                    continue

                # Convert INSERT statements
                if 'VALUES' in line and "'" in line and '-' in line:
                    converted_line = convert_insert_statement(line)
                    f_out.write(converted_line)
                    converted_count += 1
                else:
                    f_out.write(line)
            else:
                f_out.write(line)

    print(f"\nConversion complete!")
    print(f"  - Total INSERT statements processed: {insert_count}")
    print(f"  - Successfully converted: {converted_count}")
    print(f"  - Output file: {output_file.name}")
    print(f"\nNext steps:")
    print(f"  1. Review the output file: {output_file.name}")
    print(f"  2. Run it in MySQL: mysql -u root -p < {output_file.name}")
    print(f"  3. Verify with:")
    print(f"     SELECT MIN(date), MAX(date), COUNT(DISTINCT date) FROM pricing_daily;")


if __name__ == '__main__':
    main()
