#!/usr/bin/env bash
# Proves the generic test harness works; this does NOT test CityHaus schema.
# Requires disposable local PostgreSQL >=15 and CREATE DATABASE/ROLE privileges.
# WARNING: creates cluster-wide roles anon/authenticated/service_role/authenticator.
set -euo pipefail
T="$(cd "$(dirname "$0")" && pwd)"
PSQL=(psql -X -q -v ON_ERROR_STOP=1)
DB=cityhaus_selftest
fail=0
fresh_db() {
  "${PSQL[@]}" -d postgres -c "drop database if exists $DB" -c "create database $DB"
  grep -v -E '^(create role|grant anon)' "$T/bootstrap/00_supabase_roles_stub.sql" > /tmp/stub_noroles.sql
  "${PSQL[@]}" -d postgres -Atc "select 1 from pg_roles where rolname='anon'" | grep -q 1 \
    && "${PSQL[@]}" -d "$DB" -f /tmp/stub_noroles.sql \
    || "${PSQL[@]}" -d "$DB" -f "$T/bootstrap/00_supabase_roles_stub.sql"
}
violations() { "${PSQL[@]}" -d "$DB" -At -F '|' -f "$T/guardrails/checks.sql"; }
echo "== 1. negative fixtures: every guardrail must fire"
fresh_db
"${PSQL[@]}" -d "$DB" -f "$T/guardrails/selftest/bad_fixture.sql"
out="$(violations)"
for id in G01 G02 G03 G04 G05 G06 G07 G08 G09 G10; do
  if grep -q "^$id|" <<<"$out"; then echo "PASS: $id detected"; else echo "FAIL: $id NOT detected"; fail=1; fi
done
echo "== 2. positive fixtures: guardrails must report nothing"
fresh_db
"${PSQL[@]}" -d "$DB" -f "$T/guardrails/selftest/good_fixture.sql"
out="$(violations)"
if [ -z "$out" ]; then echo "PASS: no violations on compliant fixture"; else echo "FAIL: unexpected violations:"; echo "$out"; fail=1; fi
echo "== 3. identity harness (anon / Provider A / Provider B)"
"${PSQL[@]}" -d "$DB" -f "$T/helpers/identity_helpers.sql"
if res="$("${PSQL[@]}" -o /dev/null -d "$DB" -f "$T/guardrails/selftest/identity_harness_selftest.sql" 2>&1)"; then
  echo "$res" | grep 'PASS:' | sed 's/^psql:[^ ]* NOTICE:  /  /'
  echo "PASS count: $(grep -c 'PASS:' <<<"$res") (expected 16)"
  [ "$(grep -c 'PASS:' <<<"$res")" -eq 16 ] || fail=1
  if grep -q 'FAIL:' <<<"$res"; then grep 'FAIL:' <<<"$res"; fail=1; fi
else echo "$res" | tail -5; fail=1; fi
"${PSQL[@]}" -d postgres -c "drop database if exists $DB"
[ $fail -eq 0 ] && echo "SELFTESTS: ALL PASSED" || { echo "SELFTESTS: FAILURES"; exit 1; }
