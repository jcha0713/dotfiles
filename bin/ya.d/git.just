import 'common.just'

# Publish config/neuvim subtree to the standalone neuvim repository
neuvim-push remote='neuvim' target='main' prefix='config/neuvim':
  #!/usr/bin/env bash
  set -euo pipefail
  cd "{{ROOT}}"

  split_commit=$(git subtree split --prefix="{{prefix}}")
  echo "Publishing {{prefix}} to ${split_commit} -> {{remote}}:{{target}}"
  git push "{{remote}}" "${split_commit}:{{target}}" --force-with-lease

# Short alias for neuvim-push
np: neuvim-push
