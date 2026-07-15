\# Schedule Setup Guide — `schedule\_dependent` Directory



> \*\*Who is this for?\*\* Anyone writing or maintaining tests in this folder.  

> No prior knowledge of the schedule engine is needed.



\---



\## 1. Why Does This Directory Exist?



Tests in this folder \*\*need a schedule to already exist\*\* before they can run.  

Examples: verifying a published week, testing shift swaps, checking WIP behaviour.



Instead of each test building its own schedule (slow, brittle), every suite file here does the setup \*\*once\*\* before all its tests run. Tests then just log in and use the ready-made data.



```

Suite Setup  ──► Build schedule ONCE

&#x20;                   │

&#x20;                   ├─ Test 1 (runs in parallel)

&#x20;                   ├─ Test 2 (runs in parallel)

&#x20;                   └─ Test 3 (runs in parallel)

```



\---



\## 2. The Two Entry-Point Keywords You Will Call



You never call the internal engine directly. Pick one of these two:



| Keyword | When to use |

|---|---|

| `New Setup Schedule For Week` | \*\*Use this.\*\* Pass a `template\_name`. All config comes from the template. (Previous alias: `Setup Schedule For Week` — deprecated.) |

| `Pre Setup Store Schedule For Week` | Lower-level. Used by older suites or custom setups not yet templated. |



\### `New Setup Schedule For Week` — Example

```robot

Suite Setup    Run Only Once    New Setup Schedule For Week    template\_name=3\_0\_sm1\_store1

```



\### `Pre Setup Store Schedule For Week` — Example (older style)

```robot

Suite Setup    Pre Setup Schedule For Week 3    # calls the internal keyword via a wrapper

```



\---



\## 3. What Happens Inside — The 9-Step Pipeline



When you call either keyword above, this pipeline runs automatically.  

Each step checks the current state of the store before doing anything.



```

START

&#x20; │

&#x20; ① CHECK STATUS

&#x20; │   Reads the current state from the API:

&#x20; │   is\_forecast\_generated? is\_workload\_generated? is\_schedule\_generated?

&#x20; │   is\_schedule\_week\_in\_progress? can\_generate\_schedule? can\_lock\_schedule?

&#x20; │

&#x20; ② WEEK PLAN DELETION  (only if config: delete\_weekplan\_data = ON)

&#x20; │   Wipes all existing plan data and forces a fresh forecast.

&#x20; │   Use this for environments that need a clean slate.

&#x20; │

&#x20; ③ FORECAST GENERATION  (skipped if already done OR if week is WIP)

&#x20; │   Calls the forecast API and waits for it to finish.

&#x20; │

&#x20; ④ WORKLOAD GENERATION  (skipped if already done OR if week is WIP)

&#x20; │   Two paths depending on config:

&#x20; │   ┌─ vdi\_import config ON  → uploads VDI file via the web UI

&#x20; │   └─ vdi\_import config OFF → calls the workload API directly

&#x20; │

&#x20; ⑤ DELETE OLD SCHEDULE  (only if schedule exists AND week is NOT WIP)

&#x20; │   Clears a previously generated schedule so a fresh one can be made.

&#x20; │

&#x20; ⑥ GENERATE SCHEDULE  (only if generate\_schedule=True AND week is NOT WIP)

&#x20; │   Calls the schedule generation API and waits.

&#x20; │   ⚠ Fails immediately if the API says generation is not allowed.

&#x20; │

&#x20; ⑦ WEEK-IN-PROGRESS  (only for week\_offset=0\_0 AND week is NOT already WIP)

&#x20; │   Current week needs special treatment:

&#x20; │   → Publish the schedule first

&#x20; │   → Then generate the WIP copy

&#x20; │   After this step, the week is locked — most further steps are skipped.

&#x20; │

&#x20; ⑧ SHIFT SETUP  (for each employee in employee\_operations list)

&#x20; │   → Clears all existing shifts for the employee

&#x20; │   → Adds new shifts (stays allocated)

&#x20; │   → Adds + immediately unallocates shifts (creates open shifts)

&#x20; │

&#x20; ⑨ FINAL PUBLISH  (only if publish\_schedule=True AND week is NOT WIP)

&#x20; │   Optionally locks, then publishes the schedule to employees.

&#x20; │

&#x20; END

```



### Visual Workflow Diagram

> **How to read:**  `NO ↓ SKIP` = bypass, go straight down the spine  |  `YES → RUN` = branch right to action box, then `↓ rejoin` back

```
                        ┌──────────────────────┐
                        │      🟢  START        │
                        └──────────┬───────────┘
                                   │
                                   ▼
 ┌─────────────────────────────────────────────────────────────────────┐
 │  ① CHECK STATUS                                   ← ALWAYS RUNS    │
 │  ──────────────────────────────────────────────────────────────     │
 │  Reads current state from the API before doing anything:            │
 │    • is_forecast_generated?       • can_generate_schedule?          │
 │    • is_workload_generated?       • can_lock_schedule?              │
 │    • is_schedule_generated?       • is_schedule_week_in_progress?   │
 └─────────────────────────────────────┬───────────────────────────────┘
                                       │
                                       ▼
               ┌───────────────────────────────────────────┐
               │  ◇ ②  delete_weekplan_data = ON ?         │
               └──────────────┬──────────────┬─────────────┘
                              │              │
                        NO ↓ SKIP      YES → RUN
                              │              │
                              │   ┌──────────▼──────────────────────────┐
                              │   │  ② WEEK PLAN DELETION                │
                              │   │  ─────────────────────────────────  │
                              │   │  Wipes all existing plan data        │
                              │   │  Forces a completely fresh start     │
                              │   └──────────┬──────────────────────────┘
                              │              │ ↓ rejoin
                              ▼◀─────────────┘
               ┌───────────────────────────────────────────────────┐
               │  ◇ ③  Forecast already done  OR  week is WIP ?   │
               └──────────────┬──────────────┬───────────────────┘
                              │              │
                        YES ↓ SKIP      NO → RUN
                              │              │
                              │   ┌──────────▼──────────────────────────┐
                              │   │  ③ FORECAST GENERATION               │
                              │   │  ─────────────────────────────────  │
                              │   │  Calls forecast API                  │
                              │   │  Waits for job to complete           │
                              │   └──────────┬──────────────────────────┘
                              │              │ ↓ rejoin
                              ▼◀─────────────┘
               ┌───────────────────────────────────────────────────┐
               │  ◇ ④  Workload already done  OR  week is WIP ?   │
               └──────────────┬──────────────┬───────────────────┘
                              │              │
                        YES ↓ SKIP      NO → RUN
                              │              │
                              │   ┌──────────▼──────────────────────────┐
                              │   │  ④ WORKLOAD GENERATION               │
                              │   │  ─────────────────────────────────  │
                              │   │  vdi_import = ON  → Web UI upload    │
                              │   │  vdi_import = OFF → Direct API call  │
                              │   └──────────┬──────────────────────────┘
                              │              │ ↓ rejoin
                              ▼◀─────────────┘
               ┌───────────────────────────────────────────────────┐
               │  ◇ ⑤  Schedule exists  AND  week NOT WIP ?       │
               └──────────────┬──────────────┬───────────────────┘
                              │              │
                        NO ↓ SKIP    YES → DELETE
                              │              │
                              │   ┌──────────▼──────────────────────────┐
                              │   │  ⑤ DELETE OLD SCHEDULE               │
                              │   │  ─────────────────────────────────  │
                              │   │  Removes previously generated        │
                              │   │  schedule so a fresh one can be      │
                              │   │  created in the next step            │
                              │   └──────────┬──────────────────────────┘
                              │              │ ↓ rejoin
                              ▼◀─────────────┘
               ┌─────────────────────────────────────────────────────────┐
               │  ◇ ⑥  generate_schedule = True  AND  week NOT WIP ?   │
               └──────────────┬──────────────┬─────────────────────────┘
                              │              │
                        NO ↓ SKIP      YES → RUN
                              │              │
                              │   ┌──────────▼──────────────────────────┐
                              │   │  ⑥ GENERATE SCHEDULE                 │
                              │   │  ─────────────────────────────────  │
                              │   │  Calls schedule generation API       │
                              │   │  Waits for job to complete           │
                              │   │  ⚠ Fails immediately if API blocks   │
                              │   └──────────┬──────────────────────────┘
                              │              │ ↓ rejoin
                              ▼◀─────────────┘
               ┌─────────────────────────────────────────────────────────┐
               │  ◇ ⑦  week_offset = 0_0  AND  NOT already WIP ?       │
               └──────────────┬──────────────┬─────────────────────────┘
                              │              │
                        NO ↓ SKIP      YES → RUN
                              │              │
                              │   ┌──────────▼──────────────────────────┐
                              │   │  ⑦ WEEK-IN-PROGRESS                  │
                              │   │  ─────────────────────────────────  │
                              │   │  Step 1 → Publish schedule first     │
                              │   │  Step 2 → Generate WIP copy          │
                              │   │  ⚠ Week is now LOCKED                │
                              │   │  Steps ③ ④ ⑤ ⑥ ⑨ blocked after      │
                              │   └──────────┬──────────────────────────┘
                              │              │ ↓ rejoin
                              ▼◀─────────────┘
 ┌─────────────────────────────────────────────────────────────────────┐
 │  ⑧ SHIFT SETUP                                    ← ALWAYS RUNS    │
 │  ──────────────────────────────────────────────────────────────     │
 │  For every employee in the employee_operations list:                │
 │    ✦  Clear all existing shifts for the employee                    │
 │    ✦  Add shifts           →  remain allocated to employee          │
 │    ✦  Add then unallocate  →  move to open shift pool               │
 └─────────────────────────────────────┬───────────────────────────────┘
                                       │
                                       ▼
               ┌─────────────────────────────────────────────────────────┐
               │  ◇ ⑨  publish_schedule = True  AND  week NOT WIP ?    │
               └──────────────┬──────────────┬─────────────────────────┘
                              │              │
                        NO ↓ SKIP    YES → PUBLISH
                              │              │
                              │   ┌──────────▼──────────────────────────┐
                              │   │  ⑨ FINAL PUBLISH                     │
                              │   │  ─────────────────────────────────  │
                              │   │  Optionally lock the schedule        │
                              │   │  Publish schedule to all employees   │
                              │   └──────────┬──────────────────────────┘
                              │              │ ↓ rejoin
                              ▼◀─────────────┘
                        ┌──────────────────────┐
                        │      🟢  END          │
                        └──────────────────────┘
```

**Flow Legend:**

| Symbol | Meaning |
|--------|---------|
| `┌──┐` wide box (full width) | Step that **always runs** — no condition check |
| `◇ ②…⑨` narrow box | **Decision point** — evaluates the condition |
| `┌──┐` indented box (right branch) | **Action step** — only runs when YES |
| `NO ↓ SKIP` | Condition **not met** — bypass action, continue straight down |
| `YES → RUN / DELETE / PUBLISH` | Condition **met** — branch right to action box |
| `↓ rejoin` | Action done — reconnects back to the main vertical spine |


---



\## 4. Normal vs Dual Schedule — Decision Matrix



Some environments use \*\*Dual Schedule Generation\*\* (`DUO\_SCHEDULE\_GENERATION\_ENABLED` config).  

In dual mode, the pipeline runs \*\*twice\*\*: a first pass (generate) and a second pass (generate again + shifts).



| Step | Normal (single) | Dual — 1st pass | Dual — 2nd pass (`Schedule Setup For Dual`) |

|---|---|---|---|

| ② Week plan delete | If config ON | If config ON | \*\*Always skipped\*\* |

| ③ Forecast | If not yet done | If not yet done | \*\*Always runs\*\* (even if done) |

| ④ Workload | If not yet done | If not yet done | \*\*Always runs\*\* (even if done) |

| ⑤ Delete schedule | If exists + not WIP | If exists + not WIP | \*\*Always skipped\*\* |

| ⑥ Generate schedule | If flag=True + not WIP | If flag=True + not WIP | If flag=True + not WIP |

| ⑦ WIP (week 0 only) | If not already WIP | If not already WIP | Blocked (already WIP after 1st pass) |

| ⑧ Shift setup | Always | \*\*Skipped\*\* (deferred to 2nd pass) | \*\*Always runs\*\* |

| ⑨ Final publish | If flag=True + not WIP | If flag=True + not WIP | If flag=True + not WIP |



> \*\*Key insight for week 0 + dual:\*\* After the 1st pass triggers WIP, the entire 2nd pass becomes a \*\*shifts-only\*\* operation. Steps ③–⑦ and ⑨ are all blocked by the WIP guard — not because of a special dual rule, but because `is\_schedule\_week\_in\_progress=TRUE` after step ⑦ in the 1st pass, and the same `not WIP` condition applies in the 2nd pass just like normal.



\---



\## 5. Template Names — What They Mean



Templates are the fastest way to set up a schedule. Each template name encodes:



```

{week\_number}\_{variation}\_{manager}\_{store}

&#x20;    │             │          │         │

&#x20;    │             │          │         └─ store1, store2, sm1store2

&#x20;    │             │          └─ sm1 = Store Manager 1

&#x20;    │             └─ 0 = default variation

&#x20;    └─ 0–8 = week offset from current week

```



| Template Name | What it sets up |

|---|---|

| `0\_0\_sm1\_store1` | Week 0 (current week) — WIP schedule + employee shifts — Store 1 |

| `0\_0\_store2` | Week 0 — WIP schedule — Store 2 |

| `1\_0\_sm1\_store1` | Week 1 — generated + published schedule — Store 1 |

| `1\_0\_sm1\_store2` | Week 1 — generated + published schedule — Store 2 |

| `2\_0\_sm1\_store1` | Week 2 — generated + published schedule — Store 1 |

| `3\_0\_sm1\_store1` | Week 3 — generated + published schedule — Store 1 |

| `4\_0\_sm1store2` | Week 4 — new hire setup — Store 2 |

| `5\_0\_sm1\_store1` | Week 5 — generated + published schedule — Store 1 |

| `6\_0\_sm1\_store1` | Week 6 — generated but \*\*not published\*\* — Store 1 |

| `7\_0\_sm1\_store1` | Week 7 — generated but \*\*not published\*\*, no shift modifications |

| `8\_0\_sm1\_store1` | Week 8 — \*\*no generation\*\*, no modifications, not published |



\---



\## 6. Suite Files in This Directory



Each `.robot` file here owns a specific week+store combination.  

\*\*Always add your test to the matching suite file — do not create a new suite unless no match exists.\*\*



| Suite File | Weeks | Store | Highlights |

|---|---|---|---|

| `week0\_week5\_sm1store1\_schedule\_suite.robot` | 0 + 5 | Store 1 | Week 0 is WIP; Week 5 is published |

| `week0\_week1\_week2\_sm1store2\_schedule\_suite.robot` | 0 + 1 + 2 | Store 2 | Week navigation tests + approval tests |

| `week1\_sm1store1\_schedule\_suite.robot` | 1 | Store 1 | Day schedule operations |

| `week2\_sm1store1\_schedule\_suite.robot` | 2 | Store 1 | Published week |

| `week3\_sm1store1\_schedule\_suite.robot` | 3 | Store 1 | Shift bidding, swap, extra work |

| `week3\_sm1store2\_schedule\_suite.robot` | 3 | Store 2 | Store 2 specific shift operations |

| `week6\_week8\_sm1store1\_schedule\_suite.robot` | 6 + 8 | Store 1 | Unpublished/non-generated scenarios |

| `week7\_sm1store1\_schedule\_suite.robot` | 7 | Store 1 | Publish/unpublish toggle tests |



\---



\## 7. How to Add a Test to an Existing Suite



1\. \*\*Find the matching suite file\*\* from the table above.

2\. Add your test case at the bottom of `\*\*\* Test Cases \*\*\*`.

3\. Use the same tags as other tests in that file.

4\. You do \*\*not\*\* touch `Suite Setup` — the schedule is already there.



```robot

BATTCXXXXX: My New Test That Needs Week 3 Schedule

&#x20;   \[Documentation]    What this test verifies

&#x20;   \[Tags]    battcxxxxx    config:ess    schedule\_dependent



&#x20;   Login And Launch WFM Web App    user\_key=ESS4\_STORE1

&#x20;   # Your test steps — schedule is already set up by Suite Setup

```



\---



\## 8. How to Create a New Suite File



Only do this if \*\*no existing suite covers your week+store combination\*\*.



```robot

\*\*\* Settings \*\*\*

Documentation       Week X - SM1\_STOREX Schedule Suite

...                 \*\*PURPOSE:\*\* <describe what tests share this setup>

...                 \*\*EXECUTION COMMANDS:\*\*

...                 uv run python executor.py tests/web/l2\_suite/schedule\_dependent/weekX\_smXstoreX\_schedule\_suite.robot --test-env QA28\_B0



Library             pabot.PabotLib

Resource            resources/web/authentication/login.resource

Resource            resources/web/rws/schedule/schedule\_setup.resource

\# Add other resources your tests need



&#x20;   Suite Setup         Run Only Once    New Setup Schedule For Week    template\_name=X\_0\_smX\_storeX

Suite Teardown      Log    Week X Suite Complete    level=INFO

Test Teardown       Close Browser



Test Tags           scheduleX\_smXstoreX    schedule\_dependent





\*\*\* Test Cases \*\*\*

BATTCXXXXX: My First Test

&#x20;   \[Documentation]    ...

&#x20;   \[Tags]    battcxxxxx    config:rws



&#x20;   Login And Launch WFM Web App    user\_key=SM1\_STORE1

&#x20;   # test steps

```



> \*\*`Run Only Once`\*\* (from `pabot.PabotLib`) ensures schedule setup runs \*\*exactly once\*\* even when tests run in parallel across multiple processes.



\---



\## 9. Week 0 Special Behaviour



Week 0 = \*\*current week\*\*. It always goes through the WIP flow automatically:



```

Normal weeks (1, 2, 3...):   Generate → Publish → Done

Week 0:                       Generate → Publish → Generate WIP copy → Done

&#x20;                                                        │

&#x20;                                             is\_schedule\_week\_in\_progress = TRUE

&#x20;                                             (prevents any further generation/deletion)

```



If your test needs a \*\*WIP schedule\*\* (the real-time copy used during the current operating week), target `week\_offset=0\_0`.  

If your test just needs a \*\*published future schedule\*\*, use weeks 1–5.



\---



\## 10. Common Mistakes



| Mistake | What Happens | Fix |

|---|---|---|

| Adding a test to the wrong suite file | Test runs but gets wrong week data | Match week + store to the table in §6 |

| Forgetting `Run Only Once` in Suite Setup | Setup runs multiple times in parallel, causing race conditions | Always wrap with `Run Only Once` |

| Calling `Pre Setup Store Schedule For Week` directly in a test case | Works but bypasses template safety checks | Use `New Setup Schedule For Week` with a template (preferred) |

| Expecting shifts in week 0 from 1st pass (dual) | Shifts are skipped in 1st pass when dual is enabled | Shifts only land in the 2nd (dual) pass |

| Running tests without environment sync | Missing config values cause failures | Run `python -m dev\_utils.env\_config\_sync.cli --env <ENV>` first |



\---



\## 11. Quick Reference — Execution Commands



```powershell

\# Run a single suite

uv run python executor.py tests/web/l2\_suite/schedule\_dependent/week3\_sm1store1\_schedule\_suite.robot --test-env QA28\_B0



\# Run with parallel processes

uv run python executor.py tests/web/l2\_suite/schedule\_dependent/week3\_sm1store1\_schedule\_suite.robot --test-env QA28\_B0 --processes 7



\# Dry run (validate without executing)

uv run python executor.py --dry-run tests/web/l2\_suite/schedule\_dependent/ --test-env QA28\_B0



\# If setup is being skipped (stale pabot lock files)

Remove-Item -Path ".pabot\_results" -Recurse -Force -ErrorAction SilentlyContinue

```



\---



\## 12. Keyword Responsibility Summary



```

New Setup Schedule For Week          ← what YOU call (template-based, safest; alias `Setup Schedule For Week` is deprecated)

&#x20; └─► Pre Setup Store Schedule For Week   ← orchestrates the 9-step pipeline

&#x20;       ├─ Steps ①–⑦: generate forecast, workload, schedule, WIP

&#x20;       ├─ Step ⑧: shift setup (skipped if dual)

&#x20;       ├─ Step ⑨: final publish

&#x20;       └─► Schedule Setup For Dual       ← called automatically if DUO config ON

&#x20;             ├─ Steps ③④  : always regenerate (no deletion, no week plan wipe)

&#x20;             ├─ Step ⑧: shift setup (THIS is where shifts land in dual mode)

&#x20;             └─ Step ⑨: final publish

```

