# Pre-commit Hooks Setup Guide

This document explains how to set up pre-commit hooks for the repository

## Prerequisites

- Python 3.6 or higher
- Git

## Installation Steps

1. Install pre-commit:

```bash
pip install pre-commit
```

2. Install the pre-commit hooks:

```bash
pre-commit install
```

## What the Hooks Do

The pre-commit configuration includes:

- **RoboCop Linter**: Checks Robot Framework files for issues and best practices
- **RoboCop Formatter**: Automatically formats Robot Framework files

On every commit, these hooks will run. You dont need to manually trigger.

## Manual Execution

You can also manually run the pre-commit hooks on all files:

```bash
pre-commit run --all-files
```

Or on specific files:

```bash
pre-commit run --files tests/web/your_file.robot
```

## Troubleshooting

If you encounter issues:

1. Update pre-commit to the latest version:
   ```bash
   pip install --upgrade pre-commit
   ```

2. Update the hooks:
   ```bash
   pre-commit autoupdate
   ```

3. Uninstall and reinstall the hooks:
   ```bash
   pre-commit uninstall
   pre-commit install
   ```
