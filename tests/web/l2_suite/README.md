# L2 Suite - Quick Command Guide

## 🔑 Simple Rule
- **Default:** Setup runs automatically ✅
- **With `--exclude-tags schedule_generation_setup`:** Setup is SKIPPED ❌

---

## 📋 Commands You Need

### 1. L2 Suite WITH Setup (default)
```powershell
uv run python executor.py tests/web/l2_suite/ --test-env QA28_B0
```
Setup runs → All tests execute

### 2. L2 Suite WITHOUT Setup (exclude tag)
```powershell
uv run python executor.py tests/web/l2_suite/ --exclude-tags schedule_generation_setup --test-env QA28_B0
```
NO setup → All tests execute

### 3. Tagged Tests WITH Setup
```powershell
uv run python executor.py tests/web/l2_suite/ --include-tags dbs --test-env QA28_B0
```
Setup runs → Only `dbs` tagged tests execute

### 4. Tagged Tests WITHOUT Setup
```powershell
uv run python executor.py tests/web/l2_suite/ --include-tags dbs --exclude-tags schedule_generation_setup --test-env QA28_B0
```
NO setup → Only `dbs` tagged tests execute

---

## 📊 Quick Reference

| Scenario | Command | Setup? |
|----------|---------|--------|
| Full suite + setup | `executor.py tests/web/l2_suite/` | ✅ YES |
| Full suite, no setup | `executor.py tests/web/l2_suite/ --exclude-tags schedule_generation_setup` | ❌ NO |
| Tagged + setup | `executor.py tests/web/l2_suite/ --include-tags dbs` | ✅ YES |
| Tagged, no setup | `executor.py tests/web/l2_suite/ --include-tags dbs --exclude-tags schedule_generation_setup` | ❌ NO |

---

## ⚙️ How It Works

**Suite Setup checks for excluded tags:**
- If `schedule_generation_setup` is in `--exclude-tags` → Setup is SKIPPED
- Otherwise → Setup runs ONCE (creates schedule data for weeks 0, 1, 2, 3, 5, 6, 7, 8)

**Then tests execute in alphabetical order:** clock → ess → rta → rws → ...

**Setup keywords location:** `resources/web/rws/schedule/schedule_setup.resource`

---

## 💡 Common Use Cases

**First time / CI/CD:**
```powershell
uv run python executor.py tests/web/l2_suite/ --test-env QA28_B0
```

**Quick test (data exists):**
```powershell
uv run python executor.py tests/web/l2_suite/ --exclude-tags schedule_generation_setup --test-env QA28_B0
```

**Specific tag WITH setup:**
```powershell
uv run python executor.py tests/web/l2_suite/ --include-tags dbs --test-env QA28_B0
```

**Specific tag WITHOUT setup:**
```powershell
uv run python executor.py tests/web/l2_suite/ --include-tags dbs --exclude-tags schedule_generation_setup --test-env QA28_B0
```

---

## ❓ FAQ

**Q: How to skip setup with same path?**  
A: Add `--exclude-tags schedule_generation_setup`

**Q: Tests failing with "schedule not found"?**  
A: Run with setup: `executor.py tests/web/l2_suite/ --test-env QA28_B0`

**Q: How to know if setup ran?**  
A: Check log for: "L2 Suite Starting - Executing setup keywords in Suite Setup" or "Setup SKIPPED"

**Q: What happens if a setup keyword fails (e.g., Week 2 setup fails)?**  
A: Setup failures are **non-blocking**:
- Failed setup logs a **WARNING** (check `results/log.html`)
- Remaining setups continue to execute
- Suite Setup still **PASSES**
- All tests execute normally (tests needing failed setup data may fail)
- See [SUITE_SETUP_FAILURE_HANDLING.md](../../docs/SUITE_SETUP_FAILURE_HANDLING.md) for details

