#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
readonly REPO_ROOT

# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

readonly ISSUES_FILE="${REPO_ROOT}/config/github/issues.tsv"
readonly LABELS_FILE="${REPO_ROOT}/config/github/labels.tsv"
readonly MILESTONES_FILE="${REPO_ROOT}/config/github/milestones.tsv"
readonly FIELDS_FILE="${REPO_ROOT}/config/github/project-fields.tsv"

errors=0

validation_error() {
    printf '[project-config-validation] ERROR: %s\n' "$*" >&2
    ((errors += 1))
}

validation_pass() {
    printf '[project-config-validation] PASS: %s\n' "$*"
}

require_file() {
    local file="$1"

    if [[ ! -f "${file}" ]]; then
        validation_error "Required configuration file not found: ${file}"
        return 1
    fi
}

validate_issue_schema() {
    local invalid_rows

    invalid_rows="$(
        awk -F '\t' '
            NR == 1 {next}
            NF != 11 {
                print NR ":" NF
            }
        ' "${ISSUES_FILE}"
    )"

    if [[ -n "${invalid_rows}" ]]; then
        validation_error "issues.tsv contains rows that do not have 11 fields: ${invalid_rows}"
    else
        validation_pass "issues.tsv contains exactly 11 fields per issue."
    fi
}

validate_issue_header() {
    local expected
    local actual

    expected=$'key\ttitle\tmilestone\tpriority\tdomain\twork_type\tphase\teffort\trisk\tenvironment\tlabels'
    actual="$(head -n 1 "${ISSUES_FILE}")"

    if [[ "${actual}" != "${expected}" ]]; then
        validation_error "issues.tsv header does not match the required schema."
    else
        validation_pass "issues.tsv header is valid."
    fi
}

validate_unique_issue_keys() {
    local duplicates

    duplicates="$(
        tail -n +2 "${ISSUES_FILE}" |
            cut -f1 |
            sort |
            uniq -d
    )"

    if [[ -n "${duplicates}" ]]; then
        validation_error "Duplicate issue keys detected: ${duplicates}"
    else
        validation_pass "Issue keys are unique."
    fi
}

validate_unique_issue_titles() {
    local duplicates

    duplicates="$(
        tail -n +2 "${ISSUES_FILE}" |
            cut -f2 |
            sort |
            uniq -d
    )"

    if [[ -n "${duplicates}" ]]; then
        validation_error "Duplicate issue titles detected: ${duplicates}"
    else
        validation_pass "Issue titles are unique."
    fi
}

validate_no_backslashes() {
    local file

    for file in \
        "${ISSUES_FILE}" \
        "${LABELS_FILE}" \
        "${MILESTONES_FILE}" \
        "${FIELDS_FILE}"; do

        if grep -Fq '\' "${file}"; then
            validation_error "Unexpected backslash detected in ${file}"
        else
            validation_pass "No unexpected backslashes in $(basename "${file}")."
        fi
    done
}

validate_controlled_values() {
    local invalid

    invalid="$(
        awk -F '\t' '
            NR == 1 {next}

            $4 !~ /^(P0|P1|P2)$/ {
                print "line " NR ": invalid priority: " $4
            }

            $5 !~ /^(Governance|IAM|Networking|Compute|Storage|Database|Containers|Kubernetes|Serverless|Security|Observability|DevSecOps|FinOps|Disaster Recovery|Integration|Portfolio)$/ {
                print "line " NR ": invalid domain: " $5
            }

            $6 !~ /^(Feature|Security|Automation|Documentation|Bug|Research)$/ {
                print "line " NR ": invalid work type: " $6
            }

            $7 !~ /^(Foundation|Build|Integrate|Validate|Complete)$/ {
                print "line " NR ": invalid phase: " $7
            }

            $8 !~ /^(XS|S|M|L|XL)$/ {
                print "line " NR ": invalid effort: " $8
            }

            $9 !~ /^(Low|Medium|High|Critical)$/ {
                print "line " NR ": invalid risk: " $9
            }

            $10 !~ /^(Lab|Development|Staging|Production-like|Air-gapped Simulation)$/ {
                print "line " NR ": invalid environment: " $10
            }
        ' "${ISSUES_FILE}"
    )"

    if [[ -n "${invalid}" ]]; then
        validation_error "Invalid controlled values detected:
${invalid}"
    else
        validation_pass "All issue controlled values are valid."
    fi
}

validate_milestone_references() {
    local missing

    missing="$(
        comm -23 \
            <(tail -n +2 "${ISSUES_FILE}" | cut -f3 | sort -u) \
            <(cut -f1 "${MILESTONES_FILE}" | sort -u)
    )"

    if [[ -n "${missing}" ]]; then
        validation_error "Issues reference undefined milestones: ${missing}"
    else
        validation_pass "All issue milestone references are configured."
    fi
}

validate_label_references() {
    local required_labels
    local configured_labels
    local missing

    required_labels="$(mktemp)"
    configured_labels="$(mktemp)"

    tail -n +2 "${ISSUES_FILE}" |
        cut -f11 |
        tr ',' '\n' |
        sort -u > "${required_labels}"

    cut -f1 "${LABELS_FILE}" |
        sort -u > "${configured_labels}"

    missing="$(
        comm -23 "${required_labels}" "${configured_labels}"
    )"

    rm -f "${required_labels}" "${configured_labels}"

    if [[ -n "${missing}" ]]; then
        validation_error "Issues reference undefined labels: ${missing}"
    else
        validation_pass "All issue label references are configured."
    fi
}

validate_github_milestones() {
    local configured
    local actual
    local missing

    configured="$(mktemp)"
    actual="$(mktemp)"

    cut -f1 "${MILESTONES_FILE}" |
        sort -u > "${configured}"

    gh api \
        --paginate \
        "repos/${GITHUB_REPOSITORY}/milestones?state=all&per_page=100" \
        --jq '.[].title' |
        sort -u > "${actual}"

    missing="$(
        comm -23 "${configured}" "${actual}"
    )"

    rm -f "${configured}" "${actual}"

    if [[ -n "${missing}" ]]; then
        validation_error "Configured milestones missing from GitHub: ${missing}"
    else
        validation_pass "All configured milestones exist in GitHub."
    fi
}

validate_github_labels() {
    local configured
    local actual
    local missing

    configured="$(mktemp)"
    actual="$(mktemp)"

    cut -f1 "${LABELS_FILE}" |
        sort -u > "${configured}"

    gh label list \
        --repo "${GITHUB_REPOSITORY}" \
        --limit 100 \
        --json name \
        --jq '.[].name' |
        sort -u > "${actual}"

    missing="$(
        comm -23 "${configured}" "${actual}"
    )"

    rm -f "${configured}" "${actual}"

    if [[ -n "${missing}" ]]; then
        validation_error "Configured labels missing from GitHub: ${missing}"
    else
        validation_pass "All configured labels exist in GitHub."
    fi
}

main() {
    initialize_github_automation

    require_file "${ISSUES_FILE}"
    require_file "${LABELS_FILE}"
    require_file "${MILESTONES_FILE}"
    require_file "${FIELDS_FILE}"

    if ((errors > 0)); then
        fail "Required project configuration files are missing."
    fi

    printf '[project-config-validation] Starting project configuration validation.\n'

    validate_issue_header
    validate_issue_schema
    validate_unique_issue_keys
    validate_unique_issue_titles
    validate_no_backslashes
    validate_controlled_values
    validate_milestone_references
    validate_label_references
    validate_github_milestones
    validate_github_labels

    printf '\n'

    if ((errors > 0)); then
        printf '[project-config-validation] FAILED: %d validation error(s).\n' \
            "${errors}" >&2
        exit 1
    fi

    printf '[project-config-validation] SUCCESS: all project configuration checks passed.\n'
}

main "$@"
