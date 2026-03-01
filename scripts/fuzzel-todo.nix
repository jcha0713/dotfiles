{ pkgs }:

pkgs.writeShellScriptBin "todo" ''
  set -e

  # todo - Quick todo management via fuzzel and Noctalia IPC
  # Usage: todo [add|quick|menu]

  show_help() {
    echo "Usage: todo [command]"
    echo ""
    echo "Commands:"
    echo "  add   - Add a new todo (default)"
    echo "  menu  - Show todo menu"
    echo ""
    echo "Examples:"
    echo "  todo           # Quick add a todo"
    echo "  todo add       # Same as above"
  }

  # Quick add a todo
  cmd_add() {
    local text
    text=$(echo "" | ${pkgs.fuzzel}/bin/fuzzel --dmenu \
      --prompt "+ " \
      --placeholder "What needs to be done?" \
      --width 50)
    
    if [ -z "$text" ]; then
      exit 0
    fi

    # Send to Noctalia todo plugin via IPC
    if command -v noctalia-shell &> /dev/null; then
      noctalia-shell ipc call plugin:todo addTodoDefault "$text"
      ${pkgs.libnotify}/bin/notify-send "Todo Added" "$text" --icon=checkbox-checked
    else
      echo "Error: noctalia-shell not found"
      exit 1
    fi
  }

  # Show menu with options
  cmd_menu() {
    local choice
    choice=$(echo -e "➕ Add new todo\n📋 Open todo panel" | \
      ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "Todo: " --index)
    
    case "$choice" in
      0) cmd_add ;;
      1) 
        # Open the todo panel by clicking the bar widget
        # Note: There's no direct IPC to open panel, so we notify user
        ${pkgs.libnotify}/bin/notify-send "Todo" "Click the todo widget in your bar to open the panel" --icon=info
        ;;
      *) exit 0 ;;
    esac
  }

  # Main
  case "''${1:-add}" in
    -h|--help|help)
      show_help
      ;;
    add|quick)
      cmd_add
      ;;
    menu)
      cmd_menu
      ;;
    *)
      echo "Unknown command: $1"
      show_help
      exit 1
      ;;
  esac
''
