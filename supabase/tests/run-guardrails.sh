#!/usr/bin/env bash
# Applies migrations to throw-away local databases and runs schema-agnostic checks.
# Requires local PostgreSQL and roles from run-selftests.sh or bootstrap. NEVER hosted.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
T="$ROOT/supabase/tests"
MIG="$ROOT/supabase/migrations"
PSQL=(psql -X -q -v ON_ERROR_STOP=1)
DBA=cityhaus_guard_a; DBB=cityhaus_guard_b
fail=0
trap '"${PSQL[@]}" -d postgres -c "drop database if exists $DBA" -c "drop database if exists $DBB" >/dev/null 2>&1 || true' EXIT
mapfile -t FILES < <(find "$MIG" -maxdepth 1 -name '*.sql' | LC_ALL=C sort)
echo "== M01 migration naming/order (${#FILES[@]} migration files)"
prev=""
for f in "${FILES[@]}"; do
  b="$(basename "$f")"
  if ! [[ "$b" =~ ^[0-9]{14}_[a-z0-9_]+\.sql$ ]]; then echo "FAIL: bad name $b"; fail=1; continue; fi
  ts="${b%%_*}"
  if [ "$ts" = "$prev" ]; then echo "FAIL: duplicate timestamp $ts"; fail=1; fi
  prev="$ts"
done
[ $fail -eq 0 ] && echo "PASS: names valid, timestamps unique and ordered"
build() {
  "${PSQL[@]}" -d postgres -c "drop database if exists $1" -c "create database $1"
  if "${PSQL[@]}" -d postgres -Atc "select 1 from pg_roles where rolname='anon'" | grep -q 1; then
    grep -v -E '^(create role|grant anon)' "$T/bootstrap/00_supabase_roles_stub.sql" > /tmp/stub_noroles.sql
    "${PSQL[@]}" -d "$1" -f /tmp/stub_noroles.sql
  else "${PSQL[@]}" -d "$1" -f "$T/bootstrap/00_supabase_roles_stub.sql"; fi
  for f in "${FILES[@]}"; do "${PSQL[@]}" -d "$1" -f "$f"; done
}
echo "== M02 clean-database application"
if build "$DBA"; then echo "PASS: all migrations applied to a clean database"; else echo "FAIL: migration error"; exit 1; fi
echo "== G01-G10 guardrails"
grep -E '^-- CHECK ' "$T/guardrails/checks.sql" | sed 's/^-- /   /'
out="$("${PSQL[@]}" -d "$DBA" -At -F ' | ' -f "$T/guardrails/checks.sql")"
if [ -z "$out" ]; then echo "PASS: 0 violations"; else echo "FAIL: violations:"; echo "$out"; fail=1; fi
echo "== M03 determinism (two clean builds, schema dumps compared)"
if command -v pg_dump >/dev/null; then
  build "$DBB"
  dump() { pg_dump -s --no-owner -d "$1" | grep -v -E '^\\(un)?restrict '; }
  if diff <(dump "$DBA") <(dump "$DBB") >/dev/null; then echo "PASS: identical schemas"; else echo "FAIL: schemas differ"; fail=1; fi
else echo "SKIPPED: pg_dump not found"; fi
if [ ${#FILES[@]} -eq 0 ]; then echo "NOTE: 0 migrations present. Checks ran against an EMPTY schema and prove nothing about CityHaus."; fi
[ $fail -eq 0 ] && echo "GUARDRAILS: PASSED" || { echo "GUARDRAILS: FAILED"; exit 1; }
