# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). New entries are generated from conventional commits via [conventional-changelog-cli](https://github.com/conventional-changelog/conventional-changelog).

## [1.0.0] - 2026-02-26

### Added

- Initial release: resolve Docker build context and Dockerfile path for workflows that run at repo root (e.g. under act) when the Dockerfile lives in a subdirectory.
- Inputs: `dockerfile`, `workspace`, `set-env`, `verbose`.
- Outputs: `workflow-dir`, `docker-build-context`, `docker-file`; optional `GITHUB_ENV` when `set-env` is true.
