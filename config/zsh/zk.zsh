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
