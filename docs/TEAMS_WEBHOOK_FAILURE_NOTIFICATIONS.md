# Teams webhook notifications for failed Robot tests



This project includes a Robot Framework listener that posts to Microsoft Teams when an individual test fails—useful during long parallel (`pabot`) runs when console output is buffered. Implementation: `listener/notify_failures_to_teams.py` (`TeamsWebhookListener`).

The webhook URL is configured in **only two ways**:

1. **Environment variable `TEST_FAILURE_NOTIFICATION_WEBHOOK`** — full incoming webhook URL.

2. **Listener arguments** — URL appended after the listener class (`Class;<URL>`). See the module docstring in `listener/notify_failures_to_teams.py` for quoting. ** This is useful for local runs only **. It would not work in Jenkins jobs as the params are validated for safety reason and also some url params may be escaped while building the command.

## 1. Teams channel and incoming webhook

1. In Microsoft Teams, choose the channel where failures should appear.

2. Add an **Incoming Webhook** connector (or your org’s approved workflow) for that channel. Setup: In Teams, go to the channel, click ... -> Workflows -> Add workflow > "Post to a channel when a webhook request is received".

3. Copy the webhook URL. Treat it as a secret: do not commit it to git.


## 2. Configuring Teams webhook in Jenkins

1. In Jenkins, create a **Secret text** credential whose **value** is the Teams webhook URL. Use a stable credential ID (for example `teams-webhook-payroll-testautomation`).

2. For jobs using `jenkins-lib/vars/wfmQAPuneJenkins.groovy` only: In the wrapper Jenkinsfile in git repo, pass **`teamsWebhookCredentialId`** & **`extraRobotArgs`**:
Credential naming: stable IDs such as teams-webhook-<team>-<purpose> so multiple Jenkinsfiles can share one string

```groovy

@Library('wfm-qe-libs') _

wfmQAPuneJenkins([

    "testEnv": "QA29_B0",

    "testPath": "tests/web/examples/test_sample.robot",

    "agentLabel": "wfm-qa-agent",

    "teamsWebhookCredentialId": "teams-webhook-payroll-testautomation",

    "extraRobotArgs": "--listener listener.notify_failures_to_teams.TeamsWebhookListener"

    ... other parameters ...

])

```
Note you can also set the --listener argument as jenkins job param per execution and avoid setting it up top.
We don't recommend setting --listener argument in the Jenkinsfile via "extraRobotArgs" as default so that you can control it per job execution.

During **Test Execution**, the shared library binds that secret to **`TEST_FAILURE_NOTIFICATION_WEBHOOK`** env variable

If **`teamsWebhookCredentialId`** is omitted or empty, nothing is bound; if **`EXTRA_ROBOT_ARGS`** includes the Teams listener but no URL is set via listener args or env, notifications do not fire.

## 3. Local / manual runs

For Local runs you can pass the URL in the **`--listener`** argument as below
```
uv run python executor.py tests/path/ --test-env QA29_B0 --listener "listener.notify_failures_to_teams.TeamsWebhookListener;https://hook.example/webhook?asd=as&a=c&d=1"
```
Or 
Set the env variable **`TEST_FAILURE_NOTIFICATION_WEBHOOK`** before invoking Robot or `executor.py` or set it in scoped env file and invoke as below
```
uv run python executor.py tests/path/ --test-env QA29_B0 --listener listener.notify_failures_to_teams.TeamsWebhookListener
```
NOTE: Refer `listener/notify_failures_to_teams.py` for more details on the listener arguments.


## Reference

- Full listener behavior and MessageCard payload: module docstring in `listener/notify_failures_to_teams.py`.


