#!/bin/bash

# ========================================
# Grade Checker for Practical course:
# Advanced Systems Programming in C/Rust
# ========================================

set -euo pipefail

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BOLD="\033[1m"
NC="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POINTS_CONF="$SCRIPT_DIR/points.conf"
DEADLINES_CONF="$SCRIPT_DIR/deadlines.conf"

if [[ ! -f "$POINTS_CONF" ]]; then
    echo "ERROR: points.conf not found at $POINTS_CONF" 1>&2
    exit 1
fi
if [[ ! -f "$DEADLINES_CONF" ]]; then
    echo "ERROR: deadlines.conf not found at $DEADLINES_CONF" 1>&2
    exit 1
fi

get_expected_points() {
    local task="$1"
    grep "^$task " "$POINTS_CONF" 2>/dev/null | awk '{print $2}' || echo "0"
}

get_deadline() {
    local task="$1"
    grep "^$task " "$DEADLINES_CONF" 2>/dev/null | awk '{print $2}' || echo ""
}

export -f get_expected_points
export -f get_deadline
export POINTS_CONF
export DEADLINES_CONF

AWK_PROG=$(cat <<EOF
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

TASKS=()
while read -r line; do
    [[ -z "$line" || "$line" =~ ^#.* ]] && continue
    task="${line%% *}"
    TASKS+=("$task")
done < "$POINTS_CONF"


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
}


gh_retry() {
    local suppress_errors=false
    if [[ "${1:-}" == "--suppress-errors" ]]; then
        suppress_errors=true
        shift
    fi

    local max_retries=2
    local retry_delay=10
    local stderr_file
    stderr_file=$(mktemp)
    local ret=0

    for ((i=0; i<=max_retries; i++)); do
        if gh "$@" 2>"$stderr_file"; then
            rm -f "$stderr_file"
            return 0
        fi
        ret=$?
        if grep -qi "rate limit\|secondary rate\|abuse" "$stderr_file"; then
            if [[ $i -lt $max_retries ]]; then
                echo "Rate limited, retrying in ${retry_delay}s (attempt $((i+1))/$max_retries)..." 1>&2
                sleep $retry_delay
                retry_delay=$((retry_delay * 2))
            else
                cat "$stderr_file" 1>&2  # always show rate-limit exhaustion
                rm -f "$stderr_file"
                return 2
            fi
        else
            [[ "$suppress_errors" == false ]] && cat "$stderr_file" 1>&2
            rm -f "$stderr_file"
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

    # Skip API entirely for zero-point tasks unless --ignore-max is set
    if [[ "$EXPECTED_MAX" -eq 0 && "$IGNORE_MAX" != "true" ]]; then
        printf "%s %s %s\n" "$TASK-$USER" "0" "0"
        return 0
    fi

    # Get runs from main branch only
    if [[ -n "$DEADLINE" ]]; then
        RUN_INFO=$(gh_retry --suppress-errors run list -R "$REPO" --branch main --status=completed --limit 1 --created "<$DEADLINE" --json 'databaseId,headSha' --jq 'if length > 0 then "\(.[0].databaseId) \(.[0].headSha)" else empty end') && RUN_EXIT=0 || RUN_EXIT=$?
    else
        RUN_INFO=$(gh_retry --suppress-errors run list -R "$REPO" --branch main --status=completed --limit 1 --json 'databaseId,headSha' --jq 'if length > 0 then "\(.[0].databaseId) \(.[0].headSha)" else empty end') && RUN_EXIT=0 || RUN_EXIT=$?
    fi
    [[ $RUN_EXIT -eq 2 ]] && exit 2

    if [[ $RUN_EXIT -eq 0 && -n "$RUN_INFO" ]]; then
        RUN_ID="${RUN_INFO%% *}"
        COMMIT_SHA="${RUN_INFO#* }"
        { SCORE=$(gh_retry run view -R "$REPO" "$RUN_ID" --json jobs \
            --jq '[.jobs[].steps[].name | match("Points ([0-9]+)/([0-9]+)") | .captures | {score: .[0].string, max: .[1].string}] | first | "\(.score)/\(.max)"'); } \
            && RV_EXIT=0 || RV_EXIT=$?
        [[ $RV_EXIT -eq 2 ]] && exit 2

        if [[ -n "$COMMIT_SHA" ]]; then
            log_info "INFO: $TASK_KEY - Using commit ${COMMIT_SHA:0:7}"
        fi
    else
        if [[ -n "$DEADLINE" ]]; then
            ANY_RUNS_EXIT=0
            ANY_RUNS=$(gh_retry --suppress-errors run list -R "$REPO" --branch main --limit 1 --json 'databaseId' -q '.[0].databaseId') || ANY_RUNS_EXIT=$?
            [[ $ANY_RUNS_EXIT -eq 2 ]] && exit 2
            if [[ -n "$ANY_RUNS" ]]; then
                log_info "INFO: $TASK_KEY - No CI runs before deadline (all runs were after deadline)"
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
        log_info "WARNING: $TASK_KEY discovered max points ($DISCOVERED_MAX) differs from expected ($EXPECTED_MAX)"
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


check_grade() {
    local USER="$1"

    export -f check_task

    if [[ "$FORMAT" == "csv" ]]; then
        local TMPFILES=()
        for task in "${TASKS[@]}"; do
            local tmpfile
            tmpfile=$(mktemp "/tmp/${task}.XXXXXX")
            TMPFILES+=("$tmpfile")
            bash -euo pipefail -c 'check_task "$1" "$2" "$3"' _ "$ORG" "$task" "$USER" > "$tmpfile" \
                || { ec=$?; for f in "${TMPFILES[@]}"; do rm -f "$f"; done; exit $ec; }
        done

        local SUM=0
        local SCORES=()
        for tmpfile in "${TMPFILES[@]}"; do
            local score
            score=$(awk '{print $2}' "$tmpfile")
            rm "$tmpfile"
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
        printf '%s\n' "${TASKS[@]}" \
            | $XARGS -P 10 -I {} bash -euo pipefail -c 'check_task "$1" "$2" "$3"' _ "$ORG" "{}" "$USER" \
            | sort \
            | awk "$AWK_PROG" \
            | (echo -e "${BOLD}TASK SCORE MAX${NC}"; cat) \
            | column -t -s ' '
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
    echo -e ""
    echo -e "${BOLD}ARGUMENTS${NC}"
    echo -e "  user - list of usernames to be checked"
    echo -e ""
    echo -e "${BOLD}MISCELLANEOUS${NC}"
    echo -e "  github-cli is needed for the script to work."
    echo -e "  coreutils and awk are expected to be present."

}

while [[ $# -gt 0 ]]; do
    case $1 in
        -h | --help)
            print_help
            exit
        ;;
        -v | --verbose)
            VERBOSE=true
            shift
        ;;
        -f | --format)
            FORMAT="$2"
            shift
            shift
        ;;
        -f=* | --format=*)
            FORMAT="${1#*=}"
            shift
        ;;
        --name)
            NAME="$2"
            shift
            shift
        ;;
        --name=*)
            NAME="${1#*=}"
            shift
        ;;
        --mnum)
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

