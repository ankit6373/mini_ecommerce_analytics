# Snowflake + phData Toolkit (DEV → QA → PROD)

This repo provisions Snowflake with phData Toolkit and promotes SQL via GitHub Actions.

## Branches & Flow


- ## feature/ → PR into dev
- ## dev** → PR into qa
- ## qa** → PR into main** (production)


## Workflows
- ## Provision Plan** (`.github/workflows/provision-plan.yaml`)  
  Trigger: PR to `qa` or `main`.  
  Does:
  - Lints workflows.
  - Runs Toolkit plan (no changes).
  - Compiles only changed `sql_files/*.sql` in a rollbacked txn.
  - Required check: Snowflake Plan.

- ## Provision Deploy** (`.github/workflows/provision-deploy.yaml`)  
  Trigger:** Pull requests targeting dev, qa, or main**
  **Does:**
- Lints workflow YAMLs (`actionlint`)
- Runs **Toolkit plan** (no changes)
- Compiles only changed `sql_files/*.sql` inside a rollbacked transaction (syntax safety)
- Required status check: **Snowflake Plan**

## Secrets (GitHub → Settings → Secrets)
- Common: `TOOLKIT_TOKEN`, `SNOWFLAKE_ACCOUNT`
- DEV: `SNOWFLAKE_USER_DEV`, `SNOWFLAKE_PASSWORD_DEV`, `SNOWFLAKE_ROLE_DEV`
- QA: `SNOWFLAKE_USER_QA`, `SNOWFLAKE_PASSWORD_QA`, `SNOWFLAKE_ROLE_QA`
- PROD: `SNOWFLAKE_USER_PROD`, `SNOWFLAKE_PASSWORD_PROD`, `SNOWFLAKE_ROLE_PROD`

## Notes
- Branch protection on qa/main: PR required, required status check, up-to-date, no force push.
- Roles follow env isolation (DEV→DEV, QA→QA, PROD→PROD).