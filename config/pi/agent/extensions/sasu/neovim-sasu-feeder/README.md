# neovim-sasu-feeder

Minimal Neovim plugin that emits SASU memory save events on `BufWritePost`.

It is designed to work with `pi-nvim` (Pi terminal inside Neovim) and sends:

```text
/sasu-memory-ingest-nvim-save {"file":"/absolute/path/to/file.ts","ts":"..."}
```

SASU then normalizes the path to project-relative and ingests `code.files.changed` with:

- `source: "nvim"`
- `kind: "code.files.changed"`
- `payload.origin: "nvim.buf_write"`
- `payload.reason: "save"`

## Requirements

- `pi-nvim` plugin loaded (for terminal transport)
- Pi terminal open (`require("pi-nvim").open()`)
- SASU extension loaded in Pi session

## lazy.nvim setup example

```lua
{
  dir = "~/dotfiles/config/pi/agent/extensions/sasu/neovim-sasu-feeder",
  dependencies = {
    -- Wherever your pi-nvim plugin lives
    { dir = "~/dotfiles/config/pi/agent/extensions/sasu/reference/pi-extensions/extensions/neovim" },
  },
  config = function()
    require("sasu-feeder").setup({
      command = "/sasu-memory-ingest-nvim-save",
      throttle_ms = 500,
    })
  end,
}
```

## Commands

- `:SasuFeederStatus` — show feeder status
- `:SasuFeederEnable` — enable emit
- `:SasuFeederDisable` — disable emit
- `:SasuFeederEmitCurrent` — manually emit for current file

## Manual check

1. Open Pi terminal in Neovim (`require("pi-nvim").open()`).
2. Save a file.
3. In Pi, run:

```text
/sasu-memory-tail 10 --kind code.files.changed
```

You should see a latest `nvim` save event for that file.
