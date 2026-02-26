## [1.0.1](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/compare/v1.0.0...v1.0.1) (2026-02-26)


### Bug Fixes

* GITHUB_OUTPUT handling and align workflows with best practices ([e7f4659](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/commit/e7f4659872871b1e4eeb5f93400137dcf7a931cd))
* **release:** allow-updates so re-run can update existing release ([0d997d1](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/commit/0d997d16a70ca43414fe7d1ecb1c78a63b1ec3e1))
* **release:** use LiquidLogicLabs actions and add floating tag step ([dd20fd3](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/commit/dd20fd3826e095eb72f8feb7a314e5c5c2dc736d))



# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). New entries are generated from conventional commits via [conventional-changelog-cli](https://github.com/conventional-changelog/conventional-changelog).

## [1.0.0] - 2026-02-26

### Added

- Initial release: resolve Docker build context and Dockerfile path for workflows that run at repo root (e.g. under act) when the Dockerfile lives in a subdirectory.
- Inputs: `dockerfile`, `workspace`, `set-env`, `verbose`.
- Outputs: `workflow-dir`, `docker-build-context`, `docker-file`; optional `GITHUB_ENV` when `set-env` is true.
