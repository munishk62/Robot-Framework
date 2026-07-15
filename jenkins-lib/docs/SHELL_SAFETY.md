# ShellSafetyUtils Reference Guide

**Last Updated:** 2026-03-02  
**Scope:** Jenkins pipelines using ShellSafetyUtils with executor.py / Robot Framework

This is the single source of truth for ShellSafetyUtils features and usage.

## Features

- **Parameter validation** with regex and whitelist helpers.
- **Safe shell quoting** for Unix and Windows.
- **Robot Framework-aware helpers** to avoid over-quoting tags and extra args.
- **Command builder** for Python scripts with safe argument handling.

## Core API

**Validation**

- `validateParameter(value, pattern, paramName, allowEmpty=false)`
- `validateNumeric(value, paramName, min, max)`
- `validateWhitelist(value, allowedValues, paramName)`
- `validateTagList(tagsString, paramName)`

**Quoting**

- `quote(value, osType="")` (always quotes)
- `quoteIfNeeded(value, osType="")` (quotes only if special chars are present)

**Robot Framework helpers**

- `validateAndPrepareRobotTags(tags, paramName)` (returns comma-separated tags without quotes)
- `validateAndPrepareExtraRobotArgs(args, paramName)` (validates and returns smart-quoted args)

**Command building**

- `buildPythonCommand(scriptName, positionalArgs=[], namedArgs=[:], osType="")`

Source: [jenkins-lib/vars/ShellSafetyUtils.groovy](../vars/ShellSafetyUtils.groovy)

## Validation Patterns

Use with `validateParameter()`:

- `PATTERN_ENV_NAME` (QA29_B0, CVS_SB)
- `PATTERN_TAG_NAME` (smoke, regression)
- `PATTERN_SUITE_NAME` (sanity_suite)
- `PATTERN_PROCESS_COUNT` (1-16)
- `PATTERN_LOG_LEVEL` (INFO, DEBUG, WARNING, ERROR, CRITICAL)
- `PATTERN_FILE_PATH` (tests/web/login.robot)

## Usage Examples

### 1) Validate environment name

```groovy
def safeEnv = ShellSafetyUtils.validateParameter(
  params.TEST_ENV,
  ShellSafetyUtils.PATTERN_ENV_NAME,
  "TEST_ENV"
)
sh("""python executor.py --test-env ${safeEnv}""")
```

### 2) Include/Exclude tags (Robot Framework)

```groovy
if (params.EXCLUDE_TAGS?.trim()) {
  env.SAFE_EXCLUDE_TAGS = ShellSafetyUtils.validateAndPrepareRobotTags(
    params.EXCLUDE_TAGS,
    "EXCLUDE_TAGS"
  )
}

def excludeTagCommand = env.SAFE_EXCLUDE_TAGS ? "--exclude-tags ${env.SAFE_EXCLUDE_TAGS}" : ""
```

**Correct output:** `--exclude-tags obsolete` (no quotes)

### 3) Extra Robot args (Robot Framework)

```groovy
if (params.EXTRA_ROBOT_ARGS?.trim()) {
  env.SAFE_EXTRA_ROBOT_ARGS = ShellSafetyUtils.validateAndPrepareExtraRobotArgs(
    params.EXTRA_ROBOT_ARGS,
    "EXTRA_ROBOT_ARGS"
  )
}

def pythonCommand = "python executor.py ${testPath}"
if (env.SAFE_EXTRA_ROBOT_ARGS) {
  pythonCommand += " ${env.SAFE_EXTRA_ROBOT_ARGS}"
}
```

Example input:
```
--variable PAGE_LOAD_TIMEOUT:100s --skiponfailure applicability_not_met
```
Result: passed as multiple arguments, not a single quoted string.

### 4) Free-form values or paths

```groovy
def safePath = ShellSafetyUtils.quoteIfNeeded(params.TESTPATH ?: "tests/web/l2_suite/")
sh("""python executor.py ${safePath} --test-env ${safeEnv}""")
```

## Common Pitfall (Do Not Do This)

```groovy
// WRONG: re-quoting validated tags breaks Robot Framework filtering
"--exclude-tags ${ShellSafetyUtils.quote(env.SAFE_EXCLUDE_TAGS)}"
```

## Injection Safety (Extra Robot Args)

`validateAndPrepareExtraRobotArgs()` rejects these patterns:

- `;` (command chaining)
- `|` (pipe)
- `&` (background/AND)
- `>>` (append)
- `<<` (heredoc)
- `` ` `` (backticks)
- `$(` (subshell)

If any appear, it throws `IllegalArgumentException`.

## Minimal End-to-End Example

```groovy
try {
  def safeEnv = ShellSafetyUtils.validateParameter(
    params.TEST_ENV,
    ShellSafetyUtils.PATTERN_ENV_NAME,
    "TEST_ENV"
  )

  def includeTagCommand = ""
  if (params.INCLUDE_TAGS?.trim()) {
    env.SAFE_INCLUDE_TAGS = ShellSafetyUtils.validateAndPrepareRobotTags(
      params.INCLUDE_TAGS,
      "INCLUDE_TAGS"
    )
    includeTagCommand = "--include-tags ${env.SAFE_INCLUDE_TAGS}"
  }

  def pythonCommand = "python executor.py ${testPath} --test-env ${safeEnv} ${includeTagCommand}"

  if (params.EXTRA_ROBOT_ARGS?.trim()) {
    env.SAFE_EXTRA_ROBOT_ARGS = ShellSafetyUtils.validateAndPrepareExtraRobotArgs(
      params.EXTRA_ROBOT_ARGS,
      "EXTRA_ROBOT_ARGS"
    )
    pythonCommand += " ${env.SAFE_EXTRA_ROBOT_ARGS}"
  }

  sh("""${pythonCommand}""")
} catch (IllegalArgumentException e) {
  error("Validation failed: ${e.message}")
}
```

## Summary Rules

- Validate and prepare once, then use directly.
- Do not re-quote validated values.
- Use `quoteIfNeeded()` only for free-form values or paths with spaces.
- Use Robot-specific helpers for tags and extra args.
