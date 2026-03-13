import 'common.just'

# Package management subcommands: update, check, check-all
package action pkg='' version='':
  cd "{{ROOT}}" && ./scripts/package.sh {{action}} {{pkg}} {{version}}
