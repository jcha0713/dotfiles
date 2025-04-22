# zk
export ZK_NOTEBOOK_DIR="$HOME/note"
alias note="yazi $ZK_NOTEBOOK_DIR"

function capture() {
  zk new --title "$*" "$ZK_NOTEBOOK_DIR/captures"
}

function get_project_name() {
  local project_name

  if [ -n "$1" ]; then
    # Use provided argument if it exists
    project_name="$1"
  elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Get the git repository name if we're in a git directory
    project_name=$(basename -s .git $(git config --get remote.origin.url) 2>/dev/null)

    if [ -z "$project_name" ]; then
      # Fallback to local repo name if no remote exists
      project_name=$(basename $(git rev-parse --show-toplevel))
    fi
  else
    echo "Error: Please provide a project name or run from within a git repository"
    return 1
  fi

  echo "$project_name"
  return 0
}

function devlog() {
  project_name=$(get_project_name "$1")

  if [ $? -ne 0 ]; then
    return 1
  fi

  # Create full path
  local project_path="$ZK_NOTEBOOK_DIR/project/dev/$project_name"
  local log_path="$project_path/log"

  # Create directories if they don't exist
  if [ ! -d "$project_path" ]; then
    echo "Creating project directory: $project_path"
    mkdir -p "$log_path"
  elif [ ! -d "$log_path" ]; then
    echo "Creating log directory: $log_path"
    mkdir -p "$log_path"
  fi

  zk new --extra project=$project_name --no-input "$log_path"
}

function project() {
  local project_type="dev"
  local project_arg=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -a | --active)
      project_type="active"
      shift
      ;;
    *)
      # Save non-flag arguments
      project_arg="$1"
      shift
      ;;
    esac
  done

  project_name=$(get_project_name "$project_arg")

  echo $project_name

  if [ $? -ne 0 ]; then
    return 1
  fi

  local project_path="$ZK_NOTEBOOK_DIR/project/$project_type/$project_name"
  local project_file="$project_path/$project_name.md"

  if [ ! -d "$project_path" ]; then
    echo "Creating project directory: $project_path"
    mkdir -p "$project_path"
  fi

  # zk
  zk new --title=$project_name --extra project=$project_name --no-input "$project_path"
}

function homework() {
  if ! which fzf >/dev/null 2>&1; then
    echo "fzf is not installed, please install it first to do your homework"
    return 1
  fi

  local captures_dir="${1:-$ZK_NOTEBOOK_DIR/captures}"
  local root_dir="$ZK_NOTEBOOK_DIR"

  if [[ -z "$(ls -A "$captures_dir" 2>/dev/null)" ]]; then
    echo "No more homework left. Good job!"
    return 0
  fi

  local tmp_exit_file=$(mktemp)
  local exit_binds=(
    --bind="ctrl-q:execute(echo 1 > $tmp_exit_file)+cancel"
    --bind="ctrl-c:execute(echo 1 > $tmp_exit_file)+cancel"
    --bind="esc:execute(echo 1 > $tmp_exit_file)+cancel"
  )

  while true; do
    local files_count=$(zk list --quiet --format '{{path}}' "$captures_dir" | wc -l)

    if [[ $files_count -eq 0 ]]; then
      echo "Homework is done. Well done!"
      break
    fi

    echo "You have $files_count note(s) left to process."

    local file_paths=$(
      zk list --quiet --format '{{abs-path}}' "$captures_dir" |
        fzf --multi --preview "bat --color=always {}" \
          "${exit_binds[@]}"
    )

    local files=("${(f)file_paths}")

    if [[ -s "$tmp_exit_file" ]]; then
      rm "$tmp_exit_file"
      echo "Do your homework more frequently."
      return 0
    fi

    local dest_dir=$(
      find "$root_dir" -type d -not -path "*/\.*" |
        grep -v "$captures_dir" |
        fzf --height 90% --layout=reverse --prompt="Move to: " \
          --header="Enter: select, CTRL-E: create new directory" \
          --bind="ctrl-e:print-query" \
          "${exit_binds[@]}"
    )

    if [[ -s "$tmp_exit_file" ]]; then
      rm "$tmp_exit_file"
      echo "Do your homework more frequently."
      return 0
    fi

    if [[ -n $dest_dir ]]; then
      if [[ ! -d "$dest_dir" ]]; then
        echo "Creating new directory: $dest_dir"
        mkdir -p "$dest_dir"
      fi

      for file in "${files[@]}"; do
        mv $file "$dest_dir/"
        echo "✓ Moved $(basename "$file") to $dest_dir/$(basename "$file")"
      done

    fi
  done
}
