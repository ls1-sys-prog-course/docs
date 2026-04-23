#!/bin/bash

set -euo pipefail

RED="\033[31m"
GREEN="\033[32m"
BOLD="\033[1m"
NC="\033[0m"

require_bash_43() {
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ||
        ("${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -lt 3) ]]; then
        echo "ERROR: bash 4.3+ is required (current: $BASH_VERSION)." 1>&2
        echo "Run with a newer bash, e.g.:" 1>&2
        echo "  nix shell nixpkgs#bash --command bash ./grade.sh ..." 1>&2
        echo "  or /opt/homebrew/bin/bash ./grade.sh ..." 1>&2
        exit 1
    fi
}

require_bash_43

TASKS=()
declare -A TASK_MAX
declare -A TASK_DEADLINE

TASK_CONFIG_DATA=$(
    cat << 'EOF'
# task	max_points	deadline_iso8601
# deadline may be empty if no deadline is enforced
task0-sort	0	2026-11-03T15:00:00+01:00
task1-syscalls	30	2026-11-10T15:00:00+01:00
task2-fileio	30	2026-11-17T15:00:00+01:00
task3-processes	30	2026-11-24T15:00:00+01:00
task4-concurrency	30	2026-12-01T15:00:00+01:00
task5-memory	30	2026-12-08T15:00:00+01:00
task6-sockets	30	2026-12-15T15:00:00+01:00
task7-performance	0	
task8-llvm	30	2026-12-22T15:00:00+01:00
EOF
)

load_task_config() {
    declare -gA TASK_MAX
    declare -gA TASK_DEADLINE
    TASKS=()
    TASK_MAX=()
    TASK_DEADLINE=()

    local task max deadline extra
    while IFS=$'\t' read -r task max deadline extra; do
        [[ -z "$task" || "$task" =~ ^# ]] && continue
        if [[ -n "$extra" ]]; then
            echo "ERROR: invalid task config row for '$task'" 1>&2
            exit 1
        fi
        if ! [[ "$max" =~ ^[0-9]+$ ]]; then
            echo "ERROR: invalid max points '$max' for task '$task'" 1>&2
            exit 1
        fi
        TASKS+=("$task")
        TASK_MAX["$task"]="$max"
        TASK_DEADLINE["$task"]="${deadline:-}"
    done <<< "$TASK_CONFIG_DATA"

    if [[ ${#TASKS[@]} -eq 0 ]]; then
        echo "ERROR: no tasks loaded from embedded task config" 1>&2
        exit 1
    fi
}

ensure_task_loaded() {
    local task="$1"
    if ! declare -p TASK_MAX > /dev/null 2>&1 ||
        [[ "$(declare -p TASK_MAX 2> /dev/null)" != declare\ -A* ]] ||
        [[ -z "${TASK_MAX[$task]+x}" ]]; then
        load_task_config
    fi
}

get_expected_points() {
    local task="$1"
    ensure_task_loaded "$task"
    printf '%s\n' "${TASK_MAX[$task]:-0}"
}

get_deadline() {
    local task="$1"
    ensure_task_loaded "$task"
    printf '%s\n' "${TASK_DEADLINE[$task]:-}"
}

export -f load_task_config
export -f ensure_task_loaded
export -f get_expected_points
export -f get_deadline
export TASK_CONFIG_DATA

AWK_PROG=$(
    cat << EOF
{
    if (\$2 == \$3) {
        printf("%s %s%s%s %s\n", \$1, "$GREEN", \$2, "$NC", \$3)
    } else {
        printf("%s %s%s%s %s\n", \$1, "$RED", \$2, "$NC", \$3)
    }
    score += \$2
    max += \$3
}
END {
    if (score == max) {
        printf("summary %s%s%s %s\n", "$GREEN", score, "$NC", max)
    } else {
        printf("summary %s%s%s %s\n", "$RED", score, "$NC", max)
    }
}
EOF
)

ORG="ls1-sys-prog-course"
USERS=()
VERBOSE=false
FORMAT="table"
NAME=""
MNUM=""
IGNORE_MAX=false

check_command() {
    if ! command -v gh > /dev/null; then
        echo "github-cli is not installed!"
        echo "Install and configure it first."
        exit 1
    fi

    [[ "$FORMAT" == "csv" ]] && return 0

    if [[ $(uname) = "Darwin" ]]; then
        if command -v xargs > /dev/null && xargs --version 2>&1 | grep -q GNU; then
            XARGS="xargs"
        elif command -v gxargs > /dev/null; then
            XARGS="gxargs"
        else
            echo "GNU xargs is not installed!"
            echo "Install it with: brew install findutils"
            echo "Or with nix: nix shell nixpkgs#findutils"
            exit 1
        fi
    else
        XARGS="xargs"
        if ! command -v "$XARGS" > /dev/null; then
            echo "$XARGS is not installed."
            exit 1
        fi
    fi

    if ! command -v column > /dev/null; then
        echo "column is not installed."
        echo "Install it with: nix shell nixpkgs#util-linux"
        exit 1
    fi
}

gh_retry() {
    local suppress_errors=false
    if [[ "${1:-}" == "--suppress-errors" ]]; then
        suppress_errors=true
        shift
    fi

    if [[ "${VERBOSE:-false}" == "true" ]]; then
        suppress_errors=false
    fi

    local max_retries=2
    local retry_delay=10
    local ret=0

    for ((i = 0; i <= max_retries; i++)); do
        if [[ "$suppress_errors" == true ]]; then
            gh "$@" 2> /dev/null && return 0 || ret=$?
        else
            gh "$@" && return 0 || ret=$?
        fi

        if gh api rate_limit --jq '.resources.core.remaining == 0' 2> /dev/null | grep -q true; then
            if [[ $i -lt $max_retries ]]; then
                echo "Rate limited, retrying in ${retry_delay}s " \
                    "(attempt $((i + 1))/$max_retries)..." 1>&2
                sleep $retry_delay
                retry_delay=$((retry_delay * 2))
            else
                echo "ERROR: API rate limit exhausted, stopping." 1>&2
                return 2
            fi
        else
            return $ret
        fi
    done
}
export -f gh_retry

log_info() {
    [[ "${FORMAT:-table}" != "csv" ]] && echo "$@" 1>&2 || true
}
export -f log_info

check_task() {
    local ORG="$1"
    local TASK="$2"
    local USER="$3"

    REPO="$ORG/$TASK-$USER"
    TASK_KEY="$TASK"

    EXPECTED_MAX=$(get_expected_points "$TASK_KEY")
    DEADLINE=$(get_deadline "$TASK_KEY")

    if [[ "$EXPECTED_MAX" -eq 0 && "$IGNORE_MAX" != "true" ]]; then
        printf "%s %s %s\n" "$TASK-$USER" "0" "0"
        return 0
    fi

    local RUN_LIST_FILTER
    RUN_LIST_FILTER='map(select(.conclusion != "cancelled"))
		| if length > 0 then "\(.[0].databaseId) \(.[0].headSha)" else empty end'

    if [[ -n "$DEADLINE" ]]; then
        RUN_INFO=$(gh_retry --suppress-errors run list \
            -R "$REPO" \
            --branch main \
            --status=completed \
            --limit 20 \
            --created "<$DEADLINE" \
            --json 'databaseId,headSha,conclusion' \
            --jq "$RUN_LIST_FILTER") && RUN_EXIT=0 || RUN_EXIT=$?
    else
        RUN_INFO=$(gh_retry --suppress-errors run list \
            -R "$REPO" \
            --branch main \
            --status=completed \
            --limit 20 \
            --json 'databaseId,headSha,conclusion' \
            --jq "$RUN_LIST_FILTER") && RUN_EXIT=0 || RUN_EXIT=$?
    fi
    [[ $RUN_EXIT -eq 2 ]] && exit 2

    if [[ $RUN_EXIT -eq 0 && -n "$RUN_INFO" ]]; then
        COMMIT_SHA="${RUN_INFO#* }"
        { SCORE=$(gh_retry api "/repos/$REPO/commits/$COMMIT_SHA/check-runs" \
            --jq '[.check_runs[].output.summary
				| select(length > 0)
				| match("Points ([0-9]+)/([0-9]+)")
				| .captures
				| {score: .[0].string, max: .[1].string}] | first | "\(.score)/\(.max)"'); } &&
            RV_EXIT=0 || RV_EXIT=$?
        [[ $RV_EXIT -eq 2 ]] && exit 2

        if [[ -n "$COMMIT_SHA" ]]; then
            log_info "INFO: $TASK_KEY - Using commit ${COMMIT_SHA:0:7}"
        fi
    else
        if [[ -n "$DEADLINE" ]]; then
            ANY_RUNS_EXIT=0
            ANY_RUNS=$(gh_retry --suppress-errors run list \
                -R "$REPO" \
                --branch main \
                --limit 1 \
                --json 'databaseId' \
                -q '.[0].databaseId') || ANY_RUNS_EXIT=$?
            [[ $ANY_RUNS_EXIT -eq 2 ]] && exit 2
            if [[ -n "$ANY_RUNS" ]]; then
                log_info "INFO: $TASK_KEY - No CI runs before deadline " \
                    "(all runs were after deadline)"
            else
                log_info "INFO: $TASK_KEY - Repository not found or no CI runs available"
            fi
        else
            log_info "INFO: $TASK_KEY - Repository not found or no CI runs available"
        fi
        SCORE=""
    fi

    [[ -z "$SCORE" ]] && SCORE="0/0"

    DISCOVERED_MAX=${SCORE#*/}
    SCORE=${SCORE%/*}

    if [[ "$DISCOVERED_MAX" != "0" && "$DISCOVERED_MAX" != "$EXPECTED_MAX" ]]; then
        log_info "WARNING: $TASK_KEY discovered max points ($DISCOVERED_MAX) differs"
        log_info "         from expected ($EXPECTED_MAX)"
    fi

    if ! [[ "$SCORE" =~ ^[0-9]+$ ]]; then
        log_info "WARNING: $TASK_KEY - unexpected score format ('$SCORE'), defaulting to 0"
        SCORE=0
    fi

    if [[ "$IGNORE_MAX" != "true" && "$SCORE" -gt "$EXPECTED_MAX" ]]; then
        SCORE="$EXPECTED_MAX"
    fi

    printf "%s %s %s\n" "$TASK-$USER" "$SCORE" "$EXPECTED_MAX"
}
export -f check_task

check_grade() {
    local USER="$1"

    if [[ "$FORMAT" == "csv" ]]; then
        local SUM=0
        local SCORES=()
        for task in "${TASKS[@]}"; do
            local score ec=0
            local out
            out=$(check_task "$ORG" "$task" "$USER") || ec=$?
            [[ $ec -ne 0 ]] && exit $ec
            score=$(awk '{print $2}' <<< "$out")
            [[ -z "$score" ]] && score=0
            SCORES+=("$score")
            SUM=$((SUM + score))
        done

        local LINE="$USER,$NAME,$MNUM"
        for score in "${SCORES[@]}"; do
            LINE="$LINE,$score"
        done
        printf "%s\n" "$LINE,$SUM"
    else
        printf "Checking grades for user %s\n" "$USER" 1>&2
        printf '%s\n' "${TASKS[@]}" |
            $XARGS -P 10 -I {} bash -euo pipefail \
                -c "check_task \"\$1\" \"\$2\" \"\$3\"" \
                _ "$ORG" "{}" "$USER" |
            sort |
            awk "$AWK_PROG" |
            (
                echo -e "${BOLD}TASK SCORE MAX${NC}"
                cat
            ) |
            column -t -s ' '
    fi
}

print_help() {
    echo -e "Grade Checker for Practical course: Advanced Systems Programming in C/Rust"
    echo -e "${BOLD}USAGE${NC}"
    echo -e "  $0 [flags] [users]"
    echo -e ""
    echo -e "${BOLD}FLAGS${NC}"
    echo -e "  -h, --help              print this help"
    echo -e "  -v, --verbose           show detailed error messages"
    echo -e "  -f, --format=FORMAT     output format: table (default) or csv"
    echo -e "  --name=NAME             student name, included in csv output"
    echo -e "  --mnum=MNUM             matriculation number, included in csv output"
    echo -e "  --ignore-max            show real scores even for 0-point tasks; do not"
    echo -e "                          cap scores that exceed the configured maximum"
    echo -e "  --list-tasks            print the list of tasks (one per line) and exit"
    echo -e ""
    echo -e "${BOLD}ARGUMENTS${NC}"
    echo -e "  user - list of usernames to be checked"
    echo -e ""
    echo -e "${BOLD}MISCELLANEOUS${NC}"
    echo -e "  github-cli is needed for the script to work."
    echo -e "  coreutils and awk are expected to be present."

}

require_arg_value() {
    local flag="$1"
    local value="${2-}"
    if [[ -z "$value" ]]; then
        echo "ERROR: missing value for '$flag'" 1>&2
        exit 1
    fi
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h | --help)
            print_help
            exit
            ;;
        --list-tasks)
            load_task_config
            printf '%s\n' "${TASKS[@]}"
            exit
            ;;
        -v | --verbose)
            VERBOSE=true
            shift
            ;;
        -f | --format)
            require_arg_value "$1" "${2-}"
            FORMAT="$2"
            shift
            shift
            ;;
        -f=* | --format=*)
            FORMAT="${1#*=}"
            shift
            ;;
        --name)
            require_arg_value "$1" "${2-}"
            NAME="$2"
            shift
            shift
            ;;
        --name=*)
            NAME="${1#*=}"
            shift
            ;;
        --mnum)
            require_arg_value "$1" "${2-}"
            MNUM="$2"
            shift
            shift
            ;;
        --mnum=*)
            MNUM="${1#*=}"
            shift
            ;;
        --ignore-max)
            IGNORE_MAX=true
            shift
            ;;
        -o | --org)
            require_arg_value "$1" "${2-}"
            ORG="$2"
            shift
            shift
            ;;
        -o=* | --org=*)
            ORG="${1#*=}"
            shift
            ;;
        -*)
            echo "ERROR: unknown flag '$1'" 1>&2
            exit 1
            ;;
        *)
            USERS+=("$1")
            shift
            ;;
    esac
done

if [[ "$FORMAT" != "table" && "$FORMAT" != "csv" ]]; then
    echo "ERROR: unknown format '$FORMAT'; must be 'table' or 'csv'" 1>&2
    exit 1
fi

load_task_config
check_command

export VERBOSE
export FORMAT
export IGNORE_MAX

if [[ ${#USERS[@]} -eq 0 ]]; then
    USERS=("$(gh api /user -q '.login')")
fi

for user in "${USERS[@]}"; do
    check_grade "$user"
done
