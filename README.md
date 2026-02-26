# git-action-docker-act-compatibility

Resolve Docker build context and Dockerfile path for GitHub Actions workflows that run at repo root (e.g. under [act](https://github.com/nektos/act)) when the Dockerfile lives in a subdirectory.

## Use case

When a workflow file lives in a subdirectory (e.g. `some-mod/.github/workflows/docker-build.yaml`) and you run it from the repo root (as act or some CI does), the job’s working directory is the repo root. The Dockerfile may be in that subdirectory. This action finds the Dockerfile under the workspace and sets the build context and file path so later steps (e.g. `docker/build-push-action`) work without change.

## Inputs

| Input        | Required | Default             | Description                                                                 |
| ------------ | -------- | ------------------- | --------------------------------------------------------------------------- |
| `dockerfile` | No       | `Dockerfile`       | Basename of the Dockerfile to locate.                                       |
| `workspace`  | No       | (empty → `GITHUB_WORKSPACE`) | Directory treated as repo root; only when `pwd` equals this do we search.   |
| `set-env`    | No       | `true`              | If `true`, write `DOCKER_BUILD_CONTEXT` and `DOCKER_FILE` to `GITHUB_ENV`.   |
| `verbose`    | No       | `false`             | Emit debug logs.                                                            |

## Outputs

| Output                 | Description                                                                 |
| ---------------------- | --------------------------------------------------------------------------- |
| `workflow-dir`         | Resolved directory: `.` or the directory containing the found Dockerfile.  |
| `docker-build-context` | Same as `workflow-dir`; use as Docker build context.                        |
| `docker-file`          | Resolved path to the Dockerfile (e.g. `./subdir/Dockerfile` or `Dockerfile`).|

When `set-env` is `true`, the action also sets:

- `DOCKER_BUILD_CONTEXT`
- `DOCKER_FILE`

so downstream steps can use `env.DOCKER_BUILD_CONTEXT` and `env.DOCKER_FILE` without change.

## Versioning

- **`@v1`** — Floating tag: points to the latest `v1.x.y` release. Use for automatic minor/patch updates.
- **`@v1.0.0`** — Exact tag: pins to a specific version. Use for maximum reproducibility.

## Permissions required

No special permissions. Default `contents: read` is sufficient (the action only reads the repository filesystem to locate a Dockerfile).

## Example

```yaml
- name: Set workflow directory for act compatibility
  id: workdir
  uses: LiquidLogicLabs/git-action-docker-act-compatibility@v1
  with:
    dockerfile: ${{ env.DOCKER_FILE }}
    set-env: true
    verbose: ${{ env.DEBUG == 'true' || env.DEBUG == '1' }}

- name: Build and push image
  uses: docker/build-push-action@v6
  with:
    context: ${{ env.DOCKER_BUILD_CONTEXT }}
    file: ${{ env.DOCKER_FILE }}
    # ...
```

For contributor and development setup (lint, test, local act runs), see [DEVELOPMENT.md](DEVELOPMENT.md).

## Troubleshooting

- **Dockerfile not found**: Ensure the `dockerfile` input matches the actual filename (e.g. `Dockerfile` or `Dockerfile.dev`). If the job does not run from the repo root, set `workspace` to the directory that should be treated as root (e.g. `${{ github.workspace }}`).
- **No subdirectory detected under act**: When `pwd` equals `workspace`, the script searches from the current directory for the Dockerfile. Under act, the job often runs with `cwd` = repo root; leave `workspace` empty so it defaults to `GITHUB_WORKSPACE` and the search runs as expected.
- **Verbose output**: Set `verbose: true` (or `verbose: ${{ env.ACTIONS_STEP_DEBUG == 'true' }}`) to see resolved paths and search behavior in the logs.

## Security notes

- The action only reads the repository filesystem (find Dockerfile by name) and writes to `GITHUB_OUTPUT` and optionally `GITHUB_ENV`. It does not make network calls or consume secrets.
- Do not pass untrusted input as `dockerfile` or `workspace` if the workflow runs in a context where those could escape the repo (e.g. path traversal). When used with standard workflow values, risk is minimal.

## License

See repository license.
