#!/usr/bin/env bash
#
# test.sh — test suite para ccp
#
# Usage:
#   scripts/test.sh               # run all
#   scripts/test.sh <name>        # run único test por prefix
#   scripts/test.sh -v            # verbose
#
# Los tests son funciones test_<name>() que setean FIXTURE (dir temporal)
# y llaman a funciones internas de ccp o al script completo.
# Convención: 0 = pass, != 0 = fail.

set -uo pipefail  # NO -e para poder controlar fails por test

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CCP="$SCRIPT_DIR/ccp"

# ---------- UI ----------
source "$SCRIPT_DIR/lib/cyber-ui.sh"

VERBOSE=0
FILTER=""
for arg in "$@"; do
  case "$arg" in
    -v|--verbose) VERBOSE=1 ;;
    -*) echo "flag desconocido: $arg" >&2; exit 2 ;;
    *) FILTER="$arg" ;;
  esac
done

# ---------- Assertions ----------
assert_eq() {
  local actual="$1" expected="$2" label="$3"
  if [[ "$actual" == "$expected" ]]; then
    (( VERBOSE )) && printf "    %b✓%b %s\n" "$C_OK" "$C_RESET" "$label"
    return 0
  fi
  printf "    %b✗%b %s\n" "$C_ERR" "$C_RESET" "$label"
  printf "      expected: %s\n" "$expected"
  printf "      actual:   %s\n" "$actual"
  return 1
}

assert_contains() {
  local haystack="$1" needle="$2" label="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    (( VERBOSE )) && printf "    %b✓%b %s\n" "$C_OK" "$C_RESET" "$label"
    return 0
  fi
  printf "    %b✗%b %s\n" "$C_ERR" "$C_RESET" "$label"
  printf "      needle: %s\n" "$needle"
  printf "      in:     %s\n" "${haystack:0:200}"
  return 1
}

assert_file_exists() {
  local path="$1" label="$2"
  if [[ -e "$path" ]]; then
    (( VERBOSE )) && printf "    %b✓%b %s\n" "$C_OK" "$C_RESET" "$label"
    return 0
  fi
  printf "    %b✗%b %s — no existe: %s\n" "$C_ERR" "$C_RESET" "$label" "$path"
  return 1
}

# ---------- Source de funciones internas para test unitario ----------
# Cargamos selectivamente (sin ejecutar dispatch)
_source_profile_fns() {
  PROFILE_SH_LIB=1 source "$CCP"
}

# ---------- Tests ----------

test_parse_github_url_basic() {
  _source_profile_fns
  local result
  result="$(parse_github_url "https://github.com/foo/bar")"
  assert_eq "$result" "foo	bar		" "parse basic https URL"
}

test_parse_github_url_with_branch() {
  _source_profile_fns
  local result
  result="$(parse_github_url "https://github.com/foo/bar/tree/dev")"
  assert_eq "$result" "foo	bar	dev	" "parse URL with branch"
}

test_parse_github_url_with_path() {
  _source_profile_fns
  local result
  result="$(parse_github_url "https://github.com/foo/bar/tree/main/skills/my-skill")"
  assert_eq "$result" "foo	bar	main	skills/my-skill" "parse URL with tree path"
}

test_parse_github_url_git_at() {
  _source_profile_fns
  local result
  result="$(parse_github_url "git@github.com:foo/bar.git")"
  assert_eq "$result" "foo	bar		" "parse SSH URL"
}

test_pack_name_from_url() {
  _source_profile_fns
  assert_eq "$(pack_name_from_url "https://github.com/foo/bar")"                  "foo/bar" "strip github prefix" &&
  assert_eq "$(pack_name_from_url "https://github.com/foo/bar.git")"              "foo/bar" "strip .git suffix" &&
  assert_eq "$(pack_name_from_url "https://github.com/foo/bar/")"                 "foo/bar" "strip trailing slash" &&
  assert_eq "$(pack_name_from_url "https://github.com/foo/bar/tree/dev")"         "foo/bar" "strip /tree/branch" &&
  assert_eq "$(pack_name_from_url "https://github.com/foo/bar/tree/main/x/y")"    "foo/bar" "strip /tree/branch/path" &&
  assert_eq "$(pack_name_from_url "https://github.com/foo/bar/blob/main/a.md")"   "foo/bar" "strip /blob/path" &&
  assert_eq "$(pack_name_from_url "git@github.com:foo/bar.git")"                  "foo/bar" "strip SSH + .git"
}

test_pack_name_from_url_edge() {
  _source_profile_fns
  # URL minimalista
  assert_eq "$(pack_name_from_url "foo/bar")" "foo/bar" "formato owner/repo directo"
}

test_detect_kind_from_path() {
  _source_profile_fns
  assert_eq "$(detect_kind_from_path "skills/foo")"          "skill"   "skills/ prefix" &&
  assert_eq "$(detect_kind_from_path "agents/foo.md")"       "agent"   "agents/ prefix" &&
  assert_eq "$(detect_kind_from_path "commands/x.md")"       "command" "commands/ prefix" &&
  assert_eq "$(detect_kind_from_path "rules/naming.md")"     "rule"    "rules/ prefix" &&
  assert_eq "$(detect_kind_from_path "references/ck.md")"    "reference" "references/ prefix" &&
  assert_eq "$(detect_kind_from_path "scripts/x.sh")"        "script"  "scripts/ prefix" &&
  assert_eq "$(detect_kind_from_path "hooks/x.sh")"          "script"  "hooks/ prefix" &&
  assert_eq "$(detect_kind_from_path "docs/README.md")"      ""        "unknown prefix"
}

test_enumerate_pack_files_standard() {
  _source_profile_fns
  local fx; fx="$(mktemp -d)"
  mkdir -p "$fx/skills/foo" && touch "$fx/skills/foo/SKILL.md"
  mkdir -p "$fx/agents" && touch "$fx/agents/bar.md"
  mkdir -p "$fx/rules" && touch "$fx/rules/naming.md"
  local out; out="$(enumerate_pack_files "$fx")"
  rm -rf "$fx"
  assert_contains "$out" "skills/foo"    "detecta skill std" &&
  assert_contains "$out" "agents/bar.md" "detecta agent std" &&
  assert_contains "$out" "rules/naming.md" "detecta rule std"
}

test_enumerate_pack_files_extended_locations() {
  _source_profile_fns
  local fx; fx="$(mktemp -d)"
  mkdir -p "$fx/skills/.curated/a" && touch "$fx/skills/.curated/a/SKILL.md"
  mkdir -p "$fx/.claude/agents" && touch "$fx/.claude/agents/b.md"
  mkdir -p "$fx/.claude/rules" && touch "$fx/.claude/rules/c.md"
  mkdir -p "$fx/.claude/scripts" && touch "$fx/.claude/scripts/d.sh"
  local out; out="$(enumerate_pack_files "$fx")"
  rm -rf "$fx"
  assert_contains "$out" "skills/a"     "detecta skill en .curated" &&
  assert_contains "$out" "agents/b.md"  "detecta agent en .claude/agents" &&
  assert_contains "$out" "rules/c.md"   "detecta rule en .claude/rules" &&
  assert_contains "$out" "scripts/d.sh" "detecta script en .claude/scripts"
}

test_enumerate_pack_files_dedup() {
  _source_profile_fns
  local fx; fx="$(mktemp -d)"
  mkdir -p "$fx/skills/foo" && touch "$fx/skills/foo/SKILL.md"
  mkdir -p "$fx/.claude/skills/foo" && touch "$fx/.claude/skills/foo/SKILL.md"
  local count; count="$(enumerate_pack_files "$fx" | grep -c '^skills/foo$')"
  rm -rf "$fx"
  assert_eq "$count" "1" "dedupe colisión skills/foo"
}

test_enumerate_requires_SKILL_md() {
  _source_profile_fns
  local fx; fx="$(mktemp -d)"
  mkdir -p "$fx/skills/without-marker"
  mkdir -p "$fx/skills/with-marker" && touch "$fx/skills/with-marker/SKILL.md"
  local out; out="$(enumerate_pack_files "$fx")"
  rm -rf "$fx"
  assert_contains "$out" "skills/with-marker" "incluye con marker" || return 1
  if [[ "$out" == *"skills/without-marker"* ]]; then
    printf "    %b✗%b NO incluye sin marker (falló)\n" "$C_ERR" "$C_RESET"
    return 1
  fi
  (( VERBOSE )) && printf "    %b✓%b NO incluye sin marker\n" "$C_OK" "$C_RESET"
  return 0
}

test_kind_accessors() {
  _source_profile_fns
  assert_contains "$(kind_dirs skill)" "skills" "skill dirs incluye 'skills'" &&
  assert_eq       "$(kind_ext agent)"  ".md" "agent ext = .md" &&
  assert_eq       "$(kind_marker skill)" "SKILL.md" "skill marker = SKILL.md" &&
  assert_eq       "$(kind_subdir rule)" "rules" "rule subdir = rules"
}

test_validate_frontmatter_valid() {
  _source_profile_fns
  local fx; fx="$(mktemp -d)"
  cat > "$fx/skill.md" <<EOF
---
name: test
description: ok
---
content
EOF
  local out; out="$(validate_frontmatter "skill" "$fx/skill.md" 2>&1)"
  rm -rf "$fx"
  # No debe emitir warn sobre missing
  if [[ "$out" == *"frontmatter incompleto"* ]]; then
    printf "    %b✗%b frontmatter válido marcado como incompleto\n" "$C_ERR" "$C_RESET"
    return 1
  fi
  return 0
}

test_validate_frontmatter_missing() {
  _source_profile_fns
  local fx; fx="$(mktemp -d)"
  cat > "$fx/broken.md" <<EOF
---
name: test
---
content
EOF
  local out; out="$(validate_frontmatter "skill" "$fx/broken.md" 2>&1)"
  rm -rf "$fx"
  assert_contains "$out" "frontmatter incompleto" "warn sobre frontmatter incompleto"
}

test_profile_sh_help_ok() {
  local out; out="$("$CCP" --help 2>&1)"
  assert_contains "$out" "PROFILE" "help muestra sección PROFILE" &&
  assert_contains "$out" "PACKS" "help muestra sección PACKS" &&
  assert_contains "$out" "profile create" "help incluye profile create"
}

test_is_github_source() {
  _source_profile_fns
  _is_github_source "https://github.com/foo/bar"    && r1=0 || r1=1
  _is_github_source "git@github.com:foo/bar"        && r2=0 || r2=1
  _is_github_source "/tmp/my-skill"                 && r3=0 || r3=1
  _is_github_source "./relative/path"               && r4=0 || r4=1
  _is_github_source "~/Documents/foo.md"            && r5=0 || r5=1
  assert_eq "$r1" "0" "https URL es github" &&
  assert_eq "$r2" "0" "SSH URL es github" &&
  assert_eq "$r3" "1" "abs path NO es github" &&
  assert_eq "$r4" "1" "relative path NO es github" &&
  assert_eq "$r5" "1" "~ path NO es github"
}

test_fetch_from_local_file() {
  _source_profile_fns
  local fx; fx="$(mktemp -d)"
  echo "# rule" > "$fx/naming.md"
  # Suprimimos logs a /dev/null via redirect
  _fetch_from_local "rule" "naming" "$fx/naming.md" >/dev/null 2>&1
  local rc=$?
  local src="$GH_SRC" commit="$GH_COMMIT"
  rm -rf "$fx"
  assert_eq "$rc" "0" "fetch local file succeeds" &&
  assert_contains "$src" "naming.md" "GH_SRC apunta al archivo" &&
  assert_eq "$commit" "local" "GH_COMMIT=local"
}

test_fetch_from_local_dir_skill() {
  _source_profile_fns
  local fx; fx="$(mktemp -d)"
  mkdir -p "$fx/my-skill"
  touch "$fx/my-skill/SKILL.md"
  _fetch_from_local "skill" "my-skill" "$fx/my-skill" >/dev/null 2>&1
  local rc=$?
  local src="$GH_SRC"
  rm -rf "$fx"
  assert_eq "$rc" "0" "fetch local skill dir succeeds" &&
  assert_contains "$src" "my-skill" "GH_SRC apunta al dir"
}

test_fetch_from_local_dir_parent() {
  _source_profile_fns
  local fx; fx="$(mktemp -d)"
  mkdir -p "$fx/agents"
  echo "---" > "$fx/agents/foo.md"
  _fetch_from_local "agent" "foo" "$fx" >/dev/null 2>&1
  local rc=$?
  local src="$GH_SRC"
  rm -rf "$fx"
  assert_eq "$rc" "0" "fetch desde parent dir usa discovery" &&
  assert_contains "$src" "agents/foo.md" "encuentra el archivo anidado"
}

test_fetch_from_local_rejects_file_for_skill() {
  _source_profile_fns
  local fx; fx="$(mktemp -d)"
  echo "# no skill" > "$fx/skill.md"
  _fetch_from_local "skill" "foo" "$fx/skill.md" >/dev/null 2>&1
  local rc=$?
  rm -rf "$fx"
  # skill requiere dir con marker, no archivo — debe fallar
  [[ "$rc" != "0" ]] && return 0
  printf "    %b✗%b skill aceptó archivo\n" "$C_ERR" "$C_RESET"
  return 1
}

test_parse_files_block_single() {
  _source_profile_fns
  local target; target="$(mktemp -d)"
  local input="<file path=\"naming.md\">
# Naming
- kebab case
</file>"
  local n; n="$(_parse_and_write_files "$input" "$target")"
  rm -rf "$target"
  assert_eq "$n" "1" "parser extrae 1 archivo"
}

test_parse_files_block_multi() {
  _source_profile_fns
  local target; target="$(mktemp -d)"
  local input="<file path=\"SKILL.md\">
---
name: foo
description: bar
---
body
</file>
<file path=\"scripts/helper.sh\">
#!/bin/bash
echo hi
</file>"
  local n; n="$(_parse_and_write_files "$input" "$target")"
  local has_skill=0 has_script=0 is_exec=0
  [[ -f "$target/SKILL.md" ]] && has_skill=1
  [[ -f "$target/scripts/helper.sh" ]] && has_script=1
  [[ -x "$target/scripts/helper.sh" ]] && is_exec=1
  rm -rf "$target"
  assert_eq "$n" "2" "parser extrae 2 archivos" &&
  assert_eq "$has_skill" "1" "SKILL.md escrito" &&
  assert_eq "$has_script" "1" "scripts/helper.sh escrito" &&
  assert_eq "$is_exec" "1" ".sh marcado ejecutable"
}

test_parse_files_block_ignores_garbage() {
  _source_profile_fns
  local target; target="$(mktemp -d)"
  local input="acá hay texto suelto que no debería importar
<file path=\"rule.md\">
contenido
</file>
más texto suelto
otro bloque de texto random"
  local n; n="$(_parse_and_write_files "$input" "$target")"
  rm -rf "$target"
  assert_eq "$n" "1" "parser ignora texto fuera de bloques"
}

test_parse_files_block_sanitizes_path() {
  _source_profile_fns
  local target; target="$(mktemp -d)"
  # Path con .. → debe sanitizarse
  local input="<file path=\"../../etc/evil\">
pwned
</file>"
  _parse_and_write_files "$input" "$target" >/dev/null
  # Verificar que NO se escribió fuera del target
  local escape=0
  [[ -f "/etc/evil" ]] && escape=1  # improbable pero chequeamos
  rm -rf "$target"
  assert_eq "$escape" "0" "no escapa con .."
}

test_draft_is_dir_type() {
  _source_profile_fns
  _draft_is_dir_type "skill" && s=0 || s=1
  _draft_is_dir_type "rule"  && r=0 || r=1
  _draft_is_dir_type "agent" && a=0 || a=1
  assert_eq "$s" "0" "skill es dir type" &&
  assert_eq "$r" "1" "rule NO es dir type" &&
  assert_eq "$a" "1" "agent NO es dir type"
}

test_draft_path_skill_vs_rule() {
  _source_profile_fns
  local sp; sp="$(_draft_path "skill" "foo")"
  local rp; rp="$(_draft_path "rule" "naming")"
  assert_contains "$sp" "drafts/skills/foo"     "skill draft path es dir" &&
  assert_contains "$rp" "drafts/rules/naming.md" "rule draft path es .md"
}

test_apply_profile_sh_help_ok() {
  local out; out="$("$CCP" --help 2>&1)"
  assert_contains "$out" "--uninstall" "help incluye --uninstall" &&
  assert_contains "$out" "--dry-run" "help incluye --dry-run"
}

# ---------- Runner ----------
tests=()
while IFS= read -r fn; do
  tests+=("$fn")
done < <(declare -F | awk '{print $3}' | grep '^test_' | sort)

[[ -n "$FILTER" ]] && tests=( $(printf '%s\n' "${tests[@]}" | grep "$FILTER" || true) )

if [[ "${#tests[@]}" -eq 0 ]]; then
  echo "sin tests que ejecutar${FILTER:+ (filtro: $FILTER)}"
  exit 2
fi

banner "TEST SUITE" "${#tests[@]} tests"

pass=0; fail=0; failed_names=()
for t in "${tests[@]}"; do
  printf "  %b▸%b %s\n" "$C_INFO" "$C_RESET" "$t"
  if "$t"; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    failed_names+=("$t")
  fi
done

echo
hr "─" "$C_DARK"
if (( fail == 0 )); then
  printf "  %b◉ %d/%d PASS%b\n" "$C_OK" "$pass" "${#tests[@]}" "$C_RESET"
  exit 0
else
  printf "  %b⊘ %d/%d FAIL%b\n" "$C_ERR" "$fail" "${#tests[@]}" "$C_RESET"
  for n in "${failed_names[@]}"; do
    printf "    - %s\n" "$n"
  done
  exit 1
fi
