## [1.0.6](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/compare/v1.0.5...v1.0.6) (2026-09-04)



## [1.0.5](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/compare/v1.0.4...v1.0.5) (2026-09-04)


### Bug Fixes

* stop a fork-controlled directory name reaching the shell ([3de5f8c](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/commit/3de5f8c06c3444f8e3e4f3ec9bbf1e1cd52487c9))



## [1.0.4](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/compare/v1.0.3...v1.0.4) (2026-07-05)



## [1.0.3](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/compare/v1.0.2...v1.0.3) (2026-04-21)



## [1.0.2](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/compare/v1.0.1...v1.0.2) (2026-03-02)


### Bug Fixes

* **ci:** runner-contract step pass on GitHub and act ([35898e9](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/commit/35898e9c959366da668c1ed24d4854c51b518c4e))
* support act, Gitea, and hosted runners via legacy set-output/set-env ([9c6ec99](https://github.com/LiquidLogicLabs/git-action-docker-act-compatibility/commit/9c6ec99b9c668b730c97c823ce3d3540eb5748f5))



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
