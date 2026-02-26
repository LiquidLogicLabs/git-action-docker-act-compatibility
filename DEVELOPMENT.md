# Development

Contributor and developer notes for working on this action.

## Lint

Run [ShellCheck](https://www.shellcheck.net/) on the script:

```bash
shellcheck scripts/*.sh
```

CI runs this in the **lint** job.

## Test

The **test** job in CI creates a fixture (`testdata/subdir/Dockerfile`), runs `scripts/resolve-workflow-dir.sh`, and asserts the outputs. To run the script locally with the same layout:

```bash
mkdir -p testdata/subdir
touch testdata/subdir/Dockerfile
INPUT_DOCKERFILE=Dockerfile INPUT_WORKSPACE=$PWD INPUT_SET_ENV=true INPUT_VERBOSE=true \
  GITHUB_WORKSPACE=$PWD GITHUB_OUTPUT=$PWD/out.txt GITHUB_ENV=$PWD/env.txt \
  bash scripts/resolve-workflow-dir.sh
cat out.txt
```

(`testdata/`, `out.txt`, and `env.txt` are in `.gitignore`.)

## Local workflow testing (act)

To run the CI workflow locally with [act](https://github.com/nektos/act):

```bash
npm run test:act
# Or: npm run test:act:ci:push
```

Available scripts (see `package.json`):

- `test:act` — run full CI workflow
- `test:act:verbose` — same with act `-v`
- `test:act:ci:push` — use push event payload (`.github/workflows/.act/event-push.json`)
- `test:act:ci:lint` — run only the **lint** job
- `test:act:ci:test` — run only the **test** job

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
- **postversion**: runs `git push --follow-tags origin HEAD` after the version commit so the new commit and tag are pushed.

The version commit message is `chore(release): X.Y.Z` (conventional-commit style).
