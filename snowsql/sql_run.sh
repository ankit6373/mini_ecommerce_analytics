#!/usr/bin/env bash
set -euo pipefail

# ===== Config / Env =====
ENV="${ENV:-DEV}"  # override with ENV=QA / ENV=PROD
SQL_ROOT="sql_files"

: "${SNOWFLAKE_ACCOUNT:?Set SNOWFLAKE_ACCOUNT}"
: "${SNOWFLAKE_USER:?Set SNOWFLAKE_USER}"
: "${SNOWFLAKE_ROLE:?Set SNOWFLAKE_ROLE}"
: "${SNOWFLAKE_WAREHOUSE:?Set SNOWFLAKE_WAREHOUSE}"

# Password: prefer SNOWSQL_PWD, else SNOWFLAKE_PASSWORD
export SNOWSQL_PWD="${SNOWSQL_PWD:-${SNOWFLAKE_PASSWORD:-}}"
: "${SNOWSQL_PWD:?Set SNOWSQL_PWD or SNOWFLAKE_PASSWORD}"

SNOWSQL_CMD="${SNOWSQL_CMD:-snowsql}"
SNOW_OPTS=(-o variable_substitution=true -o exit_on_error=true -o friendly=false)

usage() {
  cat <<EOF
Usage:
  ${0##*/} [target ...]
Targets can be:
  all                       Run everything (bronze → silver/* → gold/analytics → platform)
  bronze                    Run ${SQL_ROOT}/bronze
  silver                    Run ${SQL_ROOT}/silver/{staging,common,sales,marketing,finance} in order
  gold                      Run ${SQL_ROOT}/gold/analytics
  platform                  Run ${SQL_ROOT}/platform
  <subpath>                 Run a specific folder or file under ${SQL_ROOT}, e.g.:
                              silver/staging
                              silver/staging/orders.sql
                              gold/analytics
Examples:
  ENV=QA ${0##*/} silver/staging
  ${0##*/} bronze gold/analytics
  ${0##*/} all
EOF
}

# ===== helpers =====
need_snowsql() {
  command -v "$SNOWSQL_CMD" >/dev/null 2>&1 || {
    echo "❌ '$SNOWSQL_CMD' not found on PATH. Set SNOWSQL_CMD to its full path or add it to PATH."
    exit 127
  }
}

run_sql_file() {
  local file="$1"
  echo "▶ $file"
  "$SNOWSQL_CMD" \
    -a "$SNOWFLAKE_ACCOUNT" \
    -u "$SNOWFLAKE_USER" \
    -w "$SNOWFLAKE_WAREHOUSE" \
    -r "$SNOWFLAKE_ROLE" \
    -DENV="$ENV" \
    "${SNOW_OPTS[@]}" \
    -f "$file"
}

run_sql_folder() {
  local folder="$1"
  shopt -s nullglob
  local files=( "$folder"/*.sql )
  if [ ${#files[@]} -eq 0 ]; then
    echo "ℹ️  No .sql files in: $folder"
    return 0
  fi
  for f in "${files[@]}"; do
    run_sql_file "$f"
  done
}

run_silver_all() {
  for dir in staging common sales marketing finance; do
    run_sql_folder "${SQL_ROOT}/silver/${dir}"
  done
}

run_target() {
  local t="$1"

  case "$t" in
    all)
      run_sql_folder "${SQL_ROOT}/bronze"
      run_silver_all
      run_sql_folder "${SQL_ROOT}/gold/analytics"
      run_sql_folder "${SQL_ROOT}/platform"
      ;;
    bronze)
      run_sql_folder "${SQL_ROOT}/bronze"
      ;;
    silver)
      run_silver_all
      ;;
    gold)
      run_sql_folder "${SQL_ROOT}/gold/analytics"
      ;;
    platform)
      run_sql_folder "${SQL_ROOT}/platform"
      ;;
    *)
      # Specific subpath under SQL_ROOT (folder or single file)
      local path="$t"
      # allow both "silver/staging" and "sql_files/silver/staging"
      [[ "$path" == "$SQL_ROOT/"* ]] || path="${SQL_ROOT}/$path"
      if [ -d "$path" ]; then
        run_sql_folder "$path"
      elif [ -f "$path" ]; then
        run_sql_file "$path"
      else
        echo "❌ Not found: $path"
        exit 1
      fi
      ;;
  esac
}

run_changed_range() {
  local range="$1"  
  # list changed .sql under SQL_ROOT
  mapfile -t changed < <(git diff --name-only "$range" | grep -E '^'"$SQL_ROOT"'/.*\.sql$' || true)
  if [ ${#changed[@]} -eq 0 ]; then
    echo "ℹ️  No changed SQL in $range"
    return 0
  fi
  echo "🧩 Changed SQL files in $range:"
  printf ' - %s\n' "${changed[@]}"
  printf '%s\n' "${changed[@]}" | sort -u | while IFS= read -r f; do
    run_target "$f"
  done
}

# ===== main =====
need_snowsql
echo "=== Running (ENV=${ENV}) ==="

CHANGED_RANGE=""
args=()
while (( "$#" )); do
  case "$1" in
    --changed)
      shift
      CHANGED_RANGE="${1:-}"
      if [ -z "$CHANGED_RANGE" ]; then echo "❌ --changed needs a <A..B> range"; usage; exit 2; fi
      ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      args+=("$1") ;;
  esac
  shift || true
done

# changed-only (CI) if requested
if [ -n "$CHANGED_RANGE" ]; then
  run_changed_range "$CHANGED_RANGE"
  # If CI only wants changed files, exit early when no explicit targets
  if [ ${#args[@]} -eq 0 ]; then
    echo "✅ Done (changed-only, ENV=${ENV})"
    exit 0
  fi
fi

# explicit targets (local or CI)
if [ ${#args[@]} -eq 0 ]; then
  usage; exit 1
fi

for target in "${args[@]}"; do
  run_target "$target"
done

echo "✅ Done (ENV=${ENV})"