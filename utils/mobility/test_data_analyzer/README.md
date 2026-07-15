# Test Data Analyzer - User Guide

## 📋 Overview

The Test Data Analyzer is located in `utils/mobility/test_data_analyzer/` and analyzes Robot Framework test data CSV files to:
- Track user and day usage across test cases
- Detect **duplicate days** (same user, same day used in multiple tests)
- Identify **available days** for schedule and shift trade tests
- Generate Excel reports with PW-D format (Planning Week - Day) in the `reports/` subdirectory

## 🚀 Quick Start

Navigate to the analyzer directory:
```bash
cd utils/mobility/test_data_analyzer
```

### Basic Usage (Default VARIATION1.csv)
```bash
python3 analyze_testdata.py
```

Output: `reports/user_day_usage_report.xlsx`

### Analyze Different Variation
```bash
python3 analyze_testdata.py ../../../TestData/VARIATION2.csv
```

Output: `reports/variation2_report.xlsx`

### Analyze MORRISON Data
```bash
python3 analyze_testdata.py ../../../TestData/MORRISON.csv
```

Output: `reports/morrison_report.xlsx`

## 📊 Understanding the Excel Report

The generated Excel report contains **4 columns**:

| Column | Description | Color Code |
|--------|-------------|------------|
| **User Name** | User ID (e.g., SIT-ESS-SCH-USER1) | - |
| **Days Used (PW-D with Test Cases)** | All PW-D days used with their test case IDs | - |
| **Days Available** | Free days available for new tests | Gray background |
| **Total Days Used** | Total count of days used | - |

**Note:** Duplicate days (days reused in multiple test cases) are highlighted in the console report output, not as a separate column.

### Example Row:
```
User: SIT-ESS-SCH-USER1
Days Used: PW2-D1 (TC34053), PW2-D2 (TC34054), PW3-D2 (TC34053, TC34188), ...
Days Available: PW1-D1, PW1-D2, PW1-D3, PW3-D3, PW4-D3, ...
Total Days: 44
```

## ⚠️ Duplicate Days Detection

**What are duplicate days?**
When the same user uses the same day (PW-D) in multiple test cases, it may cause conflicts if tests run in parallel.

**Where to find duplicates:**
- **Console Output**: Duplicates are shown in the terminal when you run the analyzer
- **Excel Report**: Days with multiple test cases show both test IDs in parentheses (e.g., `PW3-D2 (TC34053, TC34188)`)

**Example Console Output:**
```
SIT-ESS-SCH-USER1:
  ⚠️  PW3-D2 is reused in: TC34053, TC34188
  ⚠️  PW4-D2 is reused in: TC34054, TC34189
```

**How to fix:**
1. Check if TC34053 and TC34188 can run simultaneously
2. If yes, reassign one test to use an available day
3. Look at "Days Available" column in the Excel report
4. Update test data to use a free day
5. Re-run analyzer to verify

## 🎯 Common Use Cases

### 1. Plan a New Test Case
**Goal:** Find available days for SIT-ESS-SCH-USER1

**Steps:**
1. Run: `python3 analyze_testdata.py`
2. Open the Excel report in `reports/variation1_report.xlsx`
3. Find row for `SIT-ESS-SCH-USER1`
4. Look at **"Days Available"** column
5. Pick any day from the list

**Example:**
```
Available: PW1-D1, PW1-D2, PW1-D3, PW3-D3, PW4-D3
✅ Use PW1-D1 for your new test
```

### 2. Fix Duplicate Day Conflicts
**Goal:** Resolve conflict where PW3-D2 is used in TC34053 and TC34188

**Steps:**
1. Check console output for **"DUPLICATE DAY USAGE DETECTION"** section
2. Or look in Excel **"Days Used"** column for days showing multiple test cases: `PW3-D2 (TC34053, TC34188)`
3. Decide which test to reassign (e.g., TC34188)
4. Choose an available day from **"Days Available"** column (e.g., PW3-D3)
5. Update TC34188 test data to use PW3-D3
6. Re-run analyzer to verify no conflicts

### 3. Check Available Capacity
**Goal:** How many more tests can use SIT-ESS-SCH-USER1?

**Steps:**
1. Look at **"Days Available"** column
2. Count the available days (e.g., 17 days)
3. **Capacity = 17 more tests possible for this user**

## 📁 Required Files

### Input Files
1. **CSV File**: Test data file from project root (e.g., `../../../TestData/VARIATION1.csv`)
2. **Template Mapping**: `../../../TestData/template_mapping_shift_data/template_week_mapping.json`

### Output Files
1. **Excel Report**: `reports/<variation>_report.xlsx` (generated in analyzer directory)
2. **Console Report**: Summary printed to terminal

## 🔧 Advanced Usage

### Specify Custom Template File
```bash
python3 analyze_testdata.py ../../../TestData/VARIATION2.csv ../../../TestData/custom_template.json
```

### Specify Custom Output File
```bash
python3 analyze_testdata.py ../../../TestData/VARIATION2.csv \
  ../../../TestData/template_mapping_shift_data/template_week_mapping.json \
  reports/my_custom_report.xlsx
```

## 📝 PW-D Format Explained

**PW-D** = Planning Week - Day

- **PW1-D1**: Planning Week 1, Day 1 (first day of current week)
- **PW2-D3**: Planning Week 2, Day 3 (third day of next week)
- **PW6-D7**: Planning Week 6, Day 7 (last day of week 6)

**Calculation:**
- Based on `PLANNING_WEEK_START` from CSV file
- PW1 starts on the date specified in CSV
- Days increment from D1 (first day) to D7 (last day)

## 🔍 How It Works

### 1. Data Collection
- Reads CSV file and extracts test case data
- Identifies users mentioned in test data
- Tracks which days (PW-D format) are used by each user

### 2. Template Mapping
- Loads template mapping from JSON file
- Maps manager templates to associate users
- Example: SIT-SM-SCH-USER1 template applies to all SIT-ESS-SCH-* users

### 3. Categorization
- **Schedule Tests**: Test cases with "schedule" in description (excluding shift trade)
- **Shift Trade Tests**: Test cases with "shift trade" or "shift" in description

### 4. Duplicate Detection
- Tracks which test cases use each day for each user
- Flags days used by the same user in multiple tests
- Highlights conflicts in yellow in Excel report

### 5. Available Days Calculation
- Compares template mapping (all possible days) with used days
- Subtracts used days from template days
- Lists remaining available days for each user

## 📈 Statistics Example

From VARIATION1 analysis:
- **Total Test Cases**: 157
- **Total Data Rows**: 1,687
- **Unique Users**: 23
- **Planning Week Start**: 2025-06-08

**Most Active Users:**
- SIT-ESS-SCH-USER1: 44 days (26 schedule, 18 shift trade)
- SIT-SM-ALTWORK-USER1: 24 days
- SIT-ESS-RTA-USER1: 10 days

## 🛠️ Troubleshooting

### Issue: "openpyxl not installed"
**Solution:**
```bash
pip install openpyxl
```

### Issue: "Template file not found"
**Solution:** Ensure template file exists at:
```
../../../TestData/template_mapping_shift_data/template_week_mapping.json
```

### Issue: "CSV file not found"
**Solution:** Check file path is correct:
```bash
ls -l ../../../TestData/VARIATION1.csv
```

## 📂 Directory Structure

```Template Mapping**: `../../../TestData/template_mapping_shift_data/template_week_mapping.json`
- **Test Data Files**: Located in `../../../TestData/` (VARIATION1.csv, VARIATION2.csv, MORRISON.csv, etc.)

## 💡 Tips

1. **Run analyzer after test data changes** to verify no conflicts
2. **Check duplicate days** before running parallel tests
3. **Use available days** when planning new test cases
4. **Keep template mapping updated** for accurate availability tracking
5. **Review Excel report** in `reports/` folder for detailed analysis
6. **All reports are generated in the `reports/` subdirectory** - keeps workspace clean

## ✅ Verified Features

- ✅ PW-D format conversion working correctly
- ✅ Duplicate day detection accurate
- ✅ Schedule vs Shift Trade categorization correct
- ✅ Available days calculation verified
- ✅ Excel report formatting professional
- ✅ Template mapping applied correctly
- ✅ VARIATION1, VARIATION2, MORRISON data tested

---

**Last Updated**: January 13, 2026  
**Version**: 2.0  
**Status**: Production Ready ✅
