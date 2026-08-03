#!/usr/bin/env bash
# Claude Code status line.
# Order: vim mode | cwd (~-compressed) | branch | diff stats | model name |
#        state badges | context usage | session duration | session lines
#        edited | rate limits
# Git segments are omitted silently when not inside a work tree; every other
# segment degrades gracefully (omitted) when its field is absent/null.
# All git commands are scoped to the session's cwd via `git -C`, never the
# script's own cwd, and use cheap local commands only (no fetch).

input=$(cat)

# --- colors (tasteful on a dark/One Dark background) ---
RESET=$'\033[0m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
CYAN=$'\033[36m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
GREEN=$'\033[32m'
RED=$'\033[31m'
GRAY=$'\033[90m'
SEP="${GRAY} | ${RESET}"

# --- nerd font icons (stable powerline + Font Awesome PUA ranges only, as
# raw UTF-8 byte escapes; no 5-hex nf-md-* codepoints) ---
ICON_VIM=$'\xee\x98\xab'            # U+E62B nf-custom-vim
ICON_FOLDER=$'\xef\x81\xbc'         # U+F07C nf-fa-folder_open
ICON_BRANCH=$'\xee\x82\xa0'         # U+E0A0 nf-pl-branch (powerline)
ICON_PENCIL=$'\xef\x81\x80'         # U+F040 nf-fa-pencil
ICON_MICROCHIP=$'\xef\x8b\x9b'      # U+F2DB nf-fa-microchip
ICON_BOLT=$'\xef\x83\xa7'           # U+F0E7 nf-fa-bolt
ICON_LIGHTBULB=$'\xef\x83\xab'      # U+F0EB nf-fa-lightbulb_o
ICON_ROCKET=$'\xef\x84\xb5'         # U+F135 nf-fa-rocket
ICON_TACHOMETER=$'\xef\x83\xa4'     # U+F0E4 nf-fa-tachometer
ICON_CLOCK=$'\xef\x80\x97'          # U+F017 nf-fa-clock_o
ICON_PENCIL_SQUARE=$'\xef\x81\x84'  # U+F044 nf-fa-pencil_square
ICON_HOURGLASS=$'\xef\x89\x94'      # U+F254 nf-fa-hourglass

segments=()

# Single jq pass pulls every JSON-derived field at once. Each expression is
# printed on its own line and read back with mapfile (one element per line)
# rather than @tsv/read: bash's `read` treats tab as IFS whitespace and
# collapses runs of consecutive delimiters, silently dropping empty optional
# fields and shifting every later field left by one. mapfile splits strictly
# on newlines with no such collapsing, so positions stay stable regardless of
# which optional keys are absent (an absent field just becomes an empty
# line/array element).
mapfile -t sl_fields < <(echo "$input" | jq -r '
  (.model.display_name // ""),
  (.context_window.used_percentage // ""),
  (.workspace.current_dir // .cwd // ""),
  (.cost.total_duration_ms // ""),
  (.cost.total_lines_added // ""),
  (.cost.total_lines_removed // ""),
  (.effort.level // ""),
  (.thinking.enabled // false),
  (.fast_mode // false),
  (.vim.mode // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.seven_day.used_percentage // "")
')
model_name="${sl_fields[0]}"
used_pct="${sl_fields[1]}"
raw_cwd="${sl_fields[2]}"
duration_ms="${sl_fields[3]}"
lines_added="${sl_fields[4]}"
lines_removed="${sl_fields[5]}"
effort_level="${sl_fields[6]}"
thinking_enabled="${sl_fields[7]}"
fast_mode="${sl_fields[8]}"
vim_mode="${sl_fields[9]}"
five_hour="${sl_fields[10]}"
seven_day="${sl_fields[11]}"

# 1. vim mode — lualine/LazyVim-style inverted block: bold dark foreground on
# a mode-colored truecolor background, padded as " MODE ".
if [ -n "$vim_mode" ]; then
  case "$vim_mode" in
    NORMAL) vim_bg=$'\033[48;2;142;189;107m' ;;   # #8ebd6b green
    INSERT) vim_bg=$'\033[48;2;79;166;237m' ;;     # #4fa6ed blue
    VISUAL|"VISUAL LINE") vim_bg=$'\033[48;2;191;104;217m' ;;  # #bf68d9 purple
    COMMAND) vim_bg=$'\033[48;2;204;144;87m' ;;    # #cc9057 orange
    *) vim_bg=$'\033[48;2;83;89;101m' ;;           # #535965 grey (unknown mode)
  esac
  vim_fg=$'\033[38;2;14;16;19m'                    # #0e1013 dark foreground
  segments+=("${vim_bg}${vim_fg}${BOLD} ${ICON_VIM} ${vim_mode} ${RESET}")
fi

# 2. cwd, tilde-compressed
if [ -n "$raw_cwd" ]; then
  case "$raw_cwd" in
    "$HOME"/*) short_cwd="~${raw_cwd#"$HOME"}" ;;
    "$HOME") short_cwd="~" ;;
    *) short_cwd="$raw_cwd" ;;
  esac
  segments+=("${BLUE}${ICON_FOLDER} ${short_cwd}${RESET}")
fi

# 3-4. git segments (branch, diff stats) — only if inside a work tree
if [ -n "$raw_cwd" ] && git -C "$raw_cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$raw_cwd" branch --show-current 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$raw_cwd" rev-parse --short HEAD 2>/dev/null)
  fi
  [ -n "$branch" ] && segments+=("${GREEN}${ICON_BRANCH} ${branch}${RESET}")

  parse_stat() {
    # extracts "N insertions" / "N deletions" counts from a --shortstat line
    local stat="$1" kind="$2"
    echo "$stat" | grep -oE "[0-9]+ ${kind}" | grep -oE '[0-9]+'
  }

  unstaged=$(git -C "$raw_cwd" diff --shortstat 2>/dev/null)
  staged=$(git -C "$raw_cwd" diff --cached --shortstat 2>/dev/null)

  ins_unstaged=$(parse_stat "$unstaged" insertion); ins_unstaged=${ins_unstaged:-0}
  ins_staged=$(parse_stat "$staged" insertion); ins_staged=${ins_staged:-0}
  del_unstaged=$(parse_stat "$unstaged" deletion); del_unstaged=${del_unstaged:-0}
  del_staged=$(parse_stat "$staged" deletion); del_staged=${del_staged:-0}

  ins=$(( ins_unstaged + ins_staged ))
  del=$(( del_unstaged + del_staged ))

  dirty_count=$(git -C "$raw_cwd" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  dirty_count=${dirty_count:-0}

  diff_seg=""
  if [ "$ins" -gt 0 ] || [ "$del" -gt 0 ]; then
    diff_seg="${GREEN}+${ins}${RESET} ${RED}-${del}${RESET}"
  fi
  if [ "$dirty_count" -gt 0 ]; then
    if [ -n "$diff_seg" ]; then
      diff_seg="${diff_seg} ${DIM}${ICON_PENCIL} ${dirty_count}${RESET}"
    else
      diff_seg="${DIM}${ICON_PENCIL} ${dirty_count}${RESET}"
    fi
  fi
  [ -n "$diff_seg" ] && segments+=("$diff_seg")
fi

# 5. model display name
[ -n "$model_name" ] && segments+=("${CYAN}${ICON_MICROCHIP} ${model_name}${RESET}")

# 6. model state badges — only shown when active
badges=()
[ -n "$effort_level" ] && badges+=("${ICON_BOLT} ${effort_level}")
[ "$thinking_enabled" = "true" ] && badges+=("${ICON_LIGHTBULB}")
[ "$fast_mode" = "true" ] && badges+=("${ICON_ROCKET}")
if [ ${#badges[@]} -gt 0 ]; then
  badge_str="${badges[0]}"
  for ((i = 1; i < ${#badges[@]}; i++)); do
    badge_str="${badge_str} ${badges[i]}"
  done
  segments+=("${CYAN}${badge_str}${RESET}")
fi

# 7. context usage
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct" 2>/dev/null)
  [ -n "$pct_int" ] && segments+=("${YELLOW}${ICON_TACHOMETER} ${pct_int}%${RESET}")
fi

# 8. session duration (human-friendly, e.g. "1h 23m" / "42m")
if [ -n "$duration_ms" ]; then
  duration_int=${duration_ms%.*}
  if [ -n "$duration_int" ]; then
    total_sec=$(( duration_int / 1000 ))
    h=$(( total_sec / 3600 ))
    m=$(( (total_sec % 3600) / 60 ))
    if [ "$h" -gt 0 ]; then
      duration_str=$(printf '%dh %dm' "$h" "$m")
    else
      duration_str=$(printf '%dm' "$m")
    fi
    segments+=("${DIM}${ICON_CLOCK} ${duration_str}${RESET}")
  fi
fi

# 9. session lines edited — distinct (dim) styling from the git diff stats
if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
  segments+=("${DIM}${ICON_PENCIL_SQUARE} +${lines_added:-0}/-${lines_removed:-0}${RESET}")
fi

# 10. rate limits — colored by threshold (<60 green, 60-85 yellow, >85 red)
color_for_pct() {
  local pct_int
  pct_int=$(printf '%.0f' "$1" 2>/dev/null) || return 1
  if [ "$pct_int" -lt 60 ]; then
    echo "$GREEN"
  elif [ "$pct_int" -le 85 ]; then
    echo "$YELLOW"
  else
    echo "$RED"
  fi
}

rate_parts=()
if [ -n "$five_hour" ]; then
  five_int=$(printf '%.0f' "$five_hour" 2>/dev/null)
  five_color=$(color_for_pct "$five_hour")
  [ -n "$five_int" ] && rate_parts+=("${five_color}5h:${five_int}%${RESET}")
fi
if [ -n "$seven_day" ]; then
  seven_int=$(printf '%.0f' "$seven_day" 2>/dev/null)
  seven_color=$(color_for_pct "$seven_day")
  [ -n "$seven_int" ] && rate_parts+=("${seven_color}7d:${seven_int}%${RESET}")
fi
if [ ${#rate_parts[@]} -gt 0 ]; then
  rate_str="${rate_parts[0]}"
  [ ${#rate_parts[@]} -gt 1 ] && rate_str="${rate_str} ${rate_parts[1]}"
  segments+=("${GRAY}${ICON_HOURGLASS}${RESET} ${rate_str}")
fi

# join segments with the separator
out=""
for seg in "${segments[@]}"; do
  if [ -z "$out" ]; then
    out="$seg"
  else
    out="${out}${SEP}${seg}"
  fi
done

printf '%s' "$out"
