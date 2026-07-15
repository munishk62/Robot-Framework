# Robot Framework Code Review System

This system provides automated review of Robot Framework code with **Robocop static analysis** as the primary check and **optional LLM-based keyword review** using Ollama models for Pull Requests. It ensures code quality through static analysis and optionally provides intelligent keyword naming suggestions.

## Features

- 🔧 **Robocop Static Analysis**: Primary code quality check with comprehensive Robot Framework best practices (enabled by default)
- 🤖 **Optional LLM Keyword Review**: AI-powered keyword analysis using local Ollama (disabled by default)
- 💬 **GitHub Comments**: Posts structured review comments directly in PRs
- 🔧 **Local Development**: Provides local review script for developers  
- 📊 **Detailed Reports**: Generates comprehensive review summaries
- 🐳 **Minimal Resource Usage**: Docker/Ollama only used when LLM review is enabled

## How It Works

### GitHub Action Workflow

1. **Trigger**: Runs on every PR that modifies `.robot` or `.resource` files
2. **Robocop Analysis**: Runs static code analysis for quality and best practices (always enabled)
3. **Optional LLM Review**: 
   - When enabled: Extracts changed keywords and uses Ollama container for AI review
   - When disabled (default): Skips Docker/Ollama setup entirely
4. **Post Comments**: Creates structured comments in the PR with findings

### Default Configuration (Robocop Only)
- ✅ **Robocop Static Analysis**: Code quality, style, and best practices
- ✅ **Fast Execution**: No Docker container startup overhead  
- ✅ **Minimal Resources**: Uses only built-in GitHub Actions runners
- ✅ **Immediate Feedback**: Quick analysis and reporting

### Optional LLM Review (When Enabled)
The system can also evaluate keywords using AI analysis based on these criteria:

- ✅ **Meaningful and Precise**: Keywords should clearly describe what they do
- ✅ **Consistent Naming Convention**: Use consistent patterns across keywords  
- ✅ **Clear Intent**: The purpose should be immediately obvious
- ✅ **Avoid Unnecessary Words**: Remove redundant or filler words
- ✅ **Consistent Verb Tense**: Use consistent tense (usually imperative/present)
- ✅ **Readable**: Easy to read and understand for any team member

## Setup

### Prerequisites

- GitHub repository with Robot Framework code
- GitHub Actions enabled  
- For LLM review (optional): Docker support in GitHub Actions (included by default)

### Installation

1. **Copy the workflow file** to your repository:
   ```
   .github/workflows/keyword-review.yml
   ```

2. **Copy the scripts** to your repository:
   ```
   .github/scripts/
   ├── extract_changed_keywords.py
   ├── keyword_reviewer.py
   ├── post_review_comments.py
   └── local_review.py
   ```

3. **Add requirements.txt** (if not already present):
   ```
   requests>=2.31.0
   PyGithub>=1.59.0
   ```

4. **Default setup complete** - the action will run automatically on PRs with **Robocop-only** analysis.

### Enabling LLM Keyword Review (Optional)

To enable AI-powered keyword analysis, edit the workflow file:

```yaml
env:
  ENABLE_KEYWORD_REVIEW: "true"  # Change from "false" to "true"
  OLLAMA_MODEL: "phi3:latest"    # Optional: customize the model
```

**Note**: Enabling LLM review adds ~60-90 seconds to workflow execution due to Docker container startup.

## Local Development

Developers can run the same review process locally before creating PRs:

### Using the Local Review Script

```bash
# Install dependencies
pip install requests

# Run Robocop-only review (fast, no Docker needed)
python .github/scripts/local_review.py --robocop-only

# Run full review with keywords (starts Ollama container automatically)
python .github/scripts/local_review.py

# Review specific directory
python .github/scripts/local_review.py --project-dir ./web/resources

# Use different model for keyword review
python .github/scripts/local_review.py --model llama2:7b

# Skip Robocop checks (keywords only)
python .github/scripts/local_review.py --keywords-only

# Custom output directory  
python .github/scripts/local_review.py --output-dir ./my-review-results
```

### Manual Docker Setup

If you prefer to manage Ollama manually:

```bash
# Start Ollama container
docker run -d --name ollama -p 11434:11434 -v ollama:/root/.ollama ollama/ollama:latest

# Pull the model
docker exec ollama ollama pull codellama:7b

# Run review with existing container
python .github/scripts/local_review.py --skip-ollama-setup

# Cleanup when done
docker stop ollama && docker rm ollama
```

## Configuration

### Enabling/Disabling LLM Keyword Review

Edit the workflow file (`.github/workflows/keyword-review.yml`) to control LLM-based keyword review:

```yaml
env:
  ENABLE_KEYWORD_REVIEW: "false"  # "false" = Robocop only, "true" = Full review
  OLLAMA_MODEL: "phi3:latest"     # Model used when keyword review is enabled
```

**Default**: `ENABLE_KEYWORD_REVIEW: "false"` (Robocop-only mode)

### Changing the LLM Model (when enabled)

**Recommended models:**
- `phi3:latest` - Fast and efficient, good for code review (default)
- `codellama:7b` - Good balance of performance and accuracy
- `llama2:7b` - General purpose, good quality  
- `codellama:13b` - Higher accuracy but slower
- `mistral:7b` - Fast alternative

### Customizing Review Criteria

To modify the keyword review criteria (when enabled), edit the `_create_review_prompt()` method in `keyword_reviewer.py`.

### Workflow Triggers

The workflow is configured to run on:
- Pull request opened, synchronized, or reopened
- Only when `.robot` or `.resource` files are modified

To change this, modify the `on` section in the workflow file.

## Understanding the Output

### GitHub PR Comments

The action posts several types of comments:

1. **Main Summary Comment**: Overview of the review with statistics
2. **Detailed File Comments**: Specific issues and suggestions for each file
3. **Robocop Comment**: Code quality issues (if found)

### Review Status

- ✅ **GOOD**: Keyword follows best practices
- 🔍 **NEEDS_IMPROVEMENT**: Minor issues that should be addressed
- ⚠️ **POOR**: Significant issues requiring attention
- ❌ **ERROR**: Review failed (technical issue)

### Local Review Output

Local reviews generate:
- `keywords-to-review.json`: Extracted keywords data
- `review-results.json`: Detailed LLM review results
- `robocop-results.txt`: Robocop static analysis results
- `review-summary.md`: Human-readable summary report

## Examples

### Good Keyword Examples
```robot
*** Keywords ***
Navigate To Request Calendar Page
    [Documentation]    Navigate to the ESS Request Calendar page
    Navigate To Specific Page On Web    ess    request_calendar

Create Day Off Request
    [Documentation]    Create a new day off request with specified dates
    [Arguments]    ${start_date}    ${end_date}    ${reason}
    Fill Day Off Form    ${start_date}    ${end_date}    ${reason}
    Submit Request Form

Verify Request Status
    [Documentation]    Verify that the request has the expected status
    [Arguments]    ${expected_status}
    ${actual_status}=    Get Request Status
    Should Be Equal    ${actual_status}    ${expected_status}
```

### Keywords That Need Improvement
```robot
*** Keywords ***
doSomethingWithCalendar  # ❌ Poor naming convention
    Navigate To Calendar

NavigateToThePageForTheRequestCalendar  # ❌ Too verbose, unnecessary words
    Navigate To Request Calendar Page

process_request  # ❌ Inconsistent case, unclear intent
    [Arguments]    ${req}
    Handle Request    ${req}
```

## Troubleshooting

### Common Issues

1. **Ollama Container Fails to Start**
   - Check Docker is available in the runner
   - Verify the model name is correct
   - Check for sufficient resources

2. **No Keywords Found**
   - Verify `.robot` and `.resource` files are in the diff
   - Check file paths in the repository
   - Ensure proper git diff between base and head

3. **Review Comments Not Posted**
   - Verify `GITHUB_TOKEN` has proper permissions
   - Check repository and PR number are correct
   - Ensure the `pull-requests: write` permission is set

4. **Robocop Errors**
   - Install missing dependencies in the action
   - Check Robocop configuration in `robocop.toml`

### Debugging

To debug the action:

1. **Check Action Logs**: Look at the GitHub Actions logs for detailed output
2. **Download Artifacts**: The action uploads review artifacts for inspection
3. **Run Locally**: Use the local review script to reproduce issues
4. **Enable Debug Logging**: Add `ACTIONS_STEP_DEBUG=true` to repository secrets

### Performance Considerations

**Robocop-Only Mode (Default):**
- **Execution Time**: ~30-60 seconds (depending on codebase size)
- **Resource Usage**: Minimal - uses only GitHub Actions runner
- **Startup Overhead**: None

**Full Review Mode (LLM Enabled):**
- **Model Size**: Larger models (13b, 70b) provide better quality but are slower
- **Keyword Count**: Review time scales linearly with number of changed keywords
- **Container Startup**: Ollama container startup adds ~30-60 seconds per run
- **Resource Usage**: Ensure runners have sufficient memory for larger models
- **Total Time**: ~2-5 minutes depending on model and keyword count

## Contributing

To improve the review system:

1. **Enhance Prompts**: Modify the review prompt in `keyword_reviewer.py`
2. **Add New Checks**: Extend the keyword extraction logic
3. **Improve Parsing**: Enhance the LLM response parsing
4. **Add Metrics**: Track review accuracy and quality over time

## Security Considerations

- The system uses local Ollama containers (no external API calls)
- Only processes Robot Framework files from the repository
- Requires standard GitHub Actions permissions
- No sensitive data is sent to external services

## License

This tool is part of the WFM Test Automation project and follows the same license terms.


## Zscaler issue Fix
ref https://github.com/ollama/ollama/issues/3372#issuecomment-2208199072
### How to download certificate
If you are using a company PC with Zscaler, @rosdi 's above solution did point me to a fix finally, but with an addition of company root certificate to /usr/local/share/ca-certificates/:

For example, if you want to use phi3 model:

visit https://ollama.com/library/phi3:3.8b
Click "Visit site information" on Chrome
Click "Connection is secure"
Click "Certificate is valid"
With the opened "Certificate Viewer:Ollama.com, go to "Details", export the top level company certificate and saved as *.crt file
Then mount or add the certificate to /usr/local/share/ca-certificates/ in the ollama container.
Just pull the docker image from here: https://hub.docker.com/r/ollama/ollama
docker run -d --name ollama-review -p 11434:11434 ^
  -v ollama-review:/root/.ollama ^
  -v C:\Workspaces\sws_wfm_test_automation\cacertificates\ZscalerRootCA.crt:/usr/local/share/ca-certificates/zscaler.crt ^
  ollama/ollama:latest
Then exec into the container
```
docker exec -it <image id> bash
```

Then run update-ca-certificates to reload your list of trusted certificates
```
update-ca-certificates
```
Restart the container.
Once done, try to pull a model, it should no longer complain of certificate issue
