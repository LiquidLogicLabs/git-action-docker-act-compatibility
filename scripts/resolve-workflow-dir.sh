#!/usr/bin/env bash
# Resolve Docker build context and Dockerfile path for act/subdirectory workflows.
# When the job runs at repo root (e.g. under act) but the Dockerfile lives in a
# subdirectory, we search for it and set workflow_dir / env so downstream steps work.

set -euo pipefail

# --- Inputs (from action.yml via env) -----------------------------------------
DOCKER_FILE="${INPUT_DOCKERFILE:-Dockerfile}"
# Dir we treat as repo root (fallback to pwd for minimal envs e.g. act composite steps).
WORKSPACE="${INPUT_WORKSPACE:-${GITHUB_WORKSPACE:-$(pwd)}}"
SET_ENV="${INPUT_SET_ENV:-true}"                    # Write to GITHUB_ENV?
VERBOSE="${INPUT_VERBOSE:-false}"

# Always shown (normal progress / outcome).
log_info() {
  echo "$@"
}

# Shown only when verbose=true (diagnostic detail). Use if so failed [ ] does not trigger set -e.
log_verbose() {
  if [ "${VERBOSE}" = 'true' ] || [ "${VERBOSE}" = '1' ]; then echo "$@"; fi
}

# --- Resolve workflow directory and Dockerfile path --------------------------
# Default: assume workflow at repo root (Dockerfile in cwd).
CURRENT_DIR=$(pwd)
WORKFLOW_DIR='.'
DOCKER_FILE_PATH="${DOCKER_FILE}"

log_verbose "Current directory: ${CURRENT_DIR}"
log_verbose "Workspace: ${WORKSPACE}"
log_verbose "DOCKER_FILE: ${DOCKER_FILE}"

# Only search when we're at "repo root" (cwd == workspace). Otherwise the job
# was started from a specific dir and we use that as-is.
if [ "${CURRENT_DIR}" = "${WORKSPACE}" ]; then
  log_verbose "Current dir equals workspace"
  if [ ! -f "${DOCKER_FILE}" ]; then
    # No Dockerfile here; search from cwd (first match wins).
    log_verbose "Dockerfile NOT found in current directory, searching for it"
    DOCKERFILE_PATH=$(find . -type f -name "${DOCKER_FILE}" -print -quit 2>/dev/null || true)
    if [ -n "${DOCKERFILE_PATH}" ]; then
      WORKFLOW_DIR=$(dirname "${DOCKERFILE_PATH}")
      DOCKER_FILE_PATH="${WORKFLOW_DIR}/${DOCKER_FILE}"
      log_verbose "Found Dockerfile at: ${DOCKERFILE_PATH}"
      log_verbose "Detected workflow in subdirectory: ${WORKFLOW_DIR}"
    else
      log_info "WARNING: Could not find Dockerfile: ${DOCKER_FILE}"
    fi
  else
    log_verbose "Workflow at root level (Dockerfile found)"
  fi
else
  log_verbose "Running in non-root directory"
fi

log_info "Using workflow directory: ${WORKFLOW_DIR} (docker-file: ${DOCKER_FILE_PATH})"

# --- Action outputs -----------------------------------------------------------
# Support GitHub Actions, Gitea Actions, act (local and hosted): write to
# GITHUB_OUTPUT/GITHUB_ENV when set; only emit legacy ::set-output::/::set-env::
# to stdout when those are unset (so act/Gitea can capture). When the runner
# provides output/env files, do not emit legacy — GitHub rejects ::set-env in logs.
# Percent-encode for legacy format: % -> %25, newline -> %0A, \r -> %0D.
encode_legacy() {
  local v="$1"
  v="${v//%/%25}"
  v="${v//$'\n'/%0A}"
  v="${v//$'\r'/%0D}"
  printf '%s' "$v"
}

emit_outputs_legacy() {
  echo "::set-output name=workflow-dir::$(encode_legacy "${WORKFLOW_DIR}")"
  echo "::set-output name=docker-build-context::$(encode_legacy "${WORKFLOW_DIR}")"
  echo "::set-output name=docker-file::$(encode_legacy "${DOCKER_FILE_PATH}")"
}

emit_env_legacy() {
  echo "::set-env name=DOCKER_BUILD_CONTEXT::$(encode_legacy "${WORKFLOW_DIR}")"
  echo "::set-env name=DOCKER_FILE::$(encode_legacy "${DOCKER_FILE_PATH}")"
}

OUTPUT_DEST="${OUTPUT_FILE:-${GITHUB_OUTPUT:-}}"
ENV_DEST="${GITHUB_ENV_FILE:-${GITHUB_ENV:-}}"

if [ -n "${OUTPUT_DEST}" ]; then
  {
    echo "workflow-dir=${WORKFLOW_DIR}"
    echo "docker-build-context=${WORKFLOW_DIR}"
    echo "docker-file=${DOCKER_FILE_PATH}"
  } >> "${OUTPUT_DEST}"
else
  emit_outputs_legacy
  log_verbose "GITHUB_OUTPUT not set; outputs emitted via legacy ::set-output:: (act/Gitea compatibility)"
fi

if [ "${SET_ENV}" = 'true' ] || [ "${SET_ENV}" = '1' ]; then
  if [ -n "${ENV_DEST}" ]; then
    {
      echo "DOCKER_BUILD_CONTEXT=${WORKFLOW_DIR}"
      echo "DOCKER_FILE=${DOCKER_FILE_PATH}"
    } >> "${ENV_DEST}"
  else
    emit_env_legacy
    log_verbose "GITHUB_ENV not set; env emitted via legacy ::set-env:: (act/Gitea compatibility)"
  fi
fi
