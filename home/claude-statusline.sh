#!/usr/bin/env bash
# Claude Code Status Line - Maximum Information Display
# Receives JSON via stdin, outputs single status line

set -euo pipefail

input=$(cat)

# Helper to safely extract JSON values
json() { echo "$input" | jq -r "$1 // empty" 2>/dev/null || echo ""; }

# Model info
MODEL=$(json '.model.display_name')
MODEL_ID=$(json '.model.id')

# Directory info
CURRENT_DIR=$(json '.workspace.current_dir')
PROJECT_DIR=$(json '.workspace.project_dir')
DIR_NAME="${CURRENT_DIR##*/}"

# Show if we're in a subdirectory of project
SUBDIR=""
if [[ -n "$PROJECT_DIR" && "$CURRENT_DIR" != "$PROJECT_DIR" && "$CURRENT_DIR" == "$PROJECT_DIR"* ]]; then
    REL_PATH="${CURRENT_DIR#$PROJECT_DIR/}"
    DIR_NAME="${PROJECT_DIR##*/}/${REL_PATH}"
fi

# Context window info
CTX_SIZE=$(json '.context_window.context_window_size')
TOTAL_IN=$(json '.context_window.total_input_tokens')
TOTAL_OUT=$(json '.context_window.total_output_tokens')

# Current usage
CURRENT_IN=$(json '.context_window.current_usage.input_tokens')
CACHE_CREATE=$(json '.context_window.current_usage.cache_creation_input_tokens')
CACHE_READ=$(json '.context_window.current_usage.cache_read_input_tokens')

# Calculate context percentage
CTX_PCT="0"
CTX_USED="0"
if [[ -n "$CTX_SIZE" && "$CTX_SIZE" != "0" && "$CTX_SIZE" != "null" ]]; then
    # Current context = input + cache tokens
    CTX_USED=$((${CURRENT_IN:-0} + ${CACHE_CREATE:-0} + ${CACHE_READ:-0}))
    CTX_PCT=$((CTX_USED * 100 / CTX_SIZE))
fi

# Format token counts (K for thousands)
format_tokens() {
    local n="${1:-0}"
    if [[ "$n" == "" || "$n" == "null" ]]; then echo "0"; return; fi
    if (( n >= 1000000 )); then
        printf "%.1fM" "$(echo "scale=1; $n/1000000" | bc)"
    elif (( n >= 1000 )); then
        printf "%.1fk" "$(echo "scale=1; $n/1000" | bc)"
    else
        echo "$n"
    fi
}

TOTAL_IN_FMT=$(format_tokens "$TOTAL_IN")
TOTAL_OUT_FMT=$(format_tokens "$TOTAL_OUT")
CTX_USED_FMT=$(format_tokens "$CTX_USED")
CTX_SIZE_FMT=$(format_tokens "$CTX_SIZE")

# Cost info
COST=$(json '.cost.total_cost_usd')
if [[ -n "$COST" && "$COST" != "null" ]]; then
    COST_FMT=$(printf "$%.2f" "$COST")
else
    COST_FMT="\$0.00"
fi

# Duration - convert ms to human readable
DURATION_MS=$(json '.cost.total_duration_ms')
format_duration() {
    local ms="${1:-0}"
    if [[ "$ms" == "" || "$ms" == "null" || "$ms" == "0" ]]; then echo "0s"; return; fi
    local secs=$((ms / 1000))
    if (( secs >= 3600 )); then
        printf "%dh%dm" $((secs/3600)) $(((secs%3600)/60))
    elif (( secs >= 60 )); then
        printf "%dm%ds" $((secs/60)) $((secs%60))
    else
        printf "%ds" $secs
    fi
}
DURATION_FMT=$(format_duration "$DURATION_MS")

# Lines changed
LINES_ADD=$(json '.cost.total_lines_added')
LINES_DEL=$(json '.cost.total_lines_removed')
LINES_ADD="${LINES_ADD:-0}"
LINES_DEL="${LINES_DEL:-0}"

# Git info (run in current directory)
GIT_INFO=""
if [[ -n "$CURRENT_DIR" ]] && cd "$CURRENT_DIR" 2>/dev/null; then
    if git rev-parse --git-dir >/dev/null 2>&1; then
        BRANCH=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        if [[ -n "$BRANCH" ]]; then
            # Check for uncommitted changes
            DIRTY=""
            if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
                DIRTY="*"
            fi
            # Check for untracked files
            if [[ -n $(git ls-files --others --exclude-standard 2>/dev/null | head -1) ]]; then
                DIRTY="${DIRTY}+"
            fi
            GIT_INFO="${BRANCH}${DIRTY}"
        fi
    fi
fi

# Cache efficiency (if cache is being used)
CACHE_INFO=""
if [[ -n "$CACHE_READ" && "$CACHE_READ" != "0" && "$CACHE_READ" != "null" ]]; then
    CACHE_TOTAL=$((${CACHE_READ:-0} + ${CACHE_CREATE:-0}))
    if (( CACHE_TOTAL > 0 )); then
        CACHE_HIT=$((CACHE_READ * 100 / CACHE_TOTAL))
        CACHE_INFO=" 💾${CACHE_HIT}%"
    fi
fi

# Context bar visualization (10 chars)
ctx_bar() {
    local pct="${1:-0}"
    local filled=$((pct / 10))
    local empty=$((10 - filled))
    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done
    echo "$bar"
}
CTX_BAR=$(ctx_bar "$CTX_PCT")

# Color codes based on context usage
if (( CTX_PCT >= 80 )); then
    CTX_COLOR="\033[31m"  # Red
elif (( CTX_PCT >= 60 )); then
    CTX_COLOR="\033[33m"  # Yellow
else
    CTX_COLOR="\033[32m"  # Green
fi
RESET="\033[0m"

# Build the status line
# Format: [Model] 📁 dir | 🌿 branch | ▰▰▰░░ 45% (12k/200k) | 💬 in:5k out:2k | 💰 $0.42 | ✏️ +10/-5 | ⏱ 5m

STATUS=""

# Model
[[ -n "$MODEL" ]] && STATUS+="[$MODEL]"

# Directory
[[ -n "$DIR_NAME" ]] && STATUS+=" 📁 $DIR_NAME"

# Git
[[ -n "$GIT_INFO" ]] && STATUS+=" │ 🌿 $GIT_INFO"

# Context with color and bar
STATUS+=" │ ${CTX_COLOR}${CTX_BAR}${RESET} ${CTX_PCT}%"
STATUS+=" (${CTX_USED_FMT}/${CTX_SIZE_FMT})"

# Cache hit rate if active
STATUS+="$CACHE_INFO"

# Session totals
STATUS+=" │ 💬 ↓${TOTAL_IN_FMT} ↑${TOTAL_OUT_FMT}"

# Cost
STATUS+=" │ 💰 $COST_FMT"

# Lines changed (only if there are changes)
if (( LINES_ADD > 0 || LINES_DEL > 0 )); then
    STATUS+=" │ ✏️  +${LINES_ADD}/-${LINES_DEL}"
fi

# Duration
STATUS+=" │ ⏱  $DURATION_FMT"

echo -e "$STATUS"
