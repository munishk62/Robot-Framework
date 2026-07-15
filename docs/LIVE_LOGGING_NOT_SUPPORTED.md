# Live per-test logging on Jenkins console for data driven parallel runs test — not supported

Whenever robot framework runs a test suite, it does log the progress of each test (status on completion of test) in the console as the and when test execution ends. This is what we refer to as live logs per test.

However, when running data driven test and run with parallel process, the robot framework console does not provide such a live status for these tests because of the way the framework handles data driven test and parallel process. There are ways to achive live logging in these cases as well however we do not support it for below reasons. An alternative option of notifying failures to teams is supported.


This documents why we do **not** treat **live** (streaming, per-test) console logging as a supported way to monitor Robot suites—especially under **Pabot**, **Data Driver**, and **multi‑hour** runs.

Use **Teams notifications**, **dashboards**, or **post‑run reports** instead of relying on the Jenkins build log for ongoing visibility.

---

- **Parallel workers contend for one console.** Pabot runs multiple Robot processes; each can emit logs and listener output at once, so interleaved lines make the console unreliable as a source of truth for “what failed when.”

- **Extra listeners increase I/O.** Per‑test hooks that write to stdout/stderr add measurable overhead across many processes and long runs; at suite durations of **8–10+ hours**, that cost compounds without improving stability.

- **Data Driver multiplies test instances.** Template‑driven suites generate large numbers of cases; streaming every completion to the console scales poorly and still does not give structured, queryable history.

- **Jenkins console is a log buffer, not a dashboard.** It is not built for analyzing hundreds or thousands of granular events over a full workday; searching and alerting remain awkward compared with dedicated tooling.

- **Recommended visibility:** use **failure notifications** (e.g. Microsoft Teams — see [TEAMS_WEBHOOK_FAILURE_NOTIFICATIONS](./TEAMS_WEBHOOK_FAILURE_NOTIFICATIONS.md)) and/or **dashboard / reporting** pipelines that consume **`output.xml`**, published artifacts, or your existing metrics stores—not incremental reliance on the live job console.

