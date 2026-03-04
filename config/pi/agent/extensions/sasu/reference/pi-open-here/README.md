# pi-open-here

Open current directory (or a path) in an external editor from [pi](https://github.com/badlogic/pi-mono).

This extension adds one command:

| Command | Description |
|---------|-------------|
| `/open-here [path]` | Open current directory (default) or a given path in an editor app |

## Install

From npm:

```bash
pi install npm:pi-open-here
```

From GitHub:

```bash
pi install https://github.com/omaclaren/pi-open-here
```

Try without installing:

```bash
pi -e https://github.com/omaclaren/pi-open-here
```

## Usage

```text
/open-here
/open-here .
/open-here ~/Git-Working/pi-studio
/open-here "docs/spec with spaces.md"
/open-here --help
```

## Launcher resolution order

The extension tries launchers in this order:

1. `PI_OPEN_EDITOR_CMD`
2. `VISUAL`
3. `EDITOR`
4. Built-in CLI launchers (`code`, `cursor`, `windsurf`, `zed`, `subl`, `idea`)
5. macOS app launchers via `open -a ...` (macOS only)

The first launcher that exists and succeeds is used.

## Notes

- Path arguments support quotes and `~` expansion.
- If a target path does not exist yet, the extension warns but still attempts to launch.
- Command lookup uses `which` on Unix/macOS and `where` on Windows.
- `/code` is intentionally **not** registered as an alias.

## License

MIT
