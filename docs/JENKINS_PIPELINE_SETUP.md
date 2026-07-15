# Jenkins Pipeline for WFM Automation

This document describes the Jenkins pipeline setup for the WFM Robot Framework test automation project.

**JENKINS URL** : http://10.123.210.131:9090/login?from=%2F
For Login details please contact : Munish Kumar / Abhishek Pundikar

## Overview
We are using Jenkins shared library to define a pipeline for executing Robot Framework tests from this repository.
The pipeline stages remain same across different enviroments, only parameters change.
The pipeline is defined in `jenkins-lib/vars/wfmQAPuneJenkins.groovy`.
For each customer environment, a separate Jenkins job is created that calls this shared library with environment-specific parameters.

By default, the shared library now performs a standalone health-check gate (`python -m dev_utils.run_health_check`) before invoking `executor.py`. If the health check fails, test execution does not start.
You can configure this per environment in each `BAT_Jenkinsfile` using `healthCheckTimeout`, `skipDatabaseHealthCheck`, and `queuePendingThreshold` (default `100`).
If a specific job must bypass the health-check step entirely, set `skipHealthCheck: true` in the environment Jenkinsfile (for example, payroll replay jobs such as `BP_DRYRUN/Payroll_Replay_Jenkinsfile` and `HNM_DRYRUN/Payroll_Replay_Jenkinsfile`).

## Setting up a Jenkins Job for a New Environment
1. **Create Jenkins File**
   - In the repository, create a new Jenkinsfile for the specific environment under test_data/environments/{ENV_NAME}/YourJenkinsfile.
   - This file should call the shared library with parameters for that environment.
   - Example: `test_data\environments\QA29_B0\BAT_Jenkinsfile`
   - For any specific override parameters required for that enviroment refer documentation from jenkins-lib/vars/wfmQAPuneJenkins.groovy and update the same in the newly created Jenkinsfile.


2.  **Create a New Jenkins Job**:
    - Go to Jenkins dashboard and create a new Pipeline job (New Item).
    - Select "Pipeline" and provide a name (e.g., `WFM_Sanity_<CUSTOMER_NAME>_<ENV_TYPE>`).
    - Copy From - Existing Job: You can copy from an existing job like `WFM Sanity QA29_B0` to retain common configurations.
    - Update the job description to reflect the new environment.
    - Update the Script Path to point to env specific Jenkins File created above.


### 🔒 **Secure Credential Management**

Sensitive test credentials that are normally in .env file is managed by pipeline as below:

#### Option 1: Encrypted Repository Files
Store encrypted credentials in the repository and decrypt them during pipeline execution.

**One Time Setup:**
1. Generate an encryption key:
   ```bash
   python dev_utils/credential_manager.py generate-key
   ```
```Note
We already have a key generated and in use. Please use the same. The above info is just for documentation purpose.
```

2. Store the key in Jenkins as credential ID: `wfm-encryption-key`

3. Encrypt credentials for each environment:

   - The credentials file is nothing but .env file in a json format. Ensure they are in sync with keys.
      ```bash
      # Create credentials file from template if you dont have one
      cp credentials_template.json decrypted_credentials.json
      # Edit decrypted_credentials.json with actual values   
      ```
   - Store this encrypted_credentials.json file in test_data/environments/{ENV_NAME}/
   - Encrypt the credentials
      ```bash
      SET ENCRYPTION_KEY="your_key_here" 
      python dev_utils/credential_manager.py encrypt --test-env QA29_B0 
      ```
   - This will create `encrypted_credentials.json` in test_data/environments/{ENV_NAME}/ directory

```Note
You can also use dev_utils/credential_manager.py to decrypt an already encryted json file.
sample command:
   SET ENCRYPTION_KEY="your_key_here" 
   python dev_utils/credential_manager.py decrypt --test-env QA29_B0 

```

For getting the encryption key contact : Kapil Gole. We have it stored in keeper.

4. Commit the encrypted files to the repository:
   ```
   test_data/environments/{ENV_NAME}/encrypted_credentials.json

   ```

## Modifying The Encrypted Credentials
To modify the encrypted credentials for an environment, follow these steps:
1. set ENCRYPTION_KEY as environment variable
for windows the command is set ENCRYPTION_KEY=YourEncryptionkeyHere  
2. Decrypt the credentials for the environment you want to modify:
```
python dev_utils/credential_manager.py decrypt --test-env QA29_B0   
```
This will create the decrypted_credentials.json file in respective environment folder:
3.  Modify the decrypted credential json as required from respective environment folder.
In this case it will be here  : test_data\environments\QA29_B0\decrypted_credentials.json
4. Encrypt the credentials back:
```
python dev_utils/credential_manager.py encrypt --test-env QA29_B0  
```
This will create/update test_data\environments\QA29_B0\encrypted_credentials.json by encrypting the modified decrypted_credentials.json file.

5. Commit the changes. 
6. In case you want to verify the changes locally, you can directly decrypt into .env file using:
```
python decrypt_creds.py --test-env QA29_B0  
```
This will create/update the .env file in the root directory with the decrypted credentials for the specified environment.
Ensure you have all terminals killed and open new terminal to verify testcases with this new .env file.

## Post-run email and BAT triage report

After test execution, the shared library `performPostBuildAction` step:

1. Publishes Robot Framework results and sends the completion email to configured recipients.
2. When `output.xml` is present, runs `dev_utils/triage/bat_triage.py` against the latest results folder.
3. Generates `evidence_report.html` via `dev_utils/generate_evidence_report.py` (styled like the BAT Test Evidence template).
4. Writes both HTML reports into the results directory and attaches them to the same email.

Document-control constants (client, test cycle, reviewers, etc.) are resolved automatically:

1. **Defaults** — `dev_utils/evidence_report_config.json` (team names use **WST Automation Team**)
2. **Environment** — `test_data/environments/<TEST_ENV>/config.json` (`CLIENT`, `app_url`, `domainId`, test-data hints)
3. **Jenkins job** — `test_data/environments/<TEST_ENV>/BAT_Jenkinsfile` (`testRayCycle`, `testRayPlan`) and live Jenkins params `TESTRAY_CYCLE` / `TESTRAY_PLAN`
4. **Execution** — Robot `output.xml` metadata (`Environment`, `Browser`, `App Version`, `Device`)
5. **Optional override** — `test_data/environments/<TEST_ENV>/evidence_report_config.json`

Triage and evidence generation are best-effort: if a script is missing or fails, the email is still sent with whatever attachments were produced.


