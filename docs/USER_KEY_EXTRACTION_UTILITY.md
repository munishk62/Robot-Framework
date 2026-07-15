# User Key Extraction Utility

## Overview

The `extract_user_keys.py` utility is designed to extract unique user_key values from Robot Framework test files. It specifically looks for the `Login And Launch WFM Web App` keyword calls with `user_key` parameters and extracts all unique user identifiers used across your test suite.

## Location

```
dev_utils/extract_user_keys.py
```

## Usage

### Basic Commands

```bash
# Extract from l2_suite directory (most common use case)
python dev_utils/extract_user_keys.py --directory tests/web/l2_suite

# Extract from a single file
python dev_utils/extract_user_keys.py --file tests/web/l2_suite/ess/wfm_83_2_ess.robot

# Quick list of unique user keys only
python dev_utils/extract_user_keys.py --directory tests/web/l2_suite --quiet
```

### Output Options

```bash
# Save to text file
python dev_utils/extract_user_keys.py --directory tests/web/l2_suite --output user_keys.txt

# Output as JSON (console)
python dev_utils/extract_user_keys.py --directory tests/web/l2_suite --format json

# Save as JSON file
python dev_utils/extract_user_keys.py --directory tests/web/l2_suite --format json --output user_keys.json
```

## Output Formats

### Summary Format (Default)
Shows detailed breakdown including:
- Total files scanned
- Total occurrences
- List of unique user_keys
- File-by-file breakdown with line numbers

### Quiet Mode
Shows only the unique user_keys, one per line (useful for scripting):
```
ESS1_STORE1
ESS1_STORE5
SM1_STORE1
SM_STORE2
SM_STORE8
SM_STORE9
SYSADMIN
```

### JSON Format
Provides structured data suitable for further processing:
```json
{
  "summary": {
    "unique_user_keys": [
      "ESS1_STORE1",
      "ESS1_STORE5",
      "SM1_STORE1",
      "SM_STORE2",
      "SM_STORE8",
      "SM_STORE9",
      "SYSADMIN"
    ],
    "total_files": 43,
    "total_occurrences": 48
  }
}
```

## Command Line Options

| Option | Description |
|--------|-------------|
| `--directory`, `-d` | Directory to scan for .robot files (recursive) |
| `--file`, `-f` | Single .robot file to process |
| `--output`, `-o` | Output file path (default: print to console) |
| `--format` | Output format: `text`, `json`, or `summary` (default) |
| `--quiet`, `-q` | Suppress detailed output, show only unique user_keys |

## Pattern Recognition

The utility uses a regex pattern to identify user_key values:
```regex
Login\s+And\s+Launch\s+WFM\s+Web\s+App.*?user_key=(\w+)
```

This pattern matches:
- `Login And Launch WFM Web App` (case-insensitive, with flexible whitespace)
- Followed by any arguments
- Ending with `user_key=<USERNAME>` where USERNAME is captured

## Example Output

```
============================================================
USER KEY EXTRACTION SUMMARY
============================================================
Files scanned: 43
Total occurrences: 48
Unique user_keys: 7

Unique user_keys found:
  - ESS1_STORE1
  - ESS1_STORE5
  - SM1_STORE1
  - SM_STORE2
  - SM_STORE8
  - SM_STORE9
  - SYSADMIN

============================================================
DETAILED BREAKDOWN BY FILE
============================================================

File: l2_suite\ess\shift_trade_board\wfm_87_1_ess.robot
  Occurrences: 1
    Line  26: ESS1_STORE1 -> Login And Launch WFM Web App    user_key=ESS1_STORE1
```

## Use Cases

1. **Environment Planning**: Identify all user accounts needed for test execution
2. **User Management**: Understand which user roles are being tested
3. **Test Dependencies**: See which tests depend on specific user accounts
4. **Documentation**: Generate lists of test users for environment setup guides
5. **Data Analysis**: Analyze user distribution across different test modules

## Integration with CI/CD

The utility can be integrated into build pipelines to:
- Validate that all required test users are configured in target environments
- Generate user lists for environment setup documentation
- Track changes in user requirements over time

## Error Handling

The utility handles various scenarios gracefully:
- Files with encoding issues (warns and continues)
- Missing files or directories (clear error messages)
- No matches found (informative message)
- Permission errors (warns and continues with other files)

## Performance

- Efficiently processes large numbers of files
- Memory usage scales linearly with number of files
- Typical performance: ~100 files/second on modern hardware
