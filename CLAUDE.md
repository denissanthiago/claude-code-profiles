# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Tooling to manage Claude Code configuration across multiple projects. The entry point is `scripts/ccp`, a ~3200-line bash CLI that applies reusable **profiles** (frontend, backend, mobile, video-creator) to target repos, managing rules, skills, agents, commands, references, scripts, settings, and MCP servers. There is no compiled code and no package manager — everything is bash + `jq`.

Canonical project docs live in the Obsidian vault under `configure-claude-code/` (entry `Índice.md`), not in this repo.

## Commands

Run everything from the repo root unless noted.

```bash
# Tests (bash-based; sources ccp with PROFILE_SH_LIB=1 to unit-test internal fns)
scripts/test.sh                    # all tests
scripts/test.sh <prefix>           # filter by test_<prefix>…
scripts/test.sh -v                 # verbose (show passes)

# Help / profile discovery
scripts/ccp --help
scripts/ccp profile list
scripts/ccp inventory <profile>

# Apply a profile (run from the TARGET project repo, not this repo)
cd /path/to/target/repo
/…/configure-claude-code/scripts/ccp apply --dry-run <profile>
/…/configure-claude-code/scripts/ccp apply <profile>
/…/configure-claude-code/scripts/ccp apply --force <profile>
/…/configure-claude-code/scripts/ccp apply <profile> --uninstall

# Manage profile contents (run from anywhere)
scripts/ccp <type> {list|add|remove} <profile> [<name>] [--from <url|path>]
#   <type> ∈ skill · agent · command · rule · reference · script · mcp
scripts/ccp mcp add-json <profile> <name> '<json>'

# External packs (GitHub repos merged into a profile)
scripts/ccp pack install <profile> <github-url> [--pin SHA | --branch X | --tag X] [--dry-run]
scripts/ccp pack update <profile> <pack|--all> [--dry-run]
scripts/ccp pack remove <profile> <pack>
scripts/ccp pack list <profile>
scripts/ccp pack adopt <profile> <github-url>   # retroactive manifest

# AI-assisted drafting workspace (uses the `claude` CLI)
scripts/ccp draft {create|refine|install|discard|list|history} …

# Install global (scope=user) MCP servers — idempotent, reads EXA_API_KEY from env
scripts/install-mcps.sh
```

`scripts/ccp apply` has safety rails: it refuses to run with the target dir equal to this repo root or `~/.claude/`. The global `settings.json` also denies a batch of destructive `Bash(…)` calls (see `global/settings.json`).

## Architecture

### Single-file bash CLI with declarative resource tables

`scripts/ccp` is the whole tool. Near the top (≈lines 123–162) there's a declarative **layout central** with `KIND_DIRS_<type>`, `KIND_EXT_<type>`, `KIND_MARKER_<type>`, `KIND_SUBDIR_<type>` tables, accessed via `kind_dirs`/`kind_ext`/`kind_marker`/`kind_subdir`. **When adding a new resource location or type, edit these tables once** — `enumerate_pack_files`, `copy_pack_file`, GitHub fetch, and the apply step all consume them. Dispatch lives at the bottom of the file (`case "$1" in …`).

`scripts/lib/cyber-ui.sh` is sourced by both `ccp` and `test.sh` for shared UI primitives (`banner`, `log_info`, `log_ok`, `die`, colors). `ccp` self-sources in library mode when `CCP_LIB=1` or `PROFILE_SH_LIB=1`, so tests can call internal functions without triggering dispatch.

### How profiles compose onto a target repo

Each `profiles/<name>/` dir can contain any subset of: `profile.json`, `CLAUDE.md`, `settings.json`, `mcp.json`, and dirs `rules/`, `skills/<skill>/SKILL.md`, `agents/*.md`, `commands/*.md`, `references/*.md`, `scripts/*`. Merge semantics (see `profiles/README.md` for the full table):

- **`CLAUDE.md`** → target's `CLAUDE.md` — appended, wrapped in `<!-- apply-profile: <name> -->` / `<!-- /apply-profile: <name> -->` markers. Re-apply is a no-op unless `--force`. `--uninstall` strips the block by marker.
- **`settings.json`** → `.claude/settings.json` — `allow`/`deny` arrays unioned + deduped; existing `env` wins; `hooks` concatenated per event.
- **`mcp.json`** → `.mcp.json` — `mcpServers` merged; existing server wins on name collision.
- **`rules/`, `skills/`, `agents/`, `commands/`, `references/`, `scripts/`** → `.claude/<same>/` — copied if missing, skipped with a warning if present, overwritten with `--force`.

Every file written by `apply` is tracked in `<target>/.claude/.applied-profiles.json` so `--uninstall` knows exactly what to remove (settings.json and mcp.json are deliberately **not** reverted — the user edits those manually).

### Two manifests, different purposes

- `profiles/<name>/.packs.json` — inside this repo. Records external GitHub packs installed into a profile (source URL, resolved commit, ref kind `pin|branch|tag`, files list). Resources copied from a pack are write-locked against direct `<type> remove` — use `pack remove` instead.
- `<target>/.claude/.applied-profiles.json` — inside the consumer repo. Records which profiles were applied and which files each profile wrote. Produced by `apply`, consumed by `--uninstall`.

### Global vs profile scope

- `global/settings.json` + `global/hooks/session-start.sh` are the user's `~/.claude/` defaults — a session-start hook prints git context, plus a baseline allow/deny permission matrix and the Notification hook.
- `profiles/<name>/settings.json` adds profile-specific permissions (e.g. backend allows `docker compose *` but denies `psql -c DROP*`). These get merged into the **target repo's** `.claude/settings.json`, not the global one.

### Drafts workflow

`drafts/` is a staging area where `ccp draft create <type> <name>` spins up an interactive session with the `claude` CLI to generate a skill/rule/agent/etc. from a template. `draft install` then copies the draft into one or more profiles and appends to `drafts/.history.json`. This is separate from the profile-resource CRUD — drafts never get applied directly to a target repo.

### Testing style

Tests in `scripts/test.sh` are bash functions named `test_<name>()`. They source `ccp` with `PROFILE_SH_LIB=1` so internal helpers (`parse_github_url`, `enumerate_pack_files`, `_parse_and_write_files`, `_fetch_from_local`, `validate_frontmatter`, `_draft_*`) are callable directly. A test returns 0 for pass, non-zero for fail; the runner collects failures and reports at the end. Assertions: `assert_eq`, `assert_contains`, `assert_file_exists`.
