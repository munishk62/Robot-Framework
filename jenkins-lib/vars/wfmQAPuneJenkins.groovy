/**
 * WFM QA Pune Jenkins Pipeline
 *
 * This pipeline is designed to run WFM QA tests on a specified Jenkins agent.
 * It includes stages for setup, git checkout, dependency installation, test execution,
 * and post-build actions such as reporting and email notifications.
 * The pipeline assumes
 * - The jenkins agent (node - agentLabel) has python 3.13+, uv, npm is installed and configured.
 * - This library is configured in Jenkins with the name 'wfm-qe-libs'.
 * - The pipeline takes care of installing all robot dependencies including SWS RF Bundle dependencies.
 *
 * @param config A map of configuration options for the pipeline.
 *               Supported keys:
 *               - agentLabel:(mandatory) Label of the Jenkins agent to run the pipeline on.
 *               - testPath:(mandatory) Path to the test suite to be executed.
 *               - testEnv:(mandatory) The test environment e.g. QA29_B0, BMR_SB.
 *               - noOfParallelProcesses: Number of parallel processes for test execution. Default to 1.
 *               - resultsFolderName: Name of the folder to store test results. Defaulted to 'results_' + testEnv.
 *               - includeTags: Tags to include in the test run.
 *               - excludeTags: Tags to exclude from the test run.
 *               - extraRobotArgs: Additional arguments for robot execution. like --variable LONG_TIMEOUT:75. Check executor.py for more details.
 *               - jobTimeout: Timeout for the entire job in hours.
 *               - repoDirName: Directory name where the repository is supposed to be checked out on agent machine. default sws_wfm_test_automation_jenkinslib.
 *               - name: Name of the Jenkins job.
 *               - defaultEmailRecipient: Default email recipients for report notifications.
 *               - dashboardUpdateEnabled: Enable dashboard JSON updates and push to dashboard-data branch. Default false.
 *               - dashboardEnvName: Display name for the environment in dashboard. Defaults to testEnv.
 *               - githubTokenCredentialId: Jenkins credential ID for GitHub PAT. Default 'kg_pat_pipeline'.
 *               - teamsWebhookCredentialId: Optional Jenkins **Secret text** credential ID whose value is the Teams
 *                 incoming webhook URL. When set, the Test Execution stage binds it to env var
 *                 `TEST_FAILURE_NOTIFICATION_WEBHOOK` for `executor.py` / Robot (e.g. `TeamsWebhookListener`). When empty,
 *                 nothing is bound—listeners that resolve the URL from env will no-op. Omit for jobs that should not
 *                 notify Teams. Same credential ID can be reused across multiple Jenkinsfiles for one channel.
 *               - skipHealthCheck: Skip standalone health check step entirely. Default false.
 *               - healthCheckTimeout: Timeout in seconds for standalone health checks. Default 10.
 *               - skipDatabaseHealthCheck: Skip DB2 and queue checks in standalone health check step. Default false.
 *               - queuePendingThreshold: Max JOBS_PENDING allowed in rfx_queue before failing health checks. Default 100.
 *               - mobilePlatform: Default mobile platform surfaced as the first `MOBILE_PLATFORM` choice
 *                 (`android` / `ios` / `''`). Defaults to `android`. Users can still override at build time.
 *               - cloudPlatform: Default cloud platform surfaced as the first `CLOUD_PLATFORM` choice
 *                 (`lambdaTest` / `zTest` / `''`). Defaults to `lambdaTest` when the caller does not
 *                 declare it, so jobs always land on lambdaTest unless explicitly set. Users can still
 *                 override at build time; selecting the empty choice runs directly on the Jenkins agent
 *                 (no cloud provider).
 *               - retryCount: Number of retry attempts for failed tests after the initial run. Default 1
 *                 (initial run + up to 1 retry of only the failed tests). Set to 0 to disable retries for
 *                 this job. Range 0..3. Users can override at build-time via the RETRY_COUNT parameter.
 *                 Retries are gated by an initial failure percentage threshold (25% hard-coded policy
 *                 constant in `dev_utils/retry_manager.py`, `MAX_FAILURE_PCT`): if too many tests fail,
 *                 retries are skipped since it likely indicates a real regression, not flake. To adjust
 *                 the threshold, edit the constant in code and commit; it is intentionally not runtime-
 *                 configurable to keep tuning reviewable. All attempts are preserved under
 *                 results/results_<ENV>/attempt_<n>/ and merged via `rebot --merge` into the top-level
 *                 output.xml so downstream reporting is unchanged.
 *
 *
 * Note: The base path where the repository is checked out on the agent machine is fixed as below:
 *       - Linux: /home/symbol/RFS_CI/GIT_REPO/
 *       - Windows: C:\RFS_CI\GIT_REPO\

 * Usage:
 * ```Jenkinsfile
        @Library('wfm-qe-libs') _
        wfmQAPuneJenkins([
            "testEnv": "AAP_SB",
            "testPath": "tests/web/examples/",
            "agentLabel": "wfm-qa-agent"
        ])
    * ```
 */
def call(Map config = [:]) {
    // Global variables for the pipeline scope
    // Default values
    def agentLabel = config.agentLabel ?: 'wfm-qa-agent'
    def testPath = config.testPath ?: "tests/"
    def defaultTestEnv = config.testEnv ?: 'QA29_B0'
    def noOfParallelProcesses = config.noOfParallelProcesses ?: '2'
    def resultsFolderName = config.resultsFolderName ?: 'results_' + defaultTestEnv
    def includeTags = config.includeTags ?: ''
    def testRayPlan = config.testRayPlan ?: ''
    def testRayCycle = config.testRayCycle ?: ''
    def excludeTags = config.excludeTags ?: 'obsolete,payroll_execution'
    def extraRobotArgs = config.extraRobotArgs ?: ''
    def jobTimeout = config.jobTimeout ?: '5'
    def repoDirName = config.repoDirName ?: "sws_wfm_test_automation_jenkinslib"
    def name = config.name ?: 'WFM_QA_Pune_Jenkins_Pipeline'
    def defaultEmailRecipient = config.defaultEmailRecipient ?: "ashish.solankar@zebra.com,kishan.madhwani@zebra.com,pratik.sutar@zebra.com,bushra.ahmed@zebra.com,azarudheen.azarudheen@zebra.com,yogesh.dixit@zebra.com,amol.ghule@zebra.com,moiz.hawalchi@zebra.com,rushikeshchandrakant.ippalpelli@zebra.com,munish.kumar@zebra.com,ravi.sankar1@zebra.com,komal.shinde2@zebra.com,bablu.ranjan1@zebra.com,v.swaminathan@zebra.com,sagar.pawar@zebra.com,mayur.kukawalkar@zebra.com,ankur.arvind@zebra.com,rahul.chava@zebra.com,sriram.maddali@zebra.com,ravising.pardeshi@zebra.com,anil.kumar@zebra.com,bvk.prasad@zebra.com,anand.mk@zebra.com,kshitij.uttarwar@zebra.com,rashi.jain@zebra.com"
    def ccRecipient = config.ccRecipient ?: "kg9078@zebra.com,abhishek.pundikar@zebra.com,sriram.krishnan@zebra.com"
    def dashboardUpdateEnabled = config.dashboardUpdateEnabled =="false" ? false : (config.dashboardUpdateEnabled ?: true)
    def dashboardDataDir = "docs/dashboard/data"
    def dashboardEnvName = config.dashboardEnvName ?: defaultTestEnv
    def dashboardBranch = "dashboard-data"
    def githubTokenCredentialId = config.githubTokenCredentialId ?: "git_pat_munish"
    def suiteName = config.suiteName ?: ''
    def i18nLocale = config.i18nLocale ?: ''
    def teamsWebhookCredentialId = config.teamsWebhookCredentialId ?: ''
    def mobilePlatform = config.mobilePlatform ?: 'android'
    // Cloud platform default follows the same convention as mobilePlatform: the value from the caller's Jenkinsfile becomes the first (default) entry in the CLOUD_PLATFORM choice list, so build-time overrides stay possible. When not declared, jobs land on `lambdaTest` by default. Selecting the empty choice at build time means "run on the Jenkins agent directly, no cloud provider".
    def cloudPlatform = config.cloudPlatform ?: 'lambdaTest'
    def skipHealthCheck = config.skipHealthCheck == true
    def healthCheckTimeout = config.healthCheckTimeout ?: '10'
    def skipDatabaseHealthCheck = config.skipDatabaseHealthCheck == true
    def queuePendingThreshold = config.queuePendingThreshold ?: '100'
    // Retry defaults. executor.py CLI default is 0 (opt-in for localdeveloper runs); the Jenkins Groovy default is 1 so every job benefits from a single re-run of failed tests unless the caller explicitly sets retryCount: 0 in the Jenkinsfile.
    def retryCount = config.retryCount != null ? "${config.retryCount}" : '1'



    def emailTo
    def emailCc

    pipeline {
        options {
            timeout(time: jobTimeout, unit: "HOURS")
            skipDefaultCheckout()
        }
        agent {
            label "${params.JENKINS_AGENT_LABEL}"
        }
        parameters {
            // Test Run Specific Params
            string(name: 'TEST_ENV', defaultValue: defaultTestEnv, description: 'Environment to Run the Test')
            string(name: 'PARALLEL_PROCESSES', defaultValue: noOfParallelProcesses, description: 'Number of parallel processes to use')
            string(name: 'JENKINS_AGENT_LABEL', defaultValue: agentLabel, description: 'Jenkins agent to be used for this job')
            string(
                name: 'INCLUDE_TAGS',
                defaultValue: includeTags,
                description: 'Only run tests with these tags (comma-separated). Leave empty to run all tests.'
            )
            string(
                name: 'EXCLUDE_TAGS',
                defaultValue: excludeTags,
                description: 'Exclude tests with these tags (comma-separated). Leave empty to exclude no tests.'
            )
            string(name: 'TESTRAY_PLAN', defaultValue: testRayPlan, description: 'Test Ray Plan')
            string(name: 'TESTRAY_CYCLE', defaultValue: testRayCycle, description: 'Test Ray Cycle')
            string(name: 'EXTRA_ROBOT_ARGS', defaultValue: extraRobotArgs, description: 'Additional robot execution arguments')
            string(name: 'JOB_TIMEOUT_IN_HOURS', defaultValue: jobTimeout, description: 'Time out Value for the Entire Job')
            booleanParam(name: 'PUBLISH_DASHBOARD', defaultValue: dashboardUpdateEnabled, description: 'Update dashboard JSON and push to GitHub')
            string(name: 'DASHBOARD_ENV_NAME', defaultValue: dashboardEnvName, description: 'Environment label used in the dashboard')
            text(name: 'MAIL_ID', defaultValue: defaultEmailRecipient, description: 'Email IDs to send the report to')
            string(name: 'SUITE_NAME', defaultValue: suiteName, description: 'Name of the test suite')
            booleanParam(
                name: 'SKIP_HEALTH_CHECK',
                defaultValue: skipHealthCheck,
                description: 'Skip the standalone health check step before executor.py.'
            )
            string(
                name: 'HEALTH_CHECK_TIMEOUT',
                defaultValue: healthCheckTimeout,
                description: 'Timeout in seconds for pre-execution health checks.'
            )
            booleanParam(
                name: 'SKIP_DATABASE_HEALTH_CHECK',
                defaultValue: skipDatabaseHealthCheck,
                description: 'Skip DB2 and queue checks in the standalone health check step.'
            )
            string(
                name: 'QUEUE_PENDING_THRESHOLD',
                defaultValue: queuePendingThreshold,
                description: 'Fail health checks if rfx_queue has JOBS_PENDING above this value.'
            )
            string(
                name: 'RETRY_COUNT',
                defaultValue: retryCount,
                description: 'Number of retry attempts for failed tests (0 disables retry, max 3). Retries are skipped when initial failure rate exceeds 25%.'
            )
            choice(
                name: 'MOBILE_PLATFORM',
                choices: (mobilePlatform == 'ios' ? ['ios', 'android', ''] : (mobilePlatform == '' ? ['', 'android', 'ios'] : ['android', 'ios', ''])),
                description: 'Mobile platform to run the tests on. E.g. android, ios. Leave empty for non-mobile tests.'
            )
            choice(
                name: 'CLOUD_PLATFORM',
                choices: (cloudPlatform == 'zTest' ? ['zTest', 'lambdaTest', ''] : (cloudPlatform == '' ? ['', 'lambdaTest', 'zTest'] : ['lambdaTest', 'zTest', ''])),
                description: 'Cloud platform to run the tests on. E.g. zTest, lambdaTest. Default is set by the Jenkinsfile config (cloudPlatform); user can still pick another option at build time.'
            )
        }
        environment {
            PYTHONIOENCODING = 'UTF-8'
            ENCRYPTION_KEY = credentials('wfm-encryption-key')

        }
        stages {
            stage('Setup') {
                steps {
                    script {
                        // Assign parameter values to global variables (To and CC must be separate for emailext)
                        emailTo = normalizeEmailList(params.MAIL_ID ?: defaultEmailRecipient)
                        emailCc = normalizeEmailList(ccRecipient)
                    }

                    validateParams(params,env)
                    initializeVariables(params, env, resultsFolderName, repoDirName)
                }
            }
            stage('Git Checkout') {
                steps {
                    gitCheckout(env)
                }
                post {
                    failure {
                        sendPipelineEmail(
                            subject: "Git Pull Failed in ${NODE_NAME} Machine - Check credentials",
                            body: '''${SCRIPT, template="groovy-html.template"}''',
                            to: emailTo,
                            cc: emailCc,
                            requester: true
                        )
                    }
                }
            }
            stage('Install Dependencies') {
                steps {
                    dir(env.REPO_LOCATION) {
                        script {
                            echo "Current Directory: ${pwd()}"
                            if (env.OS_TYPE == 'Windows') {
                                powershell '''
                                    $ErrorActionPreference = "Stop"

                                    function Get-DirectoryHash ($path) {
                                        if (-not (Test-Path $path)) { return "missing" }
                                        $files = Get-ChildItem -Path $path -Recurse -File | Where-Object { $_.FullName -notmatch "__pycache__" -and $_.Extension -ne ".log" } | Sort-Object FullName
                                        if ($files.Count -eq 0) { return "empty" }
                                        $content = $files | ForEach-Object { Get-FileHash $_.FullName -Algorithm MD5 } | Select-Object -ExpandProperty Hash
                                        $stream = [IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($content -join ""))
                                        return (Get-FileHash -InputStream $stream -Algorithm MD5).Hash
                                    }

                                    $uvLockHash = (Get-FileHash "uv.lock" -Algorithm MD5).Hash
                                    $bundleHash = Get-DirectoryHash "SWS_RF_Bundle_uv_jenkins"
                                    $currentHash = "$uvLockHash-$bundleHash"
                                    $hashFile = ".dep_hash"

                                    if (Test-Path $hashFile) {
                                        $storedHash = Get-Content $hashFile
                                        Write-Host "Stored Hash: $storedHash"
                                        Write-Host "Current Hash: $currentHash"
                                        if ($storedHash -eq $currentHash) {
                                            Write-Host "Dependencies (uv.lock and SWS_RF_Bundle_uv_jenkins) are unchanged. Skipping installation."
                                            exit 0
                                        }
                                    }

                                    Write-Host "Dependencies changed or not installed. Running installation..."

                                    if (Test-Path .venv) {
                                        Write-Host "Deleting existing .venv folder..."
                                        #Remove-Item -Path .venv -Recurse -Force
                                        # Use cmd.exe rmdir for better long path handling
                                        & cmd.exe /c "if exist .venv rmdir /s /q .venv"
                                    }

                                    uv sync

                                    Write-Host "Installing SWS RF Bundle dependencies..."
                                    . .venv\\Scripts\\activate
                                    Set-Location SWS_RF_Bundle_uv_jenkins
                                    uv run python install_bundle.py
                                    Set-Location ..

                                    $currentHash | Out-File $hashFile -NoNewline -Encoding ascii
                                    Write-Host "Dependencies installed successfully!"
                                '''
                            } else {
                                sh '''
                                    set -e
                                    calc_hash() {
                                        if command -v md5sum >/dev/null 2>&1; then
                                            local lock_hash=$(md5sum uv.lock | awk '{print $1}')
                                            local bundle_hash=$(find SWS_RF_Bundle_uv_jenkins -type f -not -path "*/__pycache__/*" -not -name "*.log" -exec md5sum {} + | sort | md5sum | awk '{print $1}')
                                        else
                                            local lock_hash=$(md5 -q uv.lock)
                                            local bundle_hash=$(find SWS_RF_Bundle_uv_jenkins -type f -not -path "*/__pycache__/*" -not -name "*.log" -exec md5 -q {} + | sort | md5 -q)
                                        fi
                                        echo "${lock_hash}-${bundle_hash}"
                                    }

                                    CURRENT_HASH=$(calc_hash)

                                    if [ -f .dep_hash ] && [ "$(cat .dep_hash)" = "$CURRENT_HASH" ]; then
                                        echo "Dependencies unchanged. Skipping installation."
                                    else
                                        echo "Dependencies changed. Running installation..."

                                        echo "Deleting existing .venv folder..."
                                        rm -rf .venv

                                        uv sync

                                        echo "Installing SWS RF Bundle dependencies..."
                                        . .venv/bin/activate
                                        cd SWS_RF_Bundle_uv_jenkins
                                        uv run python3 install_bundle.py
                                        cd ..

                                        echo "$CURRENT_HASH" > .dep_hash
                                        echo "Dependencies installed successfully!"
                                    fi
                                '''
                                //env.PATH = "${env.HOME}/.local/bin:${env.PATH}"
                            }
                        }
                    }
                }
            }
            stage('Test Execution') {
                options {
                    timeout(time: params.JOB_TIMEOUT_IN_HOURS, unit: "HOURS")
                }
                steps {
                    script {
                        def selectedCloudPlatform = params.CLOUD_PLATFORM?.trim() ?: ''
                        if (selectedCloudPlatform == 'zTest') {
                            withCredentials([usernamePassword(credentialsId: 'wfm-mobility-ztest-creds', usernameVariable: 'CLOUD_USERNAME', passwordVariable: 'CLOUD_TOKEN')]) {
                                executeWFMTest(params, env, testPath, teamsWebhookCredentialId)
                            }
                        } else if (selectedCloudPlatform == 'lambdaTest') {
                            withCredentials([usernamePassword(credentialsId: 'wfm-mobility-lambdatest-creds', usernameVariable: 'CLOUD_USERNAME', passwordVariable: 'CLOUD_TOKEN')]) {
                                executeWFMTest(params, env, testPath, teamsWebhookCredentialId)
                            }
                        } else {
                            executeWFMTest(params, env, testPath, teamsWebhookCredentialId)
                        }
                    }
                }
            }
        }
        post {
            always {
                updateDashboardData(params, env, dashboardDataDir, githubTokenCredentialId, dashboardBranch)
                performPostBuildAction(params, env, emailTo, emailCc)
            }
        }
    }
}

/**
 * Executes the WFM test suite with specified parameters and arguments.
 *
 * @param teamsWebhookCredentialId Optional Jenkins Secret text credential ID; when non-empty, binds to
 *        {@code TEST_FAILURE_NOTIFICATION_WEBHOOK} for the decrypt/executor/rebot shell steps only.
 */
def executeWFMTest(params, env, testPath, teamsWebhookCredentialId = '') {
    script {
        env.WFM_EXECUTION_RAN = 'false'
        def credId = (teamsWebhookCredentialId ?: '').trim()
        def runDecryptExecutorAndRebot = {
        // IMPORTANT: After validation/preparation with new functions, values are ALREADY safe.
        // DO NOT re-quote them (this was the root cause of the bug).
        def includeTagCommand = env.SAFE_INCLUDE_TAGS ? "--include-tags ${env.SAFE_INCLUDE_TAGS}" : ""
        def excludeTagCommand = env.SAFE_EXCLUDE_TAGS ? "--exclude-tags ${env.SAFE_EXCLUDE_TAGS}" : ""
        def testrayPlanCommand = env.SAFE_TESTRAY_PLAN ? "--testray-plan ${env.SAFE_TESTRAY_PLAN}" : ""
        def testCycleCommand = env.SAFE_TESTRAY_CYCLE ? "--testray-cycle \"${env.SAFE_TESTRAY_CYCLE}\"" : ""
        def mobilePlatformCommand = (params.MOBILE_PLATFORM == null || params.MOBILE_PLATFORM.trim() == '') ? "" : "--mobile-platform ${params.MOBILE_PLATFORM}"
        def cloudPlatformCommand = (params.CLOUD_PLATFORM == null || params.CLOUD_PLATFORM.trim() == '') ? "" : "--cloud-platform ${params.CLOUD_PLATFORM}"
        def skipDatabaseCommand = params.SKIP_DATABASE_HEALTH_CHECK ? "--skip-database" : ""
        def queueThresholdCommand = "--queue-pending-threshold ${env.QUEUE_PENDING_THRESHOLD}"
        def skipHealthCheckCommand = params.SKIP_HEALTH_CHECK
        // Only emit --retry-count when the caller opted in (> 0). Keeping
        // the flag off the command line entirely when disabled means
        // executor.py takes its byte-identical single-run code path.
        def retryCountValue = (env.RETRY_COUNT ?: '0').toInteger()
        def retryCountCommand = retryCountValue > 0 ? "--retry-count ${retryCountValue}" : ""

        // Use validated env.SUITE_NAME; initializeVariables clears it if invalid
        def suiteNameCommand = env.SUITE_NAME ? "--suite-name ${env.SUITE_NAME}" : ""
        // Note: Do NOT pass --results-dir; executor.py auto-scopes results to results/results_{TEST_ENV}
        def pythonCommand = "python executor.py ${testPath} --validate-user-keys ${includeTagCommand} ${excludeTagCommand} --test-env ${env.TEST_ENV} ${suiteNameCommand} ${testrayPlanCommand} ${testCycleCommand} --processes ${env.PARALLEL_PROCESSES} --skiponfailure applicability_not_met ${mobilePlatformCommand} ${cloudPlatformCommand} ${retryCountCommand}"
        def healthCheckCommand = "python -m dev_utils.run_health_check --test-env ${env.TEST_ENV} --timeout ${env.HEALTH_CHECK_TIMEOUT} ${queueThresholdCommand} ${skipDatabaseCommand}"
        // Pass the actual extraRobotArgs (or empty) to executor for metadata display only
        def extraRobotArgsDisplay = env.SAFE_EXTRA_ROBOT_ARGS ?: ""
        pythonCommand += " --extra-robot-args-display ${ShellSafetyUtils.quote(extraRobotArgsDisplay, env.OS_TYPE)}"
        if (env.SAFE_EXTRA_ROBOT_ARGS) {
                pythonCommand += " ${env.SAFE_EXTRA_ROBOT_ARGS}"
        }

        def decryptCommand = "python decrypt_creds.py --test-env ${env.TEST_ENV}"
        if (skipHealthCheckCommand) {
            echo "Skipping standalone health check for ${env.TEST_ENV}"
        } else {
            echo "Executing health check command: ${healthCheckCommand}"
        }
        echo "Executing command: ${pythonCommand}"

        // Step 1: Decrypt credentials, run standalone health checks, then start executor.
        if (env.OS_TYPE == 'Linux') {
            sh """
                set -e
                /bin/bash -c '
                export PATH=$PATH:/home/symbol/.local/bin
                cd ${env.REPO_LOCATION}
                source .venv/bin/activate > /dev/null 2>&1
                ${decryptCommand}
                ${skipHealthCheckCommand ? 'echo Skipping standalone health check' : healthCheckCommand}
                ${pythonCommand}
                '
            """
        } else if (env.OS_TYPE == 'macOS') {
            sh """
                set -e
                source ~/.zshrc > /dev/null 2>&1
                cd ${env.REPO_LOCATION}
                source .venv/bin/activate > /dev/null 2>&1
                ${decryptCommand}
                ${skipHealthCheckCommand ? 'echo Skipping standalone health check' : healthCheckCommand}
                ${pythonCommand}
            """
        } else if (env.OS_TYPE == 'Windows') {
            bat """
                cd ${env.REPO_LOCATION}
                call .venv\\Scripts\\activate
                ${decryptCommand}
                if errorlevel 1 exit /b 1
                ${skipHealthCheckCommand ? 'echo Skipping standalone health check' : healthCheckCommand}
                ${skipHealthCheckCommand ? 'rem Health check skipped by configuration' : 'if errorlevel 1 exit /b 1'}
                ${pythonCommand}
            """
        } else {
            error "Unsupported OS type: ${env.OS_TYPE}"
        }

        env.WFM_EXECUTION_RAN = 'true'

        // Step 2: Read the actual results directory determined by executor.py
        // This MUST happen before rebot/copy commands to avoid tight coupling
        readAndSetResultsDirectory(env)

        // Step 3: Run rebot and copy artifacts using the actual results directory
        def rebotCommand = "rebot --nostatusrc -x xunit.xml"
        if (env.OS_TYPE == 'Linux') {
            sh """
                set -e
                /bin/bash -c '
                export PATH=$PATH:/home/symbol/.local/bin
                cd ${env.REPO_LOCATION}
                source .venv/bin/activate > /dev/null 2>&1
                ${rebotCommand} -d ${env.RESULT_FOLDER} ${env.RESULT_FOLDER}/output.xml
                cp -v ${env.RESULT_FOLDER}/xunit.xml ${WORKSPACE}
                '
            """
        } else if (env.OS_TYPE == 'macOS') {
            sh """
                set -e
                source ~/.zshrc > /dev/null 2>&1
                cd ${env.REPO_LOCATION}
                source .venv/bin/activate > /dev/null 2>&1
                ${rebotCommand} -d ${env.RESULT_FOLDER} ${env.RESULT_FOLDER}/output.xml
                cp -v ${env.RESULT_FOLDER}/xunit.xml ${WORKSPACE}
            """
        } else if (env.OS_TYPE == 'Windows') {
            bat """
                set "START_DIR=%CD%"
                cd ${env.REPO_LOCATION}
                call .venv\\Scripts\\activate
                ${rebotCommand} -d ${env.RESULT_FOLDER} ${env.RESULT_FOLDER}\\output.xml
                copy "${env.REPO_LOCATION}\\${env.RESULT_FOLDER}\\xunit.xml" "%START_DIR%\\xunit.xml"
            """
        } else {
            error "Unsupported OS type: ${env.OS_TYPE}"
        }
        }
        if (credId) {
            withCredentials([string(credentialsId: credId, variable: 'TEST_FAILURE_NOTIFICATION_WEBHOOK')]) {
                runDecryptExecutorAndRebot()
            }
        } else {
            runDecryptExecutorAndRebot()
        }
    }
}

/**
 * Reads the actual results directory determined by executor.py and updates env.RESULT_FOLDER
 * This ensures Jenkins always uses the exact path that executor.py created.
 * Uses environment and optional suite name to read the specific marker file
 * for this execution (prevents race conditions).
 * Single source of truth: executor.py decides the directory structure.
 */
def readAndSetResultsDirectory(env) {
    script {
        def pathSep = (env.OS_TYPE == 'Windows') ? '\\' : '/'
        def suiteName = env.SUITE_NAME ? env.SUITE_NAME.trim() : ""
        def suiteSuffix = ""
        if (suiteName) {
            if (suiteName ==~ /[A-Za-z0-9._-]+/) {
                suiteSuffix = "_${suiteName}"
            } else {
                echo "Warning: SUITE_NAME contains invalid characters. Using default marker file name."
            }
        }
        def resultsMarkerFile = (
            "${env.REPO_LOCATION}${pathSep}.results_dir_${env.TEST_ENV}${suiteSuffix}.txt"
        )

        if (fileExists(resultsMarkerFile)) {
            try {
                def actualResultsDir = readFile(file: resultsMarkerFile).trim()
                if (actualResultsDir) {
                    env.RESULT_FOLDER = actualResultsDir
                    echo "Results directory from executor.py: ${env.RESULT_FOLDER}"
                    return
                }
            } catch (Exception e) {
                echo "Warning: Failed to read results directory from marker file: ${e.message}"
                echo "Using default results directory: ${env.RESULT_FOLDER}"
            }
        } else {
            echo "Note: Could not find results marker file at ${resultsMarkerFile}. Using default: ${env.RESULT_FOLDER}"
        }
    }
}

def validateParams(params,env){
     script {
        echo "Validating Params..."
        try{
            def testrayPlanPattern = '^WFM-\\d+$'
            def testrayCyclePattern = '^[A-Za-z0-9][A-Za-z0-9 _-]*$'
            env.TEST_ENV = ShellSafetyUtils.validateParameter(
                params.TEST_ENV,
                ShellSafetyUtils.PATTERN_ENV_NAME,
                "TEST_ENV"
            )
            echo "✓ TEST_ENV validated: ${env.TEST_ENV}"
            env.PARALLEL_PROCESSES = ShellSafetyUtils.validateNumeric(
            params.PARALLEL_PROCESSES,
            'PARALLEL_PROCESSES',1,16
            )
             echo "✓ PARALLEL_PROCESSES validated: ${env.PARALLEL_PROCESSES}"
            env.HEALTH_CHECK_TIMEOUT = ShellSafetyUtils.validateNumeric(
                params.HEALTH_CHECK_TIMEOUT,
                'HEALTH_CHECK_TIMEOUT',
                1,
                120
            )
            echo "✓ HEALTH_CHECK_TIMEOUT validated: ${env.HEALTH_CHECK_TIMEOUT}"
            env.QUEUE_PENDING_THRESHOLD = ShellSafetyUtils.validateNumeric(
                params.QUEUE_PENDING_THRESHOLD,
                'QUEUE_PENDING_THRESHOLD',
                0,
                100000
            )
            echo "✓ QUEUE_PENDING_THRESHOLD validated: ${env.QUEUE_PENDING_THRESHOLD}"
            env.RETRY_COUNT = ShellSafetyUtils.validateNumeric(
                params.RETRY_COUNT ?: '0',
                'RETRY_COUNT',
                0,
                3
            )
            echo "✓ RETRY_COUNT validated: ${env.RETRY_COUNT}"
            if (params.DASHBOARD_ENV_NAME?.trim()) {
                env.SAFE_DASHBOARD_ENV_NAME = ShellSafetyUtils.validateParameter(
                    params.DASHBOARD_ENV_NAME,
                    ShellSafetyUtils.PATTERN_ENV_NAME,
                    "DASHBOARD_ENV_NAME"
                )
                echo "✓ DASHBOARD_ENV_NAME validated: ${env.SAFE_DASHBOARD_ENV_NAME}"
            }
            // ========== OPTIONAL TAG VALIDATIONS ==========
            // Use validateAndPrepareRobotTags: returns plain comma-separated tags (NO quotes)
            if (params.INCLUDE_TAGS?.trim()) {
                env.SAFE_INCLUDE_TAGS = ShellSafetyUtils.validateAndPrepareRobotTags(params.INCLUDE_TAGS, "INCLUDE_TAGS")
                echo "✓ INCLUDE_TAGS validated: ${env.SAFE_INCLUDE_TAGS}"
            }

            if (params.EXCLUDE_TAGS?.trim()) {
                env.SAFE_EXCLUDE_TAGS = ShellSafetyUtils.validateAndPrepareRobotTags(params.EXCLUDE_TAGS, "EXCLUDE_TAGS")
                echo "✓ EXCLUDE_TAGS validated: ${env.SAFE_EXCLUDE_TAGS}"
            }

            // Use validateAndPrepareExtraRobotArgs: intelligently handles quoting
            if (params.EXTRA_ROBOT_ARGS?.trim()) {
                env.SAFE_EXTRA_ROBOT_ARGS = ShellSafetyUtils.validateAndPrepareExtraRobotArgs(params.EXTRA_ROBOT_ARGS ?: '', "EXTRA_ROBOT_ARGS")
                echo "✓ EXTRA_ROBOT_ARGS validated: ${env.SAFE_EXTRA_ROBOT_ARGS}"
            }
            if (params.TESTRAY_PLAN?.trim()) {
                env.SAFE_TESTRAY_PLAN = ShellSafetyUtils.validateParameter(
                    params.TESTRAY_PLAN,
                    testrayPlanPattern,
                    "TESTRAY_PLAN"
                )
                echo "✓ TESTRAY_PLAN validated: ${env.SAFE_TESTRAY_PLAN}"
            }
            if (params.TESTRAY_CYCLE?.trim()) {
                env.SAFE_TESTRAY_CYCLE = ShellSafetyUtils.validateParameter(
                    params.TESTRAY_CYCLE,
                    testrayCyclePattern,
                    "TESTRAY_CYCLE"
                )
                echo "✓ TESTRAY_CYCLE validated: ${env.SAFE_TESTRAY_CYCLE}"
            }
            if (params.SUITE_NAME?.trim()) {
                env.SUITE_NAME = ShellSafetyUtils.validateParameter(
                    params.SUITE_NAME,
                    ShellSafetyUtils.PATTERN_ENV_NAME,
                    "SUITE_NAME",
                    true
                )
                echo "✓ SUITE_NAME validated: ${env.SUITE_NAME}"
            }
        }catch (IllegalArgumentException e) {
            error("❌ Parameter validation failed: ${e.message}")
        }
     }
}
/**
 * Setup stage for Any Repository.
 */
def initializeVariables(params, env, resultsFolderName, repoDirName) {
    script {
        echo "Initializing variables..."
        def osType = ''
        def repoLocation = ''
        def robotResultFolder = ''
        def hostname = ''
        def suiteName = env.SUITE_NAME ? env.SUITE_NAME.trim() : ""
        def suiteSuffix = ""
        if (suiteName) {
            suiteSuffix = "_${suiteName}"
        }
        if (isUnix()) {
            def osName = sh(script: 'uname', returnStdout: true).trim()
            hostname = sh(script: 'hostname', returnStdout: true).trim()
            if (osName == 'Darwin') {
                osType = 'macOS'
                repoLocation = "/Users/symbol/RFS_CI/GIT_REPO/${repoDirName}"
            } else {
                osType = 'Linux'
                repoLocation = "/home/symbol/RFS_CI/GIT_REPO/${repoDirName}"
            }
        } else {
            osType = 'Windows'
            hostname = bat(script: '@echo off & for /f "tokens=*" %%i in (\'hostname\') do @echo %%i', returnStdout: true).trim()
            repoLocation = "C:\\RFS_CI\\GIT_REPO\\${repoDirName}"
        }
        env.OS_TYPE = osType
        env.REPO_LOCATION = repoLocation

        env.SUITE_NAME = suiteName
        // Note: Results directory is determined by executor.py and written to
        // .results_dir_{TEST_ENV}_{SUITE_NAME}.txt when suite name is provided.
        // We set a default here, but it will be overwritten by executeWFMTest if the file exists
        env.RESULT_FOLDER = "results/results_${env.TEST_ENV}${suiteSuffix}"
        env.WFM_EXECUTION_RAN = 'false'
        env.AGENT_HOSTNAME = hostname
        echo "OS Type : ${osType}"
        echo "Repo Location on agent : ${env.REPO_LOCATION}"
        echo "Results Folder Name (default) : ${env.RESULT_FOLDER}"
    }
}

/**
 * True when executor.py completed for this build (health check / decrypt failures keep this false).
 */
def testExecutionCompleted(env) {
    return (env.WFM_EXECUTION_RAN ?: 'false') == 'true'
}

/**
 * Generates a BAT triage HTML report from the latest output.xml.
 * Writes the report into the results folder and copies it to WORKSPACE for email attachment.
 * @return workspace-relative attachment pattern on success, null otherwise
 */
def generateBatTriageReport(env, outputPath) {
    script {
        if (!testExecutionCompleted(env)) {
            echo 'BAT triage skipped - test execution did not run for this build'
            return null
        }
        def pathSep = (env.OS_TYPE == 'Windows') ? '\\' : '/'
        def outputFile = "${outputPath}${pathSep}output.xml"
        def triageScript = "${env.REPO_LOCATION}${pathSep}dev_utils${pathSep}triage${pathSep}bat_triage.py"
        def reportInResults = "${outputPath}${pathSep}bat_triage_report.html"
        def reportJsonInResults = "${outputPath}${pathSep}bat_triage_report.json"
        def reportInWorkspace = "${WORKSPACE}${pathSep}bat_triage_report.html"

        if (!fileExists(outputFile)) {
            echo "BAT triage skipped - output.xml not found at ${outputFile}"
            return null
        }
        if (!fileExists(triageScript)) {
            echo "BAT triage skipped - script not found at ${triageScript}"
            return null
        }

        try {
            if (env.OS_TYPE == 'Windows') {
                bat """
                    @echo off
                    cd ${env.REPO_LOCATION}
                    call .venv\\Scripts\\activate
                    python dev_utils\\triage\\bat_triage.py "${outputPath}" --html "${reportInResults}" --json "${reportJsonInResults}"
                    if errorlevel 1 exit /b 1
                    copy /Y "${reportInResults}" "${reportInWorkspace}"
                """
            } else if (env.OS_TYPE == 'macOS') {
                sh """
                    set -e
                    cd ${env.REPO_LOCATION}
                    source .venv/bin/activate
                    python3 dev_utils/triage/bat_triage.py "${outputPath}" --html "${reportInResults}" --json "${reportJsonInResults}"
                    cp "${reportInResults}" "${reportInWorkspace}"
                """
            } else {
                sh """
                    set -e
                    cd ${env.REPO_LOCATION}
                    . .venv/bin/activate
                    python3 dev_utils/triage/bat_triage.py "${outputPath}" --html "${reportInResults}" --json "${reportJsonInResults}"
                    cp "${reportInResults}" "${reportInWorkspace}"
                """
            }

            if (fileExists(reportInWorkspace)) {
                echo "BAT triage report generated: ${reportInResults}"
                return 'bat_triage_report.html'
            }
        } catch (Exception e) {
            echo "Warning: BAT triage report generation failed (email will continue without attachment): ${e.message}"
        }
        return null
    }
}

/**
 * Generates BAT Test Evidence Report HTML from the latest output.xml.
 * @return workspace-relative attachment pattern on success, null otherwise
 */
def generateEvidenceReport(params, env, outputPath) {
    script {
        if (!testExecutionCompleted(env)) {
            echo 'BAT evidence report skipped - test execution did not run for this build'
            return null
        }
        def pathSep = (env.OS_TYPE == 'Windows') ? '\\' : '/'
        def outputFile = "${outputPath}${pathSep}output.xml"
        def evidenceScript = "${env.REPO_LOCATION}${pathSep}dev_utils${pathSep}generate_evidence_report.py"
        def reportInResults = "${outputPath}${pathSep}evidence_report.html"
        def reportInWorkspace = "${WORKSPACE}${pathSep}evidence_report.html"
        def envConfig = "${env.REPO_LOCATION}${pathSep}test_data${pathSep}environments${pathSep}${params.TEST_ENV}${pathSep}evidence_report_config.json"
        def configArg = fileExists(envConfig) ? "--config \"${envConfig}\"" : ''
        def buildUrlArg = env.BUILD_URL ? "--build-url \"${env.BUILD_URL}\"" : ''
        def testrayCycleArg = params.TESTRAY_CYCLE ? "--testray-cycle \"${params.TESTRAY_CYCLE}\"" : ''
        def testrayPlanArg = params.TESTRAY_PLAN ? "--testray-plan \"${params.TESTRAY_PLAN}\"" : ''
        def jobNameArg = env.JOB_NAME ? "--job-name \"${env.JOB_NAME}\"" : ''
        def pipelineType = 'bat'
        if ((env.JOB_NAME ?: '').toUpperCase().contains('SIT') || (params.INCLUDE_TAGS ?: '').toLowerCase().contains('sit')) {
            pipelineType = 'sit'
        }
        def pipelineTypeArg = "--pipeline-type ${pipelineType}"
        def mobilePlatformArg = (params.MOBILE_PLATFORM ?: '').trim() ? "--mobile-platform \"${params.MOBILE_PLATFORM}\"" : ''
        def buildNumberArg = env.BUILD_NUMBER ? "--build-number \"${env.BUILD_NUMBER}\"" : ''
        def nodeNameArg = env.NODE_NAME ? "--node-name \"${env.NODE_NAME}\"" : ''
        def includeTagsArg = params.INCLUDE_TAGS ? "--include-tags \"${params.INCLUDE_TAGS}\"" : ''
        def excludeTagsArg = params.EXCLUDE_TAGS ? "--exclude-tags \"${params.EXCLUDE_TAGS}\"" : ''
        def parallelArg = params.PARALLEL_PROCESSES ? "--parallel-processes \"${params.PARALLEL_PROCESSES}\"" : ''
        def gitCommitArg = env.GIT_COMMIT ? "--git-commit \"${env.GIT_COMMIT}\"" : ''
        def extraArgs = "${configArg} ${buildUrlArg} ${testrayCycleArg} ${testrayPlanArg} ${jobNameArg} ${pipelineTypeArg} ${mobilePlatformArg} ${buildNumberArg} ${nodeNameArg} ${includeTagsArg} ${excludeTagsArg} ${parallelArg} ${gitCommitArg}".trim()

        if (!fileExists(outputFile)) {
            echo "BAT evidence report skipped - output.xml not found at ${outputFile}"
            return null
        }
        if (!fileExists(evidenceScript)) {
            echo "BAT evidence report skipped - script not found at ${evidenceScript}"
            return null
        }

        try {
            if (env.OS_TYPE == 'Windows') {
                bat """
                    @echo off
                    cd ${env.REPO_LOCATION}
                    call .venv\\Scripts\\activate
                    python dev_utils\\generate_evidence_report.py --input "${outputPath}" --output "${reportInResults}" --test-env "${params.TEST_ENV}" ${extraArgs}
                    if errorlevel 1 exit /b 1
                    copy /Y "${reportInResults}" "${reportInWorkspace}"
                """
            } else if (env.OS_TYPE == 'macOS') {
                sh """
                    set -e
                    cd ${env.REPO_LOCATION}
                    source .venv/bin/activate
                    python3 dev_utils/generate_evidence_report.py --input "${outputPath}" --output "${reportInResults}" --test-env "${params.TEST_ENV}" ${extraArgs}
                    cp "${reportInResults}" "${reportInWorkspace}"
                """
            } else {
                sh """
                    set -e
                    cd ${env.REPO_LOCATION}
                    . .venv/bin/activate
                    python3 dev_utils/generate_evidence_report.py --input "${outputPath}" --output "${reportInResults}" --test-env "${params.TEST_ENV}" ${extraArgs}
                    cp "${reportInResults}" "${reportInWorkspace}"
                """
            }

            if (fileExists(reportInWorkspace)) {
                echo "BAT evidence report generated: ${reportInResults}"
                return 'evidence_report.html'
            }
        } catch (Exception e) {
            echo "Warning: BAT evidence report generation failed (email will continue without attachment): ${e.message}"
        }
        return null
    }
}

/**
 * Strip cc:/bcc: prefixes and normalize comma-separated email lists for emailext.
 */
def normalizeEmailList(String raw) {
    if (!raw?.trim()) {
        return ''
    }
    return raw.split(/[,;\s]+/)
        .collect { it?.trim()?.replaceAll(/(?i)^(cc|bcc):\s*/, '') }
        .findAll { it }
        .unique()
        .join(',')
}

/**
 * Combine To and CC lists for emailext (older Email Extension builds do not support a cc: step parameter).
 */
def combineEmailRecipients(String toList, String ccList) {
    def recipients = []
    if (toList?.trim()) {
        recipients.addAll(normalizeEmailList(toList).split(','))
    }
    if (ccList?.trim()) {
        recipients.addAll(normalizeEmailList(ccList).split(','))
    }
    return recipients.collect { it?.trim() }.findAll { it }.unique().join(',')
}

/**
 * Send pipeline email with optional build-requester recipient.
 */
def sendPipelineEmail(Map cfg) {
    script {
        def toField = combineEmailRecipients(cfg.to ?: '', cfg.cc ?: '')
        def mailArgs = [
            body: cfg.body ?: '',
            mimeType: 'text/html',
            subject: cfg.subject ?: '$DEFAULT_SUBJECT',
            to: toField,
        ]
        if (cfg.attachmentsPattern?.trim()) {
            mailArgs.attachmentsPattern = cfg.attachmentsPattern
        }
        if (cfg.requester) {
            mailArgs.recipientProviders = [[$class: 'RequesterRecipientProvider']]
        }
        echo "Post-build email — to: ${toField}"
        if (cfg.cc?.trim()) {
            echo "Post-build email — cc (merged into to): ${normalizeEmailList(cfg.cc)}"
        }
        if (mailArgs.attachmentsPattern) {
            echo "Post-build email — attachments: ${mailArgs.attachmentsPattern}"
        }
        emailext(mailArgs)
        echo 'Post-build email dispatched.'
    }
}

/**
 * Performs post-build actions.
 */
def performPostBuildAction(params, env, emailTo, emailCc) {
    script {
        def pathSep = (env.OS_TYPE == 'Windows') ? '\\' : '/'
        def outputPath = "${env.REPO_LOCATION}${pathSep}${env.RESULT_FOLDER}"
        def outputFile = "${outputPath}${pathSep}output.xml"
        def emailSubject = '$DEFAULT_SUBJECT'
        def emailBody
        def emailAttachments = []
        def isAborted = currentBuild?.currentResult == 'ABORTED'

        if (isAborted) {
            emailSubject = "⛔ WFM QA Automation Pipeline Aborted - ${params.TEST_ENV} - Build #${env.BUILD_NUMBER}"
            emailBody = """
            <html>
            <body>
            <p>Hi,</p>
            <p><strong>The Jenkins pipeline was aborted.</strong></p>
            <p><strong>Environment:</strong> ${params.TEST_ENV}</p>
            <p><strong>Build Number:</strong> <a href="${env.BUILD_URL}">#${env.BUILD_NUMBER}</a></p>
            <p><strong>Impact:</strong> Test execution and post-run steps may be incomplete.</p>
            <p>Please check the <a href="${env.BUILD_URL}">Jenkins job</a> for details.</p>
            <p>Regards,<br>WFM Automation Team</p>
            </body>
            </html>
            """

            sendPipelineEmail(
                subject: emailSubject,
                body: emailBody,
                to: emailTo,
                cc: emailCc,
                requester: true
            )
            return
        }

        if (!testExecutionCompleted(env)) {
            echo 'Skipping post-run reports and metrics — test execution did not run (health check or pre-executor failure).'
            emailSubject = "⚠️ WFM QA Automation — Test execution did not start - ${params.TEST_ENV} - Build #${env.BUILD_NUMBER}"
            emailBody = """
            <html>
            <body>
            <p>Hi,</p>
            <p><strong>Test execution did not run for this build.</strong></p>
            <p>Triage and evidence reports were not generated because Robot Framework did not start — typically due to a failed pre-execution health check, credential decryption failure, or another setup error before test execution.</p>
            <p><strong>Environment:</strong> ${params.TEST_ENV}</p>
            <p><strong>Build Number:</strong> <a href="${env.BUILD_URL}">#${env.BUILD_NUMBER}</a></p>
            <p>Please check the <a href="${env.BUILD_URL}">Jenkins job</a> console log for details.</p>
            <p>Regards,<br>WFM Automation Team</p>
            </body>
            </html>
            """

            sendPipelineEmail(
                subject: emailSubject,
                body: emailBody,
                to: emailTo,
                cc: emailCc,
                requester: true
            )
            return
        }

        try {
            junit skipMarkingBuildUnstable: true, testResults: 'xunit.xml'

            robot outputPath: outputPath,
                  passThreshold: 10.0,
                  unstableThreshold: 75.0,
                  countSkippedTests: true

            if (fileExists(outputFile)) {
                def triageAttachment = generateBatTriageReport(env, outputPath)
                if (triageAttachment) {
                    emailAttachments << triageAttachment
                }
                def evidenceAttachment = generateEvidenceReport(params, env, outputPath)
                if (evidenceAttachment) {
                    emailAttachments << evidenceAttachment
                }

                // Calculate success rate from output.xml
                def successRate = '0.0'
                try {
                    def xmlFile = readFile(file: outputFile)
                    def xml = new XmlSlurper().parseText(xmlFile)

                    // Navigate to statistics.total.stat element
                    def stat = xml.statistics.total.stat
                    def passCount = stat.@pass.toInteger()
                    def skipCount = stat.@skip.toInteger()
                    def failCount = stat.@fail.toInteger()
                    def totalCount = passCount + failCount + skipCount

                    echo "Success Rate Calculation - Pass: ${passCount}, Skip: ${skipCount}, Fail: ${failCount}, Total: ${totalCount}"

                    if (totalCount > 0) {
                        successRate = String.format("%.1f", ((skipCount + passCount) / (double)totalCount * 100))
                        echo "Success Rate: ${successRate}%"
                    }
                } catch (Exception e) {
                    echo "Warning: Could not parse success rate from output.xml: ${e.message}"
                    e.printStackTrace()
                }

                // Optional retry summary fragment. When retry_count was 0
                // (or the initial run passed cleanly) executor.py will not
                // create this file, and the email body stays byte-identical
                // to the pre-retry-feature behavior.
                def retrySummaryFile = "${outputPath}${pathSep}retry_summary.html"
                def retrySummaryFragment = ''
                if (fileExists(retrySummaryFile)) {
                    try {
                        retrySummaryFragment = readFile(file: retrySummaryFile)
                        echo "Included retry summary fragment from ${retrySummaryFile}"
                    } catch (Exception e) {
                        echo "Warning: Could not read retry summary fragment: ${e.message}"
                        retrySummaryFragment = ''
                    }
                }

                emailBody = """
                Hi,
                <!DOCTYPE html>
                <html>
                <head>
                    <style>
                    table {
                    font-family: arial, sans-serif;
                    border-collapse: collapse;
                    }

                    td, th {
                    border: 1px solid #dddddd;
                    text-align: left;
                    padding: 8px;
                    }

                    tr:first-child {
                    background-color: #dddddd;
                    }
                    </style>
                </head>
                <body>
                    <p>\${PROJECT_NAME} - Test Run Completed </p>
                    <h3>Run Results</h3>
                    <table>
                        <tr>
                            <th>Total</th>
                            <th>Pass</th>
                            <th>Fail</th>
                            <th>Skip</th>
                            <th>Success Rate</th>
                            <th>Report Link</th>
                            <th>Job Link</th>
                        </tr>
                        <tr>
                            <td>\${TEST_COUNTS,var="total"}</td>
                            <td>\${TEST_COUNTS,var="pass"}</td>
                            <td>\${TEST_COUNTS,var="fail"}</td>
                            <td>\${TEST_COUNTS,var="skip"}</td>
                            <td>${successRate}</td>
                            <td><a href=\${ROBOT_REPORTLINK}>Robot_Report</a></td>
                            <td><a href=\${BUILD_URL}>Jenkins_Job</a></td>
                        </tr>
                     </table>
                     <br>
                     ${emailAttachments ? '<p><strong>Attached reports:</strong></p><ul>' +
                        (emailAttachments.contains('bat_triage_report.html') ? '<li><code>bat_triage_report.html</code> — failure categories and skip analysis</li>' : '') +
                        (emailAttachments.contains('evidence_report.html') ? '<li><code>evidence_report.html</code> — test evidence with module-wise summary and per-test results</li>' : '') +
                        '</ul>' : ''}
                     ${retrySummaryFragment}
                    </body>
                </html>
                <br>

                 <p>Regards,<br>WFM Automation Team</p>
                """

            } else {
                emailBody = '''
                <html>
                <body>
                <p>Hi,</p>
                <p>The Jenkins job has completed, but no detailed test results were found.</p>
                <p>Please check the Jenkins job for more details: <a href="$BUILD_URL">Jenkins Job</a></p>
                <p>Regards,<br>WFM Automation Team</p>
                </body>
                </html>
                '''
            }
        } catch (Exception e) {
            e.printStackTrace()
            echo "Some error in postbuild action. Sending email with error details: ${e.message}"
            emailBody = '''
            <html>
            <body>
            <p>Hi,</p>
            <p>An error occurred during the Jenkins job execution.</p>
            <p>Please check the Jenkins job for more details: <a href="$BUILD_URL">Jenkins Job</a></p>
            <p>Regards,<br>WFM Automation Team</p>
            </body>
            </html>
            '''
        } finally {
            if (!emailBody) {
                emailBody = '''
                <html>
                <body>
                <p>Hi,</p>
                <p>The Jenkins job has completed.</p>
                <p>Please check the Jenkins job for more details: <a href="$BUILD_URL">Jenkins Job</a></p>
                <p>Regards,<br>WFM Automation Team</p>
                </body>
                </html>
                '''
            }
            def mailCfg = [
                subject: emailSubject,
                body: emailBody,
                to: emailTo,
                cc: emailCc,
                requester: true,
            ]
            if (emailAttachments) {
                mailCfg.attachmentsPattern = emailAttachments.join(',')
            }
            sendPipelineEmail(mailCfg)
        }
    }
}

def updateDashboardData(params, env, dashboardDataDir, githubTokenCredentialId, dashboardBranch) {
    script {
        if (!params.PUBLISH_DASHBOARD) {
            echo "Dashboard update disabled."
            return
        }

        if (!testExecutionCompleted(env)) {
            echo 'Dashboard update skipped — test execution did not run for this build.'
            return
        }

        // Note: Dashboard data is updated to the dashboard-data orphan branch.
        // This dedicated, lightweight branch keeps dashboard metrics isolated from main branch and gh-pages.
        // Benefits:
        // 1. Main branch remains protected and unaffected
        // 2. dashboard-data branch is fresh with no history, focused on data only
        // 3. No conflict with gh-pages (used for keyword info)
        // 4. Clean, atomic updates: only JSON files are committed
        // 5. Easy to reset or archive if needed

        def targetBranch = dashboardBranch
        def envName = env.SAFE_DASHBOARD_ENV_NAME ?: env.TEST_ENV

        // Use OS-appropriate path separators
        def pathSep = (env.OS_TYPE == 'Windows') ? '\\' : '/'
        def outputPath = "${env.REPO_LOCATION}${pathSep}${env.RESULT_FOLDER}"
        def outputFile = "${outputPath}${pathSep}output.xml"
        def dashboardUpdaterPy = "${env.REPO_LOCATION}${pathSep}dev_utils${pathSep}dashboard_results_updater.py"
        def dashboardRunTypePy = "${env.REPO_LOCATION}${pathSep}dev_utils${pathSep}dashboard_run_type.py"
        def testDetailsUpdaterPy = "${env.REPO_LOCATION}${pathSep}dev_utils${pathSep}test_results_parser.py"
        def buildUrl = env.BUILD_URL ?: ''
        def includeTagsArg = params.INCLUDE_TAGS ? "--include-tags \"${params.INCLUDE_TAGS}\"" : ''

        echo "=== Dashboard Update Debug Info ==="
        echo "Target Branch: ${targetBranch}"
        echo "Environment Name: ${envName}"
        echo "Output File: ${outputFile}"
        echo "Dashboard Updater Script: ${dashboardUpdaterPy}"
        echo "Test Details Updater Script: ${testDetailsUpdaterPy}"
        echo "OS Type: ${env.OS_TYPE}"
        echo "==================================="

        if (!fileExists(outputFile)) {
            echo "Dashboard update skipped. Output XML not found at ${outputFile}."
            return
        }

        if (!fileExists(dashboardUpdaterPy)) {
            echo "Dashboard update skipped. dashboard_results_updater.py not found at ${dashboardUpdaterPy}."
            return
        }

        echo "Both output.xml and dashboard_results_updater.py exist. Proceeding with update..."

        withCredentials([usernamePassword(credentialsId: githubTokenCredentialId, passwordVariable: 'GIT_PAT', usernameVariable: 'GIT_USERNAME')]) {
            if (env.OS_TYPE == 'Windows') {
                bat """
                    @echo off
                    setlocal enabledelayedexpansion
                    set "START_DIR=%CD%"

                    echo ========================================
                    echo Dashboard Update - Windows Batch Script
                    echo ========================================
                    echo START_DIR: %START_DIR%
                    echo.

                    REM Create a dedicated workspace for dashboard updates to avoid conflicts with main branch
                    for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set mydate=%%d%%b%%c)
                    set "mytime=%time:~0,2%%time:~3,2%%time:~6,2%"
                    set "mytime=!mytime: =0!"
                    set "DASHBOARD_WORK_DIR=%TEMP%\\wfm_dashboard_!mydate!_!mytime!_!RANDOM!"

                    echo Creating temp workspace: !DASHBOARD_WORK_DIR!
                    if not exist "!DASHBOARD_WORK_DIR!" mkdir "!DASHBOARD_WORK_DIR!"

                    REM Configure git to trust the temp directory (Windows security)
                    git config --global --add safe.directory "!DASHBOARD_WORK_DIR!"

                    echo Changing to temp workspace...
                    cd /d "!DASHBOARD_WORK_DIR!"
                    echo Current directory: %CD%
                    echo.

                    REM Clone only the targetBranch branch (shallow, single branch)
                    echo Cloning ${targetBranch} branch...
                    git clone --single-branch --branch ${targetBranch} --depth 1 https://%GIT_USERNAME%:%GIT_PAT%@github.com/zebratechnologies/sws_wfm_test_automation.git .
                    if errorlevel 1 (
                        echo Error: Failed to clone ${targetBranch} branch. Ensure the branch exists.
                        exit /b 1
                    )

                    REM Verify git repository was cloned successfully
                    if not exist ".git" (
                        echo Error: Git repository not properly cloned - .git directory missing
                        exit /b 1
                    )

                    echo Git clone successful.
                    echo Current directory after clone: %CD%
                    dir
                    echo.

                    echo Creating docs\\dashboard\\data directory...
                    if not exist "docs\\dashboard\\data" mkdir "docs\\dashboard\\data"
                    echo.

                    REM Copy the dashboard updater script from the main workspace
                    echo Preparing to copy dashboard updater script...
                    echo Source: ${dashboardUpdaterPy}
                    echo Target: %CD%\\dashboard_results_updater.py
                    echo.

                    if not exist "${dashboardUpdaterPy}" (
                        echo ERROR: Source file does not exist: ${dashboardUpdaterPy}
                        exit /b 1
                    )
                    echo Source file exists. Copying...

                    copy "${dashboardUpdaterPy}" ".\\dashboard_results_updater.py"
                    if errorlevel 1 (
                        echo Error: Failed to copy dashboard updater script
                        echo Copy command exit code: %ERRORLEVEL%
                        exit /b 1
                    )
                    echo Copy successful.

                    if not exist "${dashboardRunTypePy}" (
                        echo ERROR: Source file does not exist: ${dashboardRunTypePy}
                        exit /b 1
                    )
                    copy "${dashboardRunTypePy}" ".\\dashboard_run_type.py"
                    if errorlevel 1 (
                        echo Error: Failed to copy dashboard run type helper
                        exit /b 1
                    )
                    REM Copy the test details updater script from the main workspace
                    echo Preparing to copy test details updater script...
                    echo Source: ${testDetailsUpdaterPy}
                    echo Target: %CD%\\test_results_parser.py
                    echo.

                    if not exist "${testDetailsUpdaterPy}" (
                        echo ERROR: Source file does not exist: ${testDetailsUpdaterPy}
                        exit /b 1
                    )
                    echo Source file exists. Copying...

                    copy "${testDetailsUpdaterPy}" ".\\test_results_parser.py"
                    if errorlevel 1 (
                        echo Error: Failed to copy test details updater script
                        echo Copy command exit code: %ERRORLEVEL%
                        exit /b 1
                    )
                    echo Copy successful.
                    echo.

                    REM Activate Python environment from main workspace
                    echo Activating Python environment...
                    echo venv path: ${env.REPO_LOCATION}\\.venv\\Scripts\\activate
                    call "${env.REPO_LOCATION}\\.venv\\Scripts\\activate"
                    if errorlevel 1 (
                        echo Error: Failed to activate Python environment
                        exit /b 1
                    )
                    echo Python environment activated.
                    echo.

                    REM Run the updater
                    echo Running dashboard updater...
                    echo Command: python dashboard_results_updater.py --output-xml "${outputFile}" --env-name "${envName}" --data-dir "docs\\dashboard\\data" ${includeTagsArg}
                    python dashboard_results_updater.py --output-xml "${outputFile}" --env-name "${envName}" --data-dir "docs\\dashboard\\data" ${includeTagsArg}
                    if errorlevel 1 (
                        echo Error: dashboard_results_updater.py failed.
                        exit /b 1
                    )
                    echo Dashboard updater completed successfully.
                    echo.

                    echo Command: python test_results_parser.py --output-xml "${outputFile}" --env-name "${envName}" --data-dir "docs\\dashboard\\data" --build-url "${buildUrl}"
                    python test_results_parser.py --output-xml "${outputFile}" --env-name "${envName}" --data-dir "docs\\dashboard\\data" --build-url "${buildUrl}"
                    if errorlevel 1 (
                        echo Error: test_results_parser.py failed.
                        exit /b 1
                    )
                    echo Test results parser completed successfully.
                    echo.

                    REM Check for changes
                    echo Checking for changes in dashboard data...
                    git status
                    if errorlevel 1 (
                        echo Error: Git status failed - not in a git repository
                        exit /b 1
                    )

                    git diff --quiet -- docs\\dashboard\\data
                    if errorlevel 1 (
                        echo Dashboard data changed. Committing and pushing...
                        git add docs\\dashboard\\data\\environments.json docs\\dashboard\\data\\history.json docs\\dashboard\\data\\env_history.json
                        git add docs\\dashboard\\data\\test_results.json
                        if errorlevel 1 (
                            echo Error: Failed to stage files
                            exit /b 1
                        )

                        git config user.email "kg9078@zebra.com"
                        git config user.name "wfm-dashboard-bot"
                        git commit -m "chore(dashboard): update ${envName} results (%DATE% %TIME%)"
                        if errorlevel 1 (
                            echo Error: Failed to commit changes
                            exit /b 1
                        )

                        echo Pushing to ${targetBranch}...
                        git push https://%GIT_USERNAME%:%GIT_PAT%@github.com/zebratechnologies/sws_wfm_test_automation.git HEAD:${targetBranch}
                        if errorlevel 1 (
                            echo Error: Failed to push to remote
                            exit /b 1
                        )
                        echo Dashboard data published successfully.
                    ) else (
                        echo No dashboard data changes to publish.
                    )
                    echo.

                    echo Cleaning up temp workspace...
                    cd "%START_DIR%"
                    rmdir /s /q "!DASHBOARD_WORK_DIR!"
                    echo Cleanup complete.
                    echo ========================================
                """
            } else {
                sh """
                    set -e
                    START_DIR=\$(pwd)

                    # Create a dedicated workspace for dashboard updates to avoid conflicts with main branch
                    DASHBOARD_WORK_DIR=\$(mktemp -d)
                    trap "rm -rf \$DASHBOARD_WORK_DIR" EXIT

                    cd "\$DASHBOARD_WORK_DIR"

                    # Clone only the gh-pages branch (shallow, single branch)
                    echo "Cloning ${targetBranch} branch from repository..."
                    git clone --single-branch --branch ${targetBranch} --depth 1 https://${GIT_USERNAME}:${GIT_PAT}@github.com/zebratechnologies/sws_wfm_test_automation.git .

                    mkdir -p docs/dashboard/data

                    # Copy the dashboard updater script from the main workspace
                    cp "${dashboardUpdaterPy}" ./dashboard_results_updater.py
                    cp "${dashboardRunTypePy}" ./dashboard_run_type.py
                    cp "${testDetailsUpdaterPy}" ./test_results_parser.py

                    # Activate Python environment from main workspace
                    . ${env.REPO_LOCATION}/.venv/bin/activate

                    # Run the updater
                    echo "Updating dashboard data for environment: ${envName}"
                    python dashboard_results_updater.py --output-xml "${outputFile}" --env-name "${envName}" --data-dir "docs/dashboard/data" ${includeTagsArg}
                    echo "Dashboard updater completed successfully."
                    echo "Parsing test results for dashboard details..."
                    python test_results_parser.py --output-xml "${outputFile}" --env-name "${envName}" --data-dir "docs/dashboard/data" --build-url "${buildUrl}"

                    # Check for changes
                    if git diff --quiet -- docs/dashboard/data/environments.json docs/dashboard/data/history.json docs/dashboard/data/env_history.json docs/dashboard/data/test_results.json ; then
                        echo "No dashboard data changes to publish."
                    else
                        echo "Dashboard data changed. Committing and pushing..."
                        git add docs/dashboard/data/environments.json docs/dashboard/data/history.json docs/dashboard/data/env_history.json docs/dashboard/data/test_results.json
                        git config user.email "kg9078@zebra.com"
                        git config user.name "wfm-dashboard-bot"
                        git commit -m "chore(dashboard): update ${envName} results"
                        git push https://${GIT_USERNAME}:${GIT_PAT}@github.com/zebratechnologies/sws_wfm_test_automation.git HEAD:${targetBranch}
                        echo "Dashboard data published successfully."
                    fi

                    cd "\$START_DIR"
                """
            }
        }
    }
}

def gitCheckout(env) {
    script {
        dir(env.REPO_LOCATION) {
            checkout scm
        }
    }
}

return this
