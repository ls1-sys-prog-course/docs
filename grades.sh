#!/bin/bash

# ========================================
# Grade Checker for Practical course:
# Advanced Systems Programming in C/Rust
# ========================================

set -e

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BOLD="\033[1m"
NC="\033[0m"

SCRIPT_DIR="$(dirname "$0")"
POINTS_CONF="$SCRIPT_DIR/points.conf"

get_expected_points() {
    local task="$1"
    grep "^$task " "$POINTS_CONF" 2>/dev/null | awk '{print $2}' || echo "0"
}

export -f get_expected_points
export POINTS_CONF

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

TASKS=()
while read -r line; do
    [[ -z "$line" || "$line" =~ ^#.* ]] && continue
    task=$(echo "$line" | awk '{print $1}')
    TASKS+=("$task")
done < "$POINTS_CONF"


check_command() {
    if ! command -v gh > /dev/null; then
        echo "github-cli is not installed!"
        echo "Install and configure it first."
        exit 1
    fi

    if ! gh auth status 2> /dev/null; then
        echo "github-cli is not configured!"
        echo "Run 'gh auth login' first."
        exit 1
    fi

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


check_task() {
    local ORG="$1"
    local TASK="$2"
    local USER="$3"

    REPO="$ORG/$TASK-$USER"
    TASK_KEY="$TASK"

    EXPECTED_MAX=$(get_expected_points "$TASK_KEY")

    ERR_OUTPUT=$(gh run list -R "$REPO" --json 'databaseId' -q '.[0].databaseId' 2>&1)
    if [[ $? -eq 0 && -n "$ERR_OUTPUT" ]]; then
        SCORE=$(gh run view -R "$REPO" "$ERR_OUTPUT" 2>/dev/null | grep 'Points' | awk '{ print $3 }')
    else
        echo "INFO: $TASK_KEY - Repository not found or no CI runs available" 1>&2
        [[ "$VERBOSE" == "true" ]] && echo "$ERR_OUTPUT" 1>&2
        SCORE=""
    fi

    [[ -z "$SCORE" ]] && SCORE="0/0"

    DISCOVERED_MAX=${SCORE#*/}
    SCORE=${SCORE%/*}

    if [[ "$DISCOVERED_MAX" != "0" && "$DISCOVERED_MAX" != "$EXPECTED_MAX" ]]; then
        echo "WARNING: $TASK_KEY discovered max points ($DISCOVERED_MAX) differs from expected ($EXPECTED_MAX)" 1>&2
    fi

    if [[ "$SCORE" -gt "$EXPECTED_MAX" ]]; then
        SCORE="$EXPECTED_MAX"
    fi

    printf "%s %s %s\n" "$TASK-$USER" "$SCORE" "$EXPECTED_MAX"
}


check_grade() {
    USER="$1"
    printf "Checking grades for user %s\n" "$USER" 1>&2

    export -f check_task
    echo -n "${TASKS[@]}" \
        | $XARGS -d ' ' -P 10 -I {} bash -c "check_task $ORG \"{}\" $USER" \
        | sort \
        | awk "$AWK_PROG" \
        | (echo -e "${BOLD}TASK SCORE MAX${NC}"; cat) \
        | column -t -s ' '
}


print_help() {
    echo -e "Grade Checker for Practical course: Advanced Systems Programming in C/Rust"
    echo -e "${BOLD}USAGE${NC}"
    echo -e "  $0 [flags] [users]"
    echo -e ""
    echo -e "${BOLD}FLAGS${NC}"
    echo -e "  -h, --help     print this help"
    echo -e "  -v, --verbose  show detailed error messages"
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
        -o | --org)
            ORG="$2"
            shift
            shift
        ;;
        -o=* | --org=*)
            ORG="${1#*=}"
            shift
        ;;
        *)
            USERS+=("$1")
            shift
        ;;
    esac
done

check_command

export VERBOSE

[[ ${#USERS[@]} -eq 0 ]] && USERS=("$(gh api /user -q '.login')")

for user in "${USERS[@]}"; do
    check_grade "$user"
done

