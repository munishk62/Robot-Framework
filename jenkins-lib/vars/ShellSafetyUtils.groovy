import groovy.transform.Field

/**
 * ShellSafetyUtils - Reusable Groovy utilities for safe Jenkins pipeline shell execution.
 *
 * This utility provides methods to:
 * 1. Validate pipeline parameters against whitelists/patterns
 * 2. Safely escape shell arguments to prevent injection attacks
 * 3. Build shell commands with proper argument quoting
 *
 * PROBLEM:
 * --------
 * Parameter values directly embedded in shell scripts are vulnerable to injection:
 *   def command = "python executor.py --extra '${params.EXTRA_ROBOT_ARGS}'"
 *   // If EXTRA_ROBOT_ARGS = '; rm -rf /', the script executes arbitrary code
 *
 * SOLUTION:
 * ---------
 * Use ShellSafetyUtils.quote() and ShellSafetyUtils.validateParameter() to sanitize inputs:
 *   def safeArgs = ShellSafetyUtils.quote(params.EXTRA_ROBOT_ARGS)
 *   def command = "python executor.py --extra ${safeArgs}"
 *
 * @example
 *   // Basic usage
 *   def safeTestEnv = ShellSafetyUtils.validateParameter(
 *       params.TEST_ENV,
 *       ShellSafetyUtils.PATTERN_ENV_NAME,
 *       "TEST_ENV"
 *   )
 *
 *   def safeExtraArgs = ShellSafetyUtils.quote(params.EXTRA_ROBOT_ARGS)
 *   def command = "python executor.py --test-env ${safeTestEnv} --extra ${safeExtraArgs}"
 *
 * @author Security Team
 * @version 1.0
 */

/**
 * VALIDATION PATTERNS
 * Define acceptable input patterns for common parameter types.
 * Use these with validateParameter() to ensure only expected values are accepted.
 */

// Environment names: QA29_B0, CVS_SB, BMR_SB, etc. (alphanumeric, underscore, hyphen)
@Field static final String PATTERN_ENV_NAME = "^[A-Za-z0-9_-]+\$"

// Tag names: smoke, regression, wip, etc.
@Field static final String PATTERN_TAG_NAME = "^[A-Za-z0-9_-]+\$"

// Suite names: sanity, regression_suite, etc.
@Field static final String PATTERN_SUITE_NAME = "^[A-Za-z0-9_-]+\$"

// Process counts: 1-16 (reasonable parallelization limit)
@Field static final String PATTERN_PROCESS_COUNT = "^([1-9]|1[0-6])\$"

// Log levels: INFO, DEBUG, WARNING, ERROR, CRITICAL
@Field static final String PATTERN_LOG_LEVEL = "^(INFO|DEBUG|WARNING|ERROR|CRITICAL)\$"

// File paths: relative paths with alphanumeric, underscore, hyphen, slash, dot
@Field static final String PATTERN_FILE_PATH = "^[A-Za-z0-9_./-]+\$"

/**
 * SHELL QUOTING AND ESCAPING
 */

/**
 * Quote a string for safe use in shell commands.
 *
 * IMPORTANT: Use quoteIfNeeded() instead for most cases. This method always adds quotes.
 *
 * For Unix-like shells (Linux/macOS), uses single quotes which prevent all expansions.
 * If the string contains single quotes, they are escaped by ending the quote, adding
 * an escaped quote, and starting quotes again.
 *
 * For Windows (cmd.exe), uses double quotes and escapes special characters.
 *
 * @param value The string to quote
 * @param osType Optional: 'Linux', 'macOS', or 'Windows'. Auto-detected if blank.
 * @return The quoted string safe for shell injection
 *
 * @example
 *   def arg = "hello world; rm -rf /"
 *   def safe = ShellSafetyUtils.quote(arg)  // Returns: 'hello world; rm -rf /'
 *   def cmd = "python script.py ${safe}"     // Now safe from injection
 */
static String quote(String value, String osType = "") {
    if (!value) return "''"

    // Auto-detect OS if not specified
    if (!osType) {
        osType = System.getProperty("os.name").toLowerCase().contains("windows") ? "Windows" : "Linux"
    }

    if (osType.toLowerCase() == "windows") {
        return quoteForWindows(value)
    } else {
        // Linux and macOS use same quoting strategy
        return quoteForUnix(value)
    }
}

/**
 * Smart quoting: Only quote if the value contains special shell characters.
 *
 * This PREVENTS OVER-QUOTING issues where safe parameters are unnecessarily quoted.
 * Use this for validated parameters or parameters that might be safe.
 *
 * Shell special characters: space, ;, |, &, <, >, $, `, \, ", ', (, ), {, }, [, ]
 *
 * @param value The string to conditionally quote
 * @param osType Optional: 'Linux', 'macOS', or 'Windows'
 * @return The value, quoted only if it contains special characters
 *
 * @example
 *   ShellSafetyUtils.quoteIfNeeded("obsolete")        // Returns: obsolete (no quotes needed)
 *   ShellSafetyUtils.quoteIfNeeded("hello world")     // Returns: 'hello world' (space is special)
 *   ShellSafetyUtils.quoteIfNeeded("test;rm -rf /") // Returns: 'test;rm -rf /' (; is special)
 */
static String quoteIfNeeded(String value, String osType = "") {
    if (!value) return ""
    
    // Pattern: detects shell special characters
    def hasSpecialChars = value.matches('.*[\\s;|&<>$`\\"\'\\(\\)\\{\\}\\[\\]]+.*')
    
    if (hasSpecialChars) {
        return quote(value, osType)
    }
    return value
}

/**
 * Quote for Unix-like shells (Linux, macOS).
 * Uses single quotes and escapes embedded single quotes.
 */
private static String quoteForUnix(String value) {
    // Single quotes prevent all expansions except we need to escape the quote itself
    // Strategy: 'text'  ->  'text'\''more'  (end quote, escaped quote, resume quote)
    return "'" + value.replace("'", "'\\''") + "'"
}

/**
 * Quote for Windows cmd.exe.
 * Uses double quotes and escapes special characters.
 */
private static String quoteForWindows(String value) {
    // Windows cmd.exe is complex; use basic escaping for common injection chars
    def escaped = value
        .replace("&", "^&")   // Escape & (command chaining)
        .replace("|", "^|")   // Escape | (pipe)
        .replace("<", "^<")   // Escape < (redirect)
        .replace(">", "^>")   // Escape > (redirect)
        .replace("(", "^(")   // Escape (
        .replace(")", "^)")   // Escape )
        .replace("^", "^^")   // Escape ^ itself (must be last)

    return '"' + escaped + '"'
}

/**
 * PARAMETER VALIDATION
 */

/**
 * Validate a parameter against a regex pattern.
 *
 * @param paramValue The parameter value to validate
 * @param pattern Regex pattern (use PATTERN_* constants)
 * @param paramName Name of the parameter (for error messages)
 * @param allowEmpty If true, empty values pass validation. Default: false
 * @return The validated parameter value
 * @throws IllegalArgumentException If validation fails
 *
 * @example
 *   def safeEnv = ShellSafetyUtils.validateParameter(
 *       params.TEST_ENV,
 *       ShellSafetyUtils.PATTERN_ENV_NAME,
 *       "TEST_ENV"
 *   )
 */
static String validateParameter(
    String paramValue,
    String pattern,
    String paramName,
    boolean allowEmpty = false
) {
    if (!paramValue || paramValue.trim().isEmpty()) {
        if (allowEmpty) {
            return ""
        }
        throw new IllegalArgumentException("Parameter '${paramName}' cannot be empty")
    }

    def cleaned = paramValue.trim()
    if (!cleaned.matches(pattern)) {
        throw new IllegalArgumentException(
            "Parameter '${paramName}' value '${cleaned}' does not match expected pattern. " +
            "Pattern: ${pattern}"
        )
    }

    return cleaned
}

/**
 * Validate a CSV list of tags.
 * Each tag is validated against PATTERN_TAG_NAME.
 *
 * @param tagsString Comma or space-separated tag list
 * @param paramName Name of the parameter (for error messages)
 * @return List of validated tags
 * @throws IllegalArgumentException If any tag is invalid
 *
 * @example
 *   def tags = ShellSafetyUtils.validateTagList(params.INCLUDE_TAGS, "INCLUDE_TAGS")
 *   // Returns: ["smoke", "regression"]
 */
static List<String> validateTagList(String tagsString, String paramName) {
    if (!tagsString || tagsString.trim().isEmpty()) {
        return []
    }

    def tags = tagsString.split(/[,\s]+/).collect { it.trim() }.findAll { it }
    def invalid = tags.findAll { !it.matches(PATTERN_TAG_NAME) }

    if (invalid) {
        throw new IllegalArgumentException(
            "Parameter '${paramName}' contains invalid tags: ${invalid.join(', ')}. " +
            "Tags must match pattern: ${PATTERN_TAG_NAME}"
        )
    }

    return tags
}

/**
 * Validate a numeric parameter within a range.
 *
 * @param paramValue The parameter value to validate
 * @param paramName Name of the parameter (for error messages)
 * @param min Minimum allowed value (inclusive)
 * @param max Maximum allowed value (inclusive)
 * @return The validated integer value
 * @throws IllegalArgumentException If validation fails
 *
 * @example
 *   def processes = ShellSafetyUtils.validateNumeric(
 *       params.PARALLEL_PROCESSES,
 *       "PARALLEL_PROCESSES",
 *       1,
 *       16
 *   )
 */
static int validateNumeric(String paramValue, String paramName, int min, int max) {
    if (!paramValue || paramValue.trim().isEmpty()) {
        throw new IllegalArgumentException("Parameter '${paramName}' cannot be empty")
    }

    try {
        def value = paramValue.trim().toInteger()
        if (value < min || value > max) {
            throw new IllegalArgumentException(
                "Parameter '${paramName}' value ${value} is outside allowed range [${min}, ${max}]"
            )
        }
        return value
    } catch (NumberFormatException e) {
        throw new IllegalArgumentException(
            "Parameter '${paramName}' value '${paramValue}' is not a valid integer"
        )
    }
}

/**
 * Whitelist validation: check if value is in allowed list.
 *
 * @param paramValue The parameter value to validate
 * @param allowedValues List of acceptable values
 * @param paramName Name of the parameter (for error messages)
 * @return The validated parameter value
 * @throws IllegalArgumentException If not in whitelist
 *
 * @example
 *   def version = ShellSafetyUtils.validateWhitelist(
 *       params.COGNOS_VERSION,
 *       ["11", "12"],
 *       "COGNOS_VERSION"
 *   )
 */
static String validateWhitelist(String paramValue, List<String> allowedValues, String paramName) {
    if (!paramValue || paramValue.trim().isEmpty()) {
        throw new IllegalArgumentException("Parameter '${paramName}' cannot be empty")
    }

    def cleaned = paramValue.trim()
    if (!allowedValues.contains(cleaned)) {
        throw new IllegalArgumentException(
            "Parameter '${paramName}' value '${cleaned}' not in allowed values: ${allowedValues.join(', ')}"
        )
    }

    return cleaned
}

/**
 * ROBOT FRAMEWORK SPECIFIC HELPERS
 * 
 * These functions handle Robot Framework / executor.py arguments specially,
 * understanding that executor.py parses command-line arguments differently
 * than a generic shell would.
 */

/**
 * Validate and prepare Robot Framework tags for executor.py.
 *
 * Key point: Validated tags are already safe and should NOT be re-quoted.
 * This returns tags as a plain comma-separated string.
 *
 * @param tagString Comma or space-separated tags
 * @param paramName Name of the parameter (for error messages)
 * @return Validated comma-separated tags string (NO QUOTES)
 * @throws IllegalArgumentException If any tag is invalid
 *
 * @example
 *   def safeTags = ShellSafetyUtils.validateAndPrepareRobotTags(params.INCLUDE_TAGS, "INCLUDE_TAGS")
 *   def cmd = "python executor.py --include-tags ${safeTags}"  // NO quote() call needed!
 */
static String validateAndPrepareRobotTags(String tagString, String paramName) {
    if (!tagString || tagString.trim().isEmpty()) {
        return ""
    }

    def tags = tagString.split(/[,\s]+/).collect { it.trim() }.findAll { it }
    def invalid = tags.findAll { !it.matches(PATTERN_TAG_NAME) }

    if (invalid) {
        throw new IllegalArgumentException(
            "Parameter '${paramName}' contains invalid tags: ${invalid.join(', ')}. " +
            "Tags must match pattern: ${PATTERN_TAG_NAME}"
        )
    }

    // Return plain comma-separated string - NO QUOTES needed after validation
    return tags.join(",")
}

/**
 * Validate and prepare Robot Framework extra arguments.
 *
 * Robot Framework arguments have complex syntax (flags with colons, equals signs, etc).
 * This function validates the structure without over-quoting.
 *
 * Strategy:
 * 1. Reject known injection patterns (semicolons, pipes, command substitution)
 * 2. Check that arguments look like valid Robot Framework syntax
 * 3. Return unquoted (will be split by shell naturally) OR
 * 4. Return pre-quoted only if it contains spaces AND is a single logical argument
 *
 * @param argsString The extra robot arguments
 * @param paramName Name of the parameter (for error messages)
 * @return Validated arguments for use in shell (intelligently quoted if needed)
 * @throws IllegalArgumentException If validation fails
 *
 * @example
 *   def safeArgs = ShellSafetyUtils.validateAndPrepareExtraRobotArgs(
 *       params.EXTRA_ROBOT_ARGS,
 *       "EXTRA_ROBOT_ARGS"
 *   )
 *   def cmd = "python executor.py ${safeArgs}"  // Already properly handled
 */
static String validateAndPrepareExtraRobotArgs(String argsString, String paramName) {
    if (!argsString || argsString.trim().isEmpty()) {
        return ""
    }

    def args = argsString.trim()
    
    // Red flags: command injection patterns - REJECT
    def injectionPatterns = [
        ';',        // Command chaining
        '|',        // Pipe
        '&',        // Background/AND
        '>>',       // Append
        '<<',       // Heredoc
        '`',        // Command substitution
        '$(',     // Subshell
    ]
    
    for (pattern in injectionPatterns) {
        if (args.contains(pattern)) {
            throw new IllegalArgumentException(
                "Parameter '${paramName}' contains unsafe character '${pattern}'. " +
                "These are not allowed: ${injectionPatterns.join(', ')}"
            )
        }
    }
    
    // Robot Framework arguments are typically:
    //   --variable KEY:VALUE
    //   --variable KEY:VALUE --skiponfailure tag_name
    // These contain alphanumeric, colons, hyphens, underscores, spaces
    // Allow these patterns; reject others
    
    // If contains only safe chars for Robot Framework, return unquoted.
    // NOTE: We allow only literal spaces as whitespace here, not all \s,
    // to prevent embedded newlines or other control characters from being
    // returned unquoted into a shell script.
    if (args.matches('^[\\w :=\\-,.]*$')) {
        return args
    }
    
    // If has other special chars but looks like it might be valid
    // (user might have put something like --variable FOO:'bar baz')
    // Quote the entire thing for safety
    return quote(args)
}

/**
 * COMMAND BUILDING HELPERS
 */

/**
 * Build a Python command with safely quoted arguments.
 *
 * @param scriptName The Python script to run (e.g., "executor.py")
 * @param positionalArgs List of positional arguments
 * @param namedArgs Map of named arguments (flag -> value pairs)
 * @param osType Optional: 'Linux', 'macOS', or 'Windows'
 * @return The complete shell command string
 *
 * @example
 *   def cmd = ShellSafetyUtils.buildPythonCommand(
 *       "executor.py",
 *       ["${testPath}"],
 *       [
 *           "--test-env": params.TEST_ENV,
 *           "--processes": params.PARALLEL_PROCESSES,
 *           "--extra": params.EXTRA_ROBOT_ARGS
 *       ]
 *   )
 *   // Returns: python executor.py 'test/path' --test-env 'QA29_B0' --processes '3' --extra '...'
 */
static String buildPythonCommand(
    String scriptName,
    List<String> positionalArgs = [],
    Map<String, String> namedArgs = [:],
    String osType = ""
) {
    def parts = ["python", scriptName]

    positionalArgs.each { arg ->
        if (arg) {
            parts.add(quote(arg, osType))
        }
    }

    namedArgs.each { flag, value ->
        if (flag && value) {
            parts.add("${flag} ${quote(value, osType)}")
        }
    }

    return parts.join(" ")
}

/**
 * LOG/DEBUG: Print validation results (call in pipeline script blocks).
 * Useful for troubleshooting parameter validation.
 *
 * @param paramName Name of the parameter
 * @param originalValue Original parameter value
 * @param validatedValue Validated/sanitized value
 */
static void logValidation(String paramName, String originalValue, String validatedValue) {
    println("[SECURITY] Parameter '${paramName}' validated: '${originalValue}' -> '${validatedValue}'")
}

return this
