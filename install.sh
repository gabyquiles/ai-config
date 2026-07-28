#!/usr/bin/env bash
# Interactively install skills, agents, and MCP servers from this repo into
# Claude Code and/or Cursor via symlinks (skills/agents) or config merge (MCP).
# See CONTEXT.md for the terms used here (Element, Target, Category, ...).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parallel arrays instead of associative arrays: the default /bin/bash on
# macOS is 3.2, which has no `declare -A`.
TARGET_NAMES=()
TARGET_DIRS=()

detect_targets() {
  if [[ -d "$HOME/.claude" ]]; then
    TARGET_NAMES+=("claude")
    TARGET_DIRS+=("$HOME/.claude")
  else
    echo "Note: ~/.claude not found, skipping Claude Code."
  fi

  if [[ -d "$HOME/.cursor" ]]; then
    TARGET_NAMES+=("cursor")
    TARGET_DIRS+=("$HOME/.cursor")
  else
    echo "Note: ~/.cursor not found, skipping Cursor."
  fi

  if [[ ${#TARGET_NAMES[@]} -eq 0 ]]; then
    echo "Error: neither Claude Code (~/.claude) nor Cursor (~/.cursor) found on this machine. Nothing to install." >&2
    exit 1
  fi
}

# find_elements <root_relative_to_repo> <marker_filename>
# Prints one path per line, relative to <root_relative_to_repo>, for every
# leaf element directory (a directory containing <marker_filename>).
find_elements() {
  local root="$1" marker="$2"
  local full_root="$REPO_ROOT/$root"
  [[ -d "$full_root" ]] || return 0

  while IFS= read -r marker_file; do
    local dir="${marker_file%/*}"
    printf '%s\n' "${dir#"$full_root"/}"
  done < <(find "$full_root" -type f -name "$marker" | sort)
}

# prompt_selection <label> <element...>
# Populates the global SELECTED array with the chosen elements.
SELECTED=()
prompt_selection() {
  local label="$1"
  shift
  local elements=("$@")
  SELECTED=()

  if [[ ${#elements[@]} -eq 0 ]]; then
    echo ""
    echo "No $label found, skipping."
    return 0
  fi

  echo ""
  echo "== $label =="
  local i=1
  for e in "${elements[@]}"; do
    echo "  $i) $e"
    i=$((i + 1))
  done

  local choice
  read -r -p "Select $label: comma-separated numbers, 'a' for all, or blank to skip. > " choice
  choice="$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"

  if [[ -z "$choice" ]]; then
    return 0
  fi

  if [[ "$choice" == "a" || "$choice" == "all" ]]; then
    SELECTED=("${elements[@]}")
    return 0
  fi

  local nums=()
  local old_ifs="$IFS"
  IFS=','
  read -r -a nums <<< "$choice"
  IFS="$old_ifs"

  for n in "${nums[@]}"; do
    if [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= ${#elements[@]} )); then
      SELECTED+=("${elements[$((n - 1))]}")
    else
      echo "  Warning: ignoring invalid selection '$n'" >&2
    fi
  done
}

# install_symlink <type_root> <rel_path> <target_dir>
# type_root: "skills" or "agents". rel_path: element path relative to
# <type_root>/, preserving any category nesting.
install_symlink() {
  local type_root="$1" rel_path="$2" target_dir="$3"
  local src="$REPO_ROOT/$type_root/$rel_path"
  local dest="$target_dir/$type_root/$rel_path"

  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      echo "  [ok]     $type_root/$rel_path"
    else
      rm "$dest"
      ln -s "$src" "$dest"
      echo "  [relink] $type_root/$rel_path (was pointing elsewhere)"
    fi
  elif [[ -e "$dest" ]]; then
    echo "  [skip]   $type_root/$rel_path -> real file/dir at $dest, not touching" >&2
  else
    ln -s "$src" "$dest"
    echo "  [linked] $type_root/$rel_path"
  fi
}

# install_mcp <rel_path> <target_name> <target_dir>
install_mcp() {
  local rel_path="$1" target_name="$2" target_dir="$3"
  local name
  name="$(basename "$rel_path")"
  local mcp_file="$REPO_ROOT/mcp/$rel_path/mcp.json"

  if ! command -v jq >/dev/null 2>&1; then
    echo "  [error]  jq is required to install MCP servers. Install it with: brew install jq" >&2
    return 1
  fi

  local json
  json="$(cat "$mcp_file")"

  case "$target_name" in
    claude)
      if ! command -v claude >/dev/null 2>&1; then
        echo "  [error]  claude CLI not found on PATH, skipping mcp/$name for Claude Code" >&2
        return 1
      fi
      if claude mcp add-json "$name" "$json" --scope user >/dev/null 2>&1; then
        echo "  [linked] mcp/$name -> claude (user scope)"
      elif claude mcp get "$name" >/dev/null 2>&1; then
        echo "  [ok]     mcp/$name -> already present for claude"
      else
        echo "  [error]  failed to add mcp/$name for claude" >&2
        return 1
      fi
      ;;
    cursor)
      local cursor_mcp="$target_dir/mcp.json"
      [[ -f "$cursor_mcp" ]] || echo '{}' > "$cursor_mcp"
      local tmp
      tmp="$(mktemp)"
      jq --arg name "$name" --argjson def "$json" '.mcpServers[$name] = $def' "$cursor_mcp" > "$tmp"
      mv "$tmp" "$cursor_mcp"
      echo "  [linked] mcp/$name -> cursor ($cursor_mcp)"
      ;;
  esac
}

main() {
  detect_targets

  echo ""
  echo "Targets detected: ${TARGET_NAMES[*]}"

  local skills=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && skills+=("$line")
  done < <(find_elements "skills" "SKILL.md")
  prompt_selection "skills" "${skills[@]+"${skills[@]}"}"
  local selected_skills=("${SELECTED[@]+"${SELECTED[@]}"}")

  local agents=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && agents+=("$line")
  done < <(find_elements "agents" "AGENT.md")
  prompt_selection "agents" "${agents[@]+"${agents[@]}"}"
  local selected_agents=("${SELECTED[@]+"${SELECTED[@]}"}")

  local mcps=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && mcps+=("$line")
  done < <(find_elements "mcp" "mcp.json")
  prompt_selection "MCP servers" "${mcps[@]+"${mcps[@]}"}"
  local selected_mcps=("${SELECTED[@]+"${SELECTED[@]}"}")

  local t_idx
  for t_idx in "${!TARGET_NAMES[@]}"; do
    local target_name="${TARGET_NAMES[$t_idx]}"
    local target_dir="${TARGET_DIRS[$t_idx]}"

    echo ""
    echo "--- $target_name ---"

    if [[ ${#selected_skills[@]} -gt 0 ]]; then
      echo "Skills:"
      local rel
      for rel in "${selected_skills[@]}"; do
        install_symlink "skills" "$rel" "$target_dir"
      done
    fi

    if [[ ${#selected_agents[@]} -gt 0 ]]; then
      echo "Agents:"
      for rel in "${selected_agents[@]}"; do
        install_symlink "agents" "$rel" "$target_dir"
      done
    fi

    if [[ ${#selected_mcps[@]} -gt 0 ]]; then
      echo "MCP servers:"
      for rel in "${selected_mcps[@]}"; do
        install_mcp "$rel" "$target_name" "$target_dir"
      done
    fi
  done

  echo ""
  echo "Done."
}

main "$@"
