# Documentation Generator

This repository includes a utility to generate comprehensive documentation for all Robot Framework resource files and Python libraries. The documentation is generated using Robot Framework's libdoc tool and provides a single entry point HTML with links to all keyword documentation.

## Generate Documentation Locally

### Using the Batch File (Windows)

The easiest way to generate documentation on Windows is to use the included batch file:

```cmd
generate_docs.bat
```

This will generate documentation in the `docs/generated` directory by default.

### Options

You can customize the documentation generation with the following options:

```cmd
generate_docs.bat --output-dir=custom\path --title="Custom Title" --include-tests
```

- `--output-dir`: Specify the output directory for documentation (default: docs/generated)
- `--title`: Specify the title for the main index page (default: WFM Test Automation Documentation)
- `--include-tests`: Include test files in documentation (default: False)

### Using Python Directly

Alternatively, you can run the Python script directly:

```cmd
python generate_documentation.py --output-dir=docs/generated --title="WFM Test Automation" --include-tests
```

## Automated Documentation Generation

Documentation is automatically generated via GitHub Actions when:

1. Code is pushed to the main branch
2. A pull request targets the main branch
3. The workflow is manually triggered
4. A scheduled job runs (runs every Saturday at midnight UTC)

The generated documentation is:
1. Deployed to GitHub Pages (when pushed to main)



## View the Documentation

After generation:

1. **Local**: Open `docs/generated/index.html` in your web browser
2. **GitHub Pages**: Visit the GitHub Pages site for this repository. View in [Github Pages](https://zebratechnologies.github.io/sws_wfm_test_automation/)

The documentation includes a searchable index with all resources organized by category.
