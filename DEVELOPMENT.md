# Development

Contributor and developer notes for working on this action.

## Lint

Run [ShellCheck](https://www.shellcheck.net/) on the script:

```bash
shellcheck scripts/*.sh
```

CI runs this in the **lint** job of the reusable **Test** workflow (`.github/workflows/test.yml`).

## Test

The reusable **Test** workflow (`test.yml`) runs **lint** and **test** jobs. **CI** (`ci.yml`) and **Release** (`release.yml`) call it for validation. The **test** job:

1. **Script with file overrides** — Creates a fixture (`testdata/subdir/Dockerfile`), runs `scripts/resolve-workflow-dir.sh` with `OUTPUT_FILE` and `GITHUB_ENV_FILE` set (so the script does not rely on runner-provided `GITHUB_OUTPUT`/`GITHUB_ENV`), and asserts the output contents.
2. **Runner contract** — Runs the script with `GITHUB_OUTPUT` and `GITHUB_ENV` unset to assert the script exits 1 with a clear error message (catches environments like some Gitea/act setups that do not set these for composite steps).

To run the script locally with the same layout:

```bash
mkdir -p testdata/subdir
touch testdata/subdir/Dockerfile
INPUT_DOCKERFILE=Dockerfile INPUT_WORKSPACE=$PWD INPUT_SET_ENV=true INPUT_VERBOSE=true \
  GITHUB_WORKSPACE=$PWD OUTPUT_FILE=$PWD/out.txt GITHUB_ENV_FILE=$PWD/env.txt \
  bash scripts/resolve-workflow-dir.sh
cat out.txt
```

To assert the “runner didn’t set GITHUB_OUTPUT” path locally:

```bash
mkdir -p testdata/subdir
touch testdata/subdir/Dockerfile
unset GITHUB_OUTPUT GITHUB_ENV OUTPUT_FILE GITHUB_ENV_FILE
bash scripts/resolve-workflow-dir.sh
# Expect exit 1 and "ERROR: GITHUB_OUTPUT is not set"
```

(`testdata/`, `out.txt`, and `env.txt` are in `.gitignore`.)

## E2E

The **E2E tests** workflow (`.github/workflows/e2e-tests.yml`) runs the action as users do: `uses: ./` with a fixture, then verifies step outputs and env vars. This validates the action under the real runner (GitHub Actions sets `GITHUB_OUTPUT`/`GITHUB_ENV`). E2E does not run on Gitea/act; if the action is used there, ensure the runner sets those variables or pass override paths when supported.

## Local workflow testing (act)

To run the CI workflow locally with [act](https://github.com/nektos/act):

```bash
npm run test:act
# Or: npm run test:act:ci:push
```

Available scripts (see `package.json`):

- `test:act` — run full CI workflow (calls `test.yml`)
- `test:act:verbose` — same with act `-v`
- `test:act:ci:push` — CI with push event payload (`.github/workflows/.act/event-push.json`)
- `test:act:ci:lint` — run only the **lint** job (from `test.yml`)
- `test:act:ci:test` — run only the **test** job (from `test.yml`)
- `test:act:e2e` — run full **E2E tests** workflow (`e2e-tests.yml`)
- `test:act:e2e:dispatch` — E2E with workflow_dispatch event
- `test:act:ci:e2e` — run only the **e2e** job from `e2e-tests.yml`
- `test:act:release` — run the **Release** workflow (tag event; for local validation only)
- `test:act:release:tag` — same as `test:act:release` (tag event payload)
- `test:act:release:dispatch` — Release workflow with workflow_dispatch (e.g. to test with a tag input)

All scripts use `--container-options "--user $(id -u):$(id -g)"` and `--env-file .act.env --var-file .act.vars --secret-file .act.secrets` to avoid permission issues when the runner writes into the repo directory.

### Act configuration

- **.act.env** — non-secret env (e.g. `HOME`, `RUNNER_TEMP`); committed.
- **.act.vars** — workflow variables; committed (usually empty).
- **.act.secrets** — placeholder only; do not commit real tokens. Use a local file (e.g. `.act.secrets.local`) for real secrets and pass it with `--secret-file .act.secrets.local` if needed.

Sample copies (`.act.env.sample`, `.act.vars.sample`, `.act.secrets.sample`) are committed for reference.

## Release

Version and push a new release (patch / minor / major):

```bash
npm run release:patch   # 1.0.0 → 1.0.1, commit + tag, push
npm run release:minor   # 1.0.0 → 1.1.0, commit + tag, push
npm run release:major   # 1.0.0 → 2.0.0, commit + tag, push
```

- **preversion**: runs `shellcheck scripts/*.sh` before the bump (release is blocked if lint fails).
- **version**: runs after the version bump but before the commit — generates `CHANGELOG.md` from conventional commits via `conventional-changelog-cli` (angular preset) and stages it. The release commit therefore includes updated `CHANGELOG.md`.
- **postversion**: runs `git push --follow-tags origin HEAD` after the version commit so the new commit and tag are pushed.

The version commit message is `chore(release): X.Y.Z` (conventional-commit style). Use conventional commit messages (e.g. `fix:`, `feat:`, `docs:`) so the changelog stays accurate.

After the tag is pushed, the **Release** workflow (`.github/workflows/release.yml`) runs: it first runs the **Test** workflow (lint + test) for defense in depth, then (1) creates a [GitHub Release](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/releases) using [LiquidLogicLabs/git-action-release](https://github.com/LiquidLogicLabs/git-action-release) with `CHANGELOG.md` as the body, and (2) updates the major floating tag (e.g. `v1`) using [LiquidLogicLabs/git-action-tag-floating-version](https://github.com/LiquidLogicLabs/git-action-tag-floating-version) so `@v1` always resolves to the latest 1.x.y. No extra steps are required for each release.
