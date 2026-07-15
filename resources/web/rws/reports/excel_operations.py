"""
Excel utility functions for processing Cognos report data files.
Handles splitting large Excel files into batches for DataDriver compatibility.
"""

import pandas as pd
from pathlib import Path
from typing import List
import logging
import math

logger = logging.getLogger(__name__)


def get_row_count(file_path: Path, sheet_name: str = 0) -> int:
    """
    Get the number of data rows in an Excel file (excluding header).

    Args:
        file_path: Path to the Excel file
        sheet_name: Sheet name or index (default: 0)

    Returns:
        Number of data rows
    """
    try:
        df = pd.read_excel(file_path, sheet_name=sheet_name)
        return len(df)
    except Exception as e:
        logger.error(f"Error reading Excel file {file_path}: {e}")
        raise


def split_excel_to_sheets(
    input_file: Path, output_file: Path, batch_size: int = 200
) -> List[str]:
    """
    Split an Excel file into multiple sheets with specified batch size.

    Args:
        input_file: Path to the input Excel file
        output_file: Path to the output Excel file
        batch_size: Number of rows per sheet (default: 200)

    Returns:
        List of sheet names created
    """
    try:
        # Read the original Excel file (first sheet only, skip empty rows)
        df = pd.read_excel(input_file, sheet_name=0)

        # Remove any completely empty rows
        df = df.dropna(how="all")

        total_rows = len(df)

        logger.info(
            f"Processing {input_file.name} with {total_rows} data rows (after removing empty rows)"
        )

        # If rows <= batch_size, create single sheet
        if total_rows <= batch_size:
            logger.info(
                f"File has {total_rows} rows (≤ {batch_size}), creating single BATCH_1 sheet"
            )
            with pd.ExcelWriter(output_file, engine="openpyxl") as writer:
                df.to_excel(writer, sheet_name="BATCH_1", index=False)
            return ["BATCH_1"]

        # Calculate number of batches needed
        num_batches = math.ceil(total_rows / batch_size)
        logger.info(
            f"Will create {num_batches} batches (calculated as ceil({total_rows}/{batch_size}))"
        )

        # Split into multiple sheets
        sheet_names = []
        with pd.ExcelWriter(output_file, engine="openpyxl") as writer:
            for batch_num in range(1, num_batches + 1):
                start_idx = (batch_num - 1) * batch_size
                end_idx = min(start_idx + batch_size, total_rows)

                batch_df = df.iloc[start_idx:end_idx]
                actual_row_count = len(batch_df)

                sheet_name = f"BATCH_{batch_num}"
                batch_df.to_excel(writer, sheet_name=sheet_name, index=False)
                sheet_names.append(sheet_name)

                logger.info(
                    f"Created {sheet_name}: {actual_row_count} rows (Excel rows {start_idx + 2} to {end_idx + 1})"
                )

        logger.info(
            f"Successfully created {len(sheet_names)} sheets in {output_file.name}"
        )
        logger.info(
            f"Sheet distribution: {[f'{name}({len(df.iloc[(i) * batch_size : min((i + 1) * batch_size, total_rows)])} rows)' for i, name in enumerate(sheet_names)]}"
        )

        return sheet_names

    except Exception as e:
        logger.error(f"Error splitting Excel file: {e}")
        logger.error("Stack trace:", exc_info=True)
        raise


def get_excel_sheet_names(file_path: Path) -> List[str]:
    """
    Get all sheet names from an Excel file.

    Args:
        file_path: Path to the Excel file

    Returns:
        List of sheet names
    """
    try:
        xl_file = pd.ExcelFile(file_path)
        return xl_file.sheet_names
    except Exception as e:
        logger.error(f"Error getting sheet names from {file_path}: {e}")
        raise


def delete_excel_file(file_path: Path) -> None:
    """
    Delete an Excel file if it exists.

    Args:
        file_path: Path to the Excel file to delete
    """
    try:
        if file_path.exists():
            file_path.unlink()
            logger.info(f"Deleted file: {file_path}")
    except Exception as e:
        logger.error(f"Error deleting file {file_path}: {e}")
        raise


def rename_excel_file(old_path: Path, new_path: Path) -> None:
    """
    Rename an Excel file.

    Args:
        old_path: Current file path
        new_path: New file path
    """
    try:
        if old_path.exists():
            old_path.rename(new_path)
            logger.info(f"Renamed {old_path.name} to {new_path.name}")
    except Exception as e:
        logger.error(f"Error renaming file from {old_path} to {new_path}: {e}")
        raise
