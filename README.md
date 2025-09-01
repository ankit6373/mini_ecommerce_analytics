# Snowflake + phData Toolkit (QA → PROD)

This repo provisions Snowflake with phData Toolkit and promotes SQL via GitHub Actions.

## Branches & Flow
- `feature/*` → PR into `qa`
- `qa` → staging env (QA)
- `main` → production env (PROD)
- Best practice: After every release (qa → main), open a quick sync PR main → qa.

## Workflows
- ## Provision Plan** (`.github/workflows/provision-plan.yaml`)  
  Trigger: PR to `qa` or `main`.  
  Does:
  - Lints workflows.
  - Runs Toolkit plan (no changes).
  - Compiles only changed `sql_files/*.sql` in a rollbacked txn.
  - Required check: Snowflake Plan.

- ## Provision Deploy** (`.github/workflows/provision-deploy.yaml`)  
  Trigger: push to `qa` or `main` when paths under `provision/`, `sql_files/`, etc. change.  
  Does:
  - Applies Toolkit changes (QA if branch=qa, PROD if branch=main).
  - Executes** only changed `sql_files/*.sql`.

## Secrets (GitHub → Settings → Secrets)
- Common: `TOOLKIT_TOKEN`, `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_WAREHOUSE`
- QA: `SNOWFLAKE_USER_QA`, `SNOWFLAKE_PASSWORD_QA`, `SNOWFLAKE_ROLE_QA`
- PROD: `SNOWFLAKE_USER_PROD`, `SNOWFLAKE_PASSWORD_PROD`, `SNOWFLAKE_ROLE_PROD`

## Notes
- Branch protection on qa/main: PR required, required status check, up-to-date, no force push.
- Roles follow env isolation (DEV→DEV, QA→QA, PROD→PROD).