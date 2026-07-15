# Docker Support for WFM Automation

This container image bundles everything required to execute the Robot Framework suites with `executor.py`, including Python 3.13, UV tooling, Playwright browsers, Node/npm, and the Zebra SWS bundle (installed via `SWS_RF_Bundle_uv_jenkins/install_bundle.py`).

## Build the image

From the repository root run:

```bash
docker build -t wfm-robot-automation .
```

The build installs all Python dependencies defined in `pyproject.toml`, provisions the SWS bundle (device steps are skipped via `--exclude_device` to keep the image lighter), and downloads the Playwright browsers once so that test containers start quickly.

During the image build the `robotframework_playwright_helper/helper.js` file is automatically converted to CommonJS so that the Robot Framework Browser wrapper (which uses `require`) can load the helper without `ERR_REQUIRE_ESM`. The script simply rewrites the import/export statements after the bundle install completes.

## Run tests inside the container

Bind-mount your working copy so that results stay on the host and invoke `executor.py` through UV:

```bash
docker run --rm -it \
  -v %cd%:/workspace \
  -w /workspace \
  -e USER_CREDENTIALS="<json secrets>" \
  wfm-robot-automation \
  uv run python executor.py tests/web/smoke/ --test-env QA28_B0
```

Tips:

- Replace `%cd%` with `$(pwd)` when using a Unix shell.
- Mount any extra result/log directories you need (e.g. `-v %cd%/results:/workspace/results`).
- Use normal `executor.py` switches (`--include-tags`, `--dry-run`, etc.).
- Run environment sync before executing suites: `uv run python -m web.test_data.env_config_sync.cli --env QA28`.

## Optional device tooling

If you need the Appium/mobile tooling that the bundle can provision, remove `--exclude_device` from the `RUN python install_bundle.py --exclude_device` step in the `Dockerfile` and rebuild the image. The default build keeps the image smaller while still covering the browser-based WFM tests.

## Installed paths of interest

- Project virtual environment: `/opt/wfm/.venv`
- SWS bundle: `/opt/SWS_RF_Bundle_uv_jenkins`
- Playwright browsers: `/ms-playwright`

The container drops you into `/workspace` by default, ready for mounting your checkout and running tests.
