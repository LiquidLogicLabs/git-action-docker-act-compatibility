#!/usr/bin/env bash
# Resolve Docker build context and Dockerfile path for act/subdirectory workflows.
# When the job runs at repo root (e.g. under act) but the Dockerfile lives in a
# subdirectory, we search for it and set workflow_dir / env so downstream steps work.

set -euo pipefail

# --- Inputs (from action.yml via env) -----------------------------------------
DOCKER_FILE="${INPUT_DOCKERFILE:-Dockerfile}"
WORKSPACE="${INPUT_WORKSPACE:-$GITHUB_WORKSPACE}"   # Dir we treat as repo root
SET_ENV="${INPUT_SET_ENV:-true}"                    # Write to GITHUB_ENV?
VERBOSE="${INPUT_VERBOSE:-false}"

# Always shown (normal progress / outcome).
log_info() {
  echo "$@"
}

# Shown only when verbose=true (diagnostic detail).
log_verbose() {
  [ "${VERBOSE}" = 'true' ] || [ "${VERBOSE}" = '1' ] && echo "$@"
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
# Step outputs (always); optional env vars when set-env is true.
{
  echo "workflow-dir=${WORKFLOW_DIR}"
  echo "docker-build-context=${WORKFLOW_DIR}"
  echo "docker-file=${DOCKER_FILE_PATH}"
} >> "${GITHUB_OUTPUT}"

if [ "${SET_ENV}" = 'true' ] || [ "${SET_ENV}" = '1' ]; then
  {
    echo "DOCKER_BUILD_CONTEXT=${WORKFLOW_DIR}"
    echo "DOCKER_FILE=${DOCKER_FILE_PATH}"
  } >> "${GITHUB_ENV}"
fi
