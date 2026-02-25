# Agentic Pair Programming Environment Analysis

## Project: ailou/pi-extensions (Neovim Extension)

### Overview
This is a bidirectional integration between Pi (agentic coding harness) and Neovim. It enables:
1. Pi to query Neovim for editor state
2. Neovim to host Pi in an embedded terminal
3. Automatic context injection and file synchronization

---

## Architecture Analysis

### 🔌 Connection Mechanism

**How it works:**
- **Lockfile-based discovery**: Neovim creates a JSON lockfile at `~/.local/share/nvim/pi-nvim/{cwd_hash}-{pid}.json` containing socket path, cwd, and pid
- **Unix socket RPC**: Neovim starts an RPC server via `vim.fn.serverstart(socket_path)`
- **Remote expression queries**: Pi uses `nvim --server {socket} --remote-expr {lua_expr}` to execute Lua code and get JSON responses

```
Pi Extension (TypeScript)          Neovim Plugin (Lua)
+---------------------+            +---------------------+
| nvim_context tool   |---RPC---->| pi-nvim.query()     |
| hooks (lifecycle)   |  (nvim    | actions/            |
| nvim.ts (discover)  |  --remote | rpc/server          |
+---------------------+   -expr)  +---------------------+
                            |
                            v
                    Unix socket + lockfile
                    ~/.local/share/nvim/pi-nvim/
```

**Strengths:**
- ✅ Simple, no additional dependencies beyond Neovim
- ✅ Lockfile cleanup on stale PIDs (process kill check)
- ✅ Supports multiple Neovim instances with interactive selection
- ✅ Cross-platform socket paths (respects XDG, macOS variants)

**Weaknesses:**
- ⚠️ Spawning `nvim --remote-expr` subprocess for every query has overhead
- ⚠️ No persistent connection (could use msgpack-rpc over socket instead)
- ⚠️ Lockfile approach may fail if Neovim crashes without cleanup

---

### 🔄 Bidirectional Integration Components

#### 1. Pi → Neovim: Context Queries (Tool-based)

**File**: `tools/nvim-context.ts`

```typescript
pi.registerTool({
  name: "nvim_context",
  parameters: Type.Object({
    action: StringEnum(["context", "splits", "diagnostics", "current_function"])
  }),
  execute: async (...) => {
    const result = await queryNvim(exec, socket, params.action);
    return { content: [...], details: { action, result, cwd } };
  }
});
```

**Actions supported:**
| Action | Purpose |
|--------|---------|
| `context` | Current file, cursor position, selection, filetype |
| `splits` | All visible splits with metadata |
| `diagnostics` | LSP diagnostics for current buffer |
| `current_function` | Treesitter info about function at cursor |

**Strengths:**
- ✅ Rich context: filetype, cursor, selection, visible ranges, modified status
- ✅ Structured tool result with both text content and typed details
- ✅ Graceful degradation (continues without context if query fails)
- ✅ Caching: stores socket in state to avoid rediscovery

**Weaknesses:**
- ⚠️ Tool calls add latency to agent response
- ⚠️ No automatic context refresh during an agent turn

---

#### 2. Neovim → Pi: Embedded Terminal

**File**: `lua/pi-nvim/cli/terminal.lua`

```lua
-- Creates a terminal buffer running Pi CLI
terminal.job = vim.fn.jobstart(cmd, {
  term = true,
  clear_env = true,
  env = { NVIM = vim.v.servername, ... },
})

-- Window options: split (left/right/top/bottom/float)
local win = vim.api.nvim_open_win(buf, true, {
  split = 'right',
  width = cfg.win.width,
})
```

**Features:**
- Auto-start Pi terminal with configurable layout
- Keymaps for close, exit terminal mode, suspend, context picker
- Focus source window on terminal exit option
- Resume terminal insert mode after suspend

**Strengths:**
- ✅ Native Neovim terminal integration (no external window)
- ✅ Flexible layouts with auto-detection based on screen size
- ✅ Passes `NVIM` env var so Pi can connect back to this instance
- ✅ Clean buffer/window lifecycle management

**Weaknesses:**
- ⚠️ Terminal UI is limited compared to full TUI
- ⚠️ No built-in file picker integration in the terminal itself

---

#### 3. Automatic Context Injection (Hooks)

**File**: `hooks/nvim-context.ts`

```typescript
pi.on("before_agent_start", async (...) => {
  const splits = await queryNvim(pi.exec, state.socket, "splits");
  return {
    systemPrompt: formatSplitsContext(splits, ctx.cwd)
  };
});
```

**Lifecycle hooks:**
| Hook | Action |
|------|--------|
| `session_start` | Auto-discover and connect to Neovim instance |
| `before_agent_start` | Inject editor state (splits) into system prompt |
| `tool_result` | Track modified files, reload in Neovim |
| `turn_end` | Query LSP errors for modified files, send as follow-up |

**Context format example:**
```
Current editor state:
- src/main.ts [focused] (typescript) visible lines 1-50, cursor at line 25:10
- src/utils.ts [modified] (typescript) visible lines 1-30
```

**Strengths:**
- ✅ Zero-config: auto-discovers Neovim on session start
- ✅ Multiple instance support with interactive picker
- ✅ Tracks modified files across agent turns for LSP diagnostics
- ✅ Follow-up messages for diagnostics (doesn't block agent)

**Weaknesses:**
- ⚠️ System prompt injection on every turn can be verbose
- ⚠️ No deduplication if context hasn't changed

---

#### 4. File Synchronization

**File**: `hooks/nvim-context.ts` (tool_result handler)

```typescript
pi.on("tool_result", async (event, ctx) => {
  if (event.toolName === "write" || event.toolName === "edit") {
    state.modifiedFilesThisTurn.add(absPath);
    
    // Notify Neovim to reload the file
    await queryNvim(pi.exec, state.socket, {
      type: "reload",
      files: [absPath]
    });
  }
});
```

**Lua reload action:** `lua/pi-nvim/actions/reload.lua`

```lua
for _, file in ipairs(action.files) do
  local bufnr = vim.fn.bufnr(file)
  if bufnr ~= -1 then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd.checktime()  -- Trigger autoread
    end)
  end
end
```

**Strengths:**
- ✅ Immediate file reload in Neovim after Pi writes/edits
- ✅ Uses `checktime()` to respect 'autoread' settings
- ✅ Only reloads if buffer is loaded

**Weaknesses:**
- ⚠️ Requires 'autoread' to be set for automatic reload
- ⚠️ Could use `nvim_buf_set_lines` for smoother updates without disk read

---

#### 5. LSP Diagnostics Integration

**File**: `hooks/nvim-context.ts` (turn_end handler)

```typescript
pi.on("turn_end", async (...) => {
  const diagnostics = await queryNvim(pi.exec, state.socket, {
    type: "diagnostics_for_files",
    files: Array.from(state.modifiedFilesThisTurn)
  });
  
  pi.sendMessage({
    customType: "nvim-diagnostics",
    content: formatDiagnosticsMessage(diagnostics, ctx.cwd),
    display: true
  }, {
    deliverAs: "followUp",
    triggerTurn: true  // Triggers new agent turn
  });
});
```

**Custom message renderer:** Styled like a failed tool call with `toolErrorBg` background

**Strengths:**
- ✅ Only checks files modified in current turn (not entire codebase)
- ✅ Custom TUI renderer for diagnostics with error/warning counts
- ✅ Follow-up message triggers agent to fix errors automatically
- ✅ Expandable/collapsible error details

**Weaknesses:**
- ⚠️ Only errors, not warnings/hints
- ⚠️ Could be noisy if many files modified

---

## Key Design Patterns

### 1. **Action Dispatch Pattern**

```lua
-- lua/pi-nvim/actions/init.lua
function M.dispatch(action)
  if type(action) == "string" then
    return require("pi-nvim.actions." .. action).execute()
  else
    return require("pi-nvim.actions." .. action.type).execute(action)
  end
end
```

Clean separation of concerns with action modules for each query type.

### 2. **Shared State Management**

```typescript
// Shared between hooks and tools
interface NvimConnectionState {
  socket: string | null;
  lockfile: string | null;
  modifiedFilesThisTurn: Set<string>;
}
```

State shared across hooks and tools avoids redundant discovery.

### 3. **Graceful Degradation**

Every RPC call wrapped in try/catch, continues without context on failure:
```typescript
try {
  const splits = await queryNvim(...);
  return { systemPrompt: formatSplitsContext(splits) };
} catch {
  return;  // Continue without context
}
```

---

## What to Adopt

| Component | Recommendation |
|-----------|---------------|
| **Lockfile discovery** | ✅ Excellent pattern - simple, reliable, cross-platform |
| **Hooks architecture** | ✅ Lifecycle hooks provide clean integration points |
| **Automatic context injection** | ✅ Essential for agent awareness |
| **File reload on write** | ✅ Critical for tight feedback loop |
| **LSP diagnostics follow-up** | ✅ Auto-fix pattern is powerful |
| **Action dispatch pattern** | ✅ Clean, extensible architecture |
| **Multiple instance selection** | ✅ Real-world consideration |
| **Custom message renderers** | ✅ Improves TUI experience |

## What to Avoid/Improve

| Component | Issue | Better Approach |
|-----------|-------|----------------|
| **Subprocess RPC** | Overhead of spawning nvim for each query | Persistent msgpack-rpc connection |
| **System prompt injection** | Can be verbose | Use context files or compressed format |
| **Autoread dependency** | File reload requires 'autoread' | Direct buffer manipulation via API |
| **Tool-based context** | Adds latency | Background sync + on-demand refresh |
| **Lockfile staleness** | Crash leaves lockfile | Heartbeat/ttl mechanism |
| **Single error severity** | Only errors, not warnings | Configurable severity levels |

---

## Gap Analysis: Workspace-Level Change Awareness

The pi-neovim extension tracks **files Pi modified** and queries **Neovim loaded buffers**. It does NOT:
- Track external changes (git operations, other editors, build tools)
- Provide diagnostics for unloaded files
- Give the agent a complete picture of codebase delta

### Approaches for Full Codebase Change Tracking

#### 1. Git-Based Delta Tracking ⭐ Recommended

```typescript
// Track changes since last agent turn using git
interface CodebaseDelta {
  modified: string[];   // Files modified since last turn
  created: string[];    // New files
  deleted: string[];    // Removed files
  diffs: Map<string, string>;  // Unified diff per file
}

async function getDeltaSinceLastTurn(cwd: string): Promise<CodebaseDelta> {
  // Option A: Compare against staged/stash
  const lastKnown = getLastTurnRef();  // Store commit hash or create temp ref
  
  // Option B: Use git stash/create temp commits
  // 1. Before agent turn: git stash push -m "pi-turn-${timestamp}"
  // 2. After agent turn: git diff stash@{0}..HEAD
  
  const modified = await exec("git", ["diff", "--name-only", lastKnown]);
  const diffs = await exec("git", ["diff", "-U3", lastKnown]);  // Unified diff with context
  
  return { modified, created, deleted, diffs };
}

// Inject into system prompt
pi.on("before_agent_start", async () => {
  const delta = await getDeltaSinceLastTurn(ctx.cwd);
  return {
    systemPrompt: formatDeltaContext(delta)
  };
});
```

**Pros:**
- ✅ Captures ALL changes (Pi, user, external tools, git operations)
- ✅ Provides semantic diffs (not just file lists)
- ✅ Works across the entire codebase, not just open buffers
- ✅ Git is already present in most codebases

**Cons:**
- ⚠️ Requires git repository
- ⚠️ Need to manage "last turn" reference point
- ⚠️ Large refactors could produce huge diffs

**Implementation strategy:**
```
Turn N: Agent generates changes
   ↓
Store "checkpoint" (git stash or temp commit with tag)
   ↓
Turn N+1: User makes external changes
   ↓
Agent turn starts: git diff checkpoint..HEAD
   ↓
Feed diff to agent as context
```

---

#### 2. Filesystem Watcher Approach

```typescript
import { watch } from "fs";

class WorkspaceWatcher {
  private changes = new Set<string>();
  private watchers = new Map<string, ReturnType<typeof watch>>();
  
  start(cwd: string) {
    const watcher = watch(cwd, { recursive: true }, (event, filename) => {
      if (this.shouldTrack(filename)) {
        this.changes.add(path.resolve(cwd, filename));
      }
    });
    this.watchers.set(cwd, watcher);
  }
  
  getAndClearChanges(): string[] {
    const result = Array.from(this.changes);
    this.changes.clear();
    return result;
  }
}

pi.on("before_agent_start", async () => {
  const changes = watcher.getAndClearChanges();
  const diffs = await Promise.all(
    changes.map(async (file) => ({
      file,
      diff: await computeDiffFromSnapshot(file)  // Need snapshot storage
    }))
  );
  return { systemPrompt: formatChanges(diffs) };
});
```

**Pros:**
- ✅ Works without git
- ✅ Real-time tracking
- ✅ Captures external editor changes

**Cons:**
- ⚠️ Platform-specific (recursive watch not supported on Linux)
- ⚠️ Need to store file snapshots to compute diffs
- ⚠️ Noise from build artifacts, node_modules, etc.

---

#### 3. Hybrid: Git + LSP Workspace Diagnostics

```typescript
pi.on("turn_end", async () => {
  // 1. Get all modified files (git)
  const gitChanges = await getGitDelta();
  
  // 2. Get workspace diagnostics from LSP (if server supports it)
  const workspaceDiagnostics = await queryLspWorkspaceDiagnostics();
  
  // 3. Cross-reference: which changed files have errors?
  const relevantErrors = workspaceDiagnostics.filter(
    d => gitChanges.modified.includes(d.file)
  );
  
  // 4. Also check if changes introduced errors in OTHER files
  // (e.g., changed interface broke consumers)
  const affectedFiles = workspaceDiagnostics.filter(
    d => !gitChanges.modified.includes(d.file) && d.severity === "error"
  );
  
  if (affectedFiles.length > 0) {
    pi.sendMessage({
      content: `Changes may have broken ${affectedFiles.length} other files`,
      details: { affectedFiles, gitChanges }
    }, { deliverAs: "followUp", triggerTurn: true });
  }
});
```

**Pros:**
- ✅ Correlates changes with impact
- ✅ Finds breaking changes across the codebase
- ✅ LSP already knows the dependency graph

**Cons:**
- ⚠️ Not all LSP servers support workspace diagnostics
- ⚠️ More complex to implement

---

#### 4. User-Driven Context Expansion

Instead of automatic tracking, let the user explicitly include context:

```typescript
// Tool-based approach
pi.registerTool({
  name: "get_codebase_changes",
  description: "Get all changes made to the codebase since the last turn",
  parameters: Type.Object({
    includeDiffs: Type.Boolean({ default: true }),
    maxFiles: Type.Number({ default: 20 })
  }),
  execute: async (params) => {
    const delta = await getGitDelta();
    const limited = delta.slice(0, params.maxFiles);
    const content = await Promise.all(
      limited.map(async (f) => ({
        file: f,
        diff: params.includeDiffs ? await getDiff(f) : null,
        summary: await summarizeChanges(f)  // LLM-based or simple stats
      }))
    );
    return { content };
  }
});
```

**Usage in agent flow:**
1. Agent completes turn
2. Before next turn, agent calls `get_codebase_changes`
3. Sees: "User modified src/types.ts - interface User changed"
4. Suggests: "I see you updated the User interface. Should I update the consumers in src/api/ and src/components/?"

---

### Comparison Matrix

| Approach | All Files | External Changes | Diffs Available | Complexity | Best For |
|----------|-----------|------------------|-----------------|------------|----------|
| Current (pi-neovim) | ❌ Loaded only | ❌ No | ❌ No | Low | Editor-focused |
| Git-based | ✅ Yes | ✅ Yes | ✅ Yes | Medium | Most projects |
| Filesystem watcher | ✅ Yes | ✅ Yes | ⚠️ Snapshots needed | High | Non-git projects |
| LSP workspace | ✅ Yes | ❌ No | ❌ No | Medium | Large refactors |
| Tool-driven | ✅ Yes | ✅ Yes | ✅ Optional | Low | User control |

---

## Recommendation for Your Project

**Hybrid Git + Context Tool approach:**

1. **Automatic lightweight tracking**: Use git to detect changed files since last turn
2. **Inject summary**: Add "N files changed externally" to system prompt
3. **On-demand deep dive**: Provide `get_codebase_changes` tool for detailed diffs
4. **Smart triggering**: If critical files changed (types, configs), auto-trigger review

This gives the agent awareness without overwhelming the context window, while letting it choose when to investigate deeper.

---

## Summary

The pi-neovim extension demonstrates a **pragmatic, production-ready** approach to agent-editor integration. Its strengths are in the bidirectional design, automatic context management, and clean lifecycle hooks. The main improvement opportunity is moving from subprocess-based RPC to a persistent connection for lower latency.

**Key insight**: The system treats the editor as a "source of truth" for context while the agent drives changes. The follow-up pattern for diagnostics creates a natural "code → check → fix" loop that feels like true pair programming.

**Your extension opportunity**: The gap is **workspace-level change awareness**. By tracking git deltas or filesystem changes, you can give the agent a complete picture of the codebase evolution, enabling smarter suggestions based on the full context of changes, not just the agent's own modifications.

---

## Project: pablopunk/pi.nvim

### Overview
A **minimalist, unidirectional** Neovim plugin for Pi. Unlike pi-extensions (bidirectional), this is a simpler "fire and forget" approach where Neovim drives Pi as a subprocess.

**Core Philosophy:**
> "It's funny that all AI plugins for Neovim are quite complex to interact with, like they want to imitate all current IDE features, while those are trending towards the simplicity of the CLI... pi.dev is the best example of this philosophy"

---

## Architecture Analysis

### 🔀 Communication Pattern: RPC Mode over Stdio

```
┌─────────────────┐         ┌─────────────────┐
│   Neovim        │────────►│   Pi (CLI)      │
│                 │  stdin  │                 │
│ - User prompt   │────────►│ - Mode: rpc     │
│ - Buffer content│         │ - No session    │
│ - Selection     │         │ - JSON events   │
└─────────────────┘         └─────────────────┘
        ▲                              │
        └──────────────────────────────┘
              JSON events (stdout)
```

**How it works:**

```lua
-- 1. Start pi in RPC mode
local cmd = { "pi", "--mode", "rpc", "--no-session" }
state.job = vim.fn.jobstart(cmd, {
  stdin = "pipe",
  on_stdout = function(_, data)
    for _, line in ipairs(data) do
      handle_event(line)  -- Parse JSON events
    end
  end,
})

-- 2. Send prompt via stdin
local prompt_cmd = vim.json.encode({
  type = "prompt",
  message = full_prompt,  -- User query + context
})
vim.fn.chansend(state.job, prompt_cmd .. "\n")
```

**Key differences from pi-extensions:**

| Aspect | pi-extensions | pi.nvim |
|--------|--------------|---------|
| Direction | Bidirectional | Unidirectional |
| Who hosts | Pi embeds Neovim terminal | Neovim spawns Pi |
| Connection | Unix socket (remote-expr) | Stdio JSON RPC |
| Context | Pi queries Neovim | Neovim pushes to Pi |
| Persistence | Multi-turn session | Single prompt/response |
| LSP feedback | Yes (follow-up messages) | No (one-shot) |

---

### 📝 Context Assembly

**File**: `lua/pi/init.lua`

Two context modes:

#### 1. Full Buffer Context (`:PiAsk`)

```lua
function M.get_buffer_context()
  local context = SYSTEM_PROMPT .. "\n\n"
  if has_filename then
    context = context .. string.format(
      "File: %s\n```\n%s\n```", 
      filename, content
    )
  end
  
  if buffer_is_empty(bufnr) then
    context = context .. "\n\n" .. EMPTY_FILE_NOTE
  end
  
  return context
end

-- SYSTEM_PROMPT:
-- "You are running inside the pi.nvim Neovim plugin. 
--  The user has sent a request and will not be able to reply back. 
--  You must complete the task immediately without asking any questions..."

-- EMPTY_FILE_NOTE:
-- "NOTE: This file is currently empty. Please create or populate it 
--  directly by applying the necessary edits..."
```

#### 2. Visual Selection Context (`:PiAskSelection`)

```lua
function M.get_visual_context()
  -- Sends BOTH full file AND selection
  context = string.format([[
    File: %s
    
    Full file content:
    ```
    %s
    ```
    
    Selected lines %d-%d:
    ```
    %s
    ```
  ]], filename, all_content, start_line, end_line, selection_content)
end
```

**Strengths:**
- ✅ Simple, predictable context format
- ✅ Handles empty files specially (prompts Pi to create content)
- ✅ Selection context includes full file for broader context
- ✅ Hardcoded system prompt forces agent to act (no clarifying questions)

**Weaknesses:**
- ⚠️ No automatic context on every turn
- ⚠️ No LSP diagnostics or error feedback
- ⚠️ Fixed system prompt, not configurable
- ⚠️ Context size grows linearly with file size

---

### 🪟 UI: Floating Window with Spinner

```lua
local function create_output_window()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = math.min(40, max_width),
    height = math.min(1, max_height),
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " pi ",
    title_pos = "center",
  })
  
  return buf, win
end
```

**Event handling:**

```lua
local function handle_event(data)
  local event = vim.json.decode(data)
  
  if event.type == "message_update" then
    if delta.type == "thinking_delta" then
      update_spinner("Thinking...")
    elseif delta.type == "error" then
      cleanup()  -- Close window, show error
    end
  elseif event.type == "tool_execution_start" then
    update_spinner("Running tool: " .. event.toolName)
  elseif event.type == "tool_execution_end" then
    update_spinner("Thinking...")
  elseif event.type == "agent_end" then
    stop_spinner()
    cleanup()  -- Close window
    vim.cmd("edit!")  -- Reload file
    vim.notify("pi finished", vim.log.levels.INFO)
  end
end
```

**Features:**
- Floating window with rounded border and "pi" title
- Animated spinner (⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏) with status text
- Virtual text extmark for inline spinner
- Auto-close on completion
- Auto-reload file (`:edit!`) when agent finishes

**Strengths:**
- ✅ Clean, unobtrusive UI (doesn't take over editor)
- ✅ Spinner gives feedback during long operations
- ✅ Markdown filetype for syntax highlighting
- ✅ Auto-reload shows changes immediately

**Weaknesses:**
- ⚠️ No scrollable output buffer (content not shown, just status)
- ⚠️ Window closes on completion - can't review what happened
- ⚠️ No way to see tool outputs or reasoning
- ⚠️ Blocking pattern (one job at a time)

---

## What to Adopt

| Component | Recommendation |
|-----------|---------------|
| **RPC mode over stdio** | ✅ Simple, no socket/files needed |
| **System prompt** | ✅ Forces agent to act, no back-and-forth |
| **Empty file handling** | ✅ Special prompt for file creation |
| **Selection context** | ✅ Full file + selection is smart |
| **Auto-reload on finish** | ✅ Essential for seeing changes |
| **Spinner feedback** | ✅ Good UX for long operations |
| **Floating window** | ✅ Non-intrusive, centered |

## What to Avoid/Improve

| Component | Issue | Better Approach |
|-----------|-------|----------------|
| **No session** | Each prompt is isolated | Allow multi-turn with context |
| **Output not visible** | Window shows spinner only, not content | Scrollable output buffer |
| **No LSP feedback** | Errors not shown | Query diagnostics post-edit |
| **Fixed system prompt** | Not configurable | Allow user override |
| **Single job** | Can't queue or parallelize | Job queue or cancellation |
| **Auto-close** | Can't review what happened | Keep buffer open, keymap to close |

---

## Comparison: pi-extensions vs pi.nvim

| Feature | pi-extensions | pi.nvim |
|---------|--------------|---------|
| **Complexity** | High (bidirectional) | Low (unidirectional) |
| **Setup** | Extension + Neovim plugin | Just Neovim plugin |
| **Pi mode** | Normal session | RPC mode (`--mode rpc`) |
| **Context injection** | Automatic (hooks) | Manual (commands) |
| **LSP integration** | Yes (follow-up diagnostics) | No |
| **File reload** | Immediate (on tool_result) | On agent_end |
| **Multi-turn** | Yes (persistent session) | No (one-shot) |
| **Terminal** | Embedded in Neovim | Floating window |
| **Output visibility** | Full TUI with history | Spinner only, auto-close |
| **Configuration** | Extensive | Minimal (provider/model) |

---

## Philosophical Differences

### pi-extensions: "Agent as IDE"
- Agent is the driver, editor is a component
- Rich integration, stateful, conversational
- More like Copilot/ChatGPT IDE integration

### pi.nvim: "Agent as CLI tool"
- Editor is the driver, agent is a utility
- Stateless, command-based, simple
- More like `:!git diff` or `:!make`

**Which to choose depends on your mental model:**
- Use **pi-extensions** if you want the agent to be a persistent pair programmer
- Use **pi.nvim** if you want the agent to be a powerful command you invoke when needed

For **sasu**, consider a hybrid:
- Lightweight like pi.nvim for quick tasks
- Rich integration like pi-extensions for deep sessions
- Workspace change tracking (the gap we identified) as a unique feature

---

## Project: ThePrimeagen/99

### Overview
A **multi-provider, async-first** AI client for Neovim supporting opencode, claude, cursor-agent, and kiro. Built for developers who "don't have skill issues" - focusing on streamlined, restricted AI workflows rather than general chat.

**Core Philosophy:**
> "The AI client that Neovim deserves, built by those that still enjoy to code."
> "For more general requests, please just use opencode. Don't use neovim."

---

## Architecture Analysis

### 🔄 Async Job Architecture: vim.system + Deferred Execution

```
┌─────────────────────────────────────────────────────────────────┐
│                        99 State Manager                          │
├─────────────────────────────────────────────────────────────────┤
│  __active_requests: table<number, ActiveRequest>                │
│  __request_history: RequestEntry[]                              │
│  __request_by_id: table<number, RequestEntry>                   │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
   ┌─────────┐          ┌──────────┐          ┌──────────┐
   │ Request │          │ Request  │          │ Request  │
   │   #1    │          │   #2     │          │   #3     │
   │(running)│          │(running) │          │(running) │
   └────┬────┘          └────┬─────┘          └────┬─────┘
        │                    │                     │
        ▼                    ▼                     ▼
   ┌─────────┐          ┌──────────┐          ┌──────────┐
   │ vim.system() │     │ vim.system()  │     │ vim.system()  │
   │ (opencode)   │     │ (claude)      │     │ (cursor-agent)│
   └──────────────┘     └───────────────┘     └───────────────┘
```

**Key Architecture Patterns:**

#### 1. **Request State Management**

```lua
--- @class _99.Request
--- @field state "ready" | "calling-model" | "parsing-result" | "updating-file" | "cancelled"
--- @field _proc vim.SystemObj?
local Request = {}

function Request:cancel()
  self.state = "cancelled"
  if self._proc and self._proc.pid then
    local sigterm = vim.uv.constants.SIGTERM
    self._proc:kill(sigterm)
  end
end
```

#### 2. **Global State with Request Tracking**

```lua
--- @class _99.State
--- @field __active_requests table<number, _99.ActiveRequest>
--- @field __request_history _99.RequestEntry[]
--- @field __request_by_id table<number, _99.RequestEntry>

function _99_State:add_active_request(clean_up, request_id, name)
  _active_request_id = _active_request_id + 1
  self.__active_requests[_active_request_id] = {
    clean_up = clean_up,
    request_id = request_id,
    name = name,
  }
  return _active_request_id
end

function _99.stop_all_requests()
  for _, active in pairs(_99_state.__active_requests) do
    active.clean_up()
  end
  _99_state.__active_requests = {}
end
```

#### 3. **vim.system for Non-Blocking I/O**

```lua
function BaseProvider:make_request(query, request, observer)
  local command = self:_build_command(query, request)
  
  local proc = vim.system(
    command,
    {
      text = true,
      stdout = vim.schedule_wrap(function(err, data)
        if request:is_cancelled() then
          once_complete("cancelled", "")
          return
        end
        observer.on_stdout(data)
      end),
      stderr = vim.schedule_wrap(function(err, data)
        observer.on_stderr(data)
      end),
    },
    vim.schedule_wrap(function(obj)
      if obj.code ~= 0 then
        once_complete("failed", str)
      else
        once_complete("success", res)
      end
    end)
  )

  request:_set_process(proc)
end
```

**Key strengths:**
- ✅ True async using `vim.system` (Neovim 0.10+)
- ✅ Multiple concurrent requests supported
- ✅ Proper cancellation with SIGTERM
- ✅ Observer pattern for streaming responses
- ✅ `vim.schedule_wrap` for safe UI updates from callbacks

---

### 🎨 Visual Feedback System

#### 1. **RequestStatus: Animated Virtual Text**

```lua
--- @class _99.RequestStatus
--- @field update_time number  -- milliseconds per update
--- @field max_lines number    -- number of status lines
--- @field mark? _99.Mark      -- extmark position

function RequestStatus:start()
  local function update_spinner()
    if not self.running then return end
    
    self.status_line:update()
    if self.mark then
      self.mark:set_virtual_text(self:get())
    end
    vim.defer_fn(update_spinner, self.update_time)
  end
  
  self.running = true
  vim.defer_fn(update_spinner, self.update_time)
end

-- Usage: Status lines appear above/below selection
local top_status = RequestStatus.new(250, 3, "Implementing", top_mark)
local bottom_status = RequestStatus.new(250, 1, "Implementing", bottom_mark)
```

#### 2. **Throbber: Eased Animation**

```lua
--- @class _99.Throbber
--- @field state "init" | "throbbing" | "cooldown" | "stopped"

function Throbber:_run()
  local elapsed = time.now() - self.start_time
  local percent = math.min(1, elapsed / self.section_time)
  local icon = self.throb_fn(percent)
  
  self.cb(icon)  -- Callback to update UI
  vim.defer_fn(function() self:_run() end, tick_time)
end
```

**Animation features:**
- Multiple icon sets (⠋⠙⠹..., ◐◓◑◒, ⣾⣽⣻...)
- Easing functions (linear, ease-in-out-quadratic, ease-in-out-cubic)
- Throb/cooldown cycles for visual variety

#### 3. **In-Flight Requests Window**

```lua
local function show_in_flight_requests()
  vim.defer_fn(show_in_flight_requests, 1000)  -- Poll every second
  
  if _99_state:active_request_count() == 0 then return end
  
  local win = Window.status_window()
  local throb = Throbber.new(function(throb)
    local count = _99_state:active_request_count()
    local lines = {
      throb .. " requests(" .. tostring(count) .. ") " .. throb,
    }
    for _, r in pairs(_99_state.__active_requests) do
      table.insert(lines, r.name)
    end
    Window.resize(win, #lines[1], #lines)
    vim.api.nvim_buf_set_lines(win.buf_id, 0, 1, false, lines)
  end)
  
  throb:start()
end
```

---

### 🧩 Provider Abstraction

```lua
--- @class _99.Providers.BaseProvider
--- @field _build_command fun(self, query: string, request: _99.Request): string[]
--- @field _get_provider_name fun(self): string

local BaseProvider = {}

function BaseProvider:make_request(query, request, observer)
  -- Shared implementation for all providers
end

-- Concrete providers override only command building
local OpenCodeProvider = setmetatable({}, { __index = BaseProvider })

function OpenCodeProvider._build_command(_, query, request)
  return {
    "opencode", "run", "--agent", "build",
    "-m", request.context.model, query,
  }
end
```

**Supported providers:**
| Provider | CLI | Default Model |
|----------|-----|---------------|
| OpenCodeProvider | `opencode` | opencode/claude-sonnet-4-5 |
| ClaudeCodeProvider | `claude` | claude-sonnet-4-5 |
| CursorAgentProvider | `cursor-agent` | sonnet-4.5 |
| KiroProvider | `kiro-cli` | claude-sonnet-4-5 |

---

### 📝 Context Assembly & Rules System

```lua
function _99_State:refresh_rules()
  self.rules = Agents.rules(self)
  Extensions.refresh(self)
end

-- #rules and @files completion
local refs = Completions.parse(additional_prompt)
context:add_references(refs)
```

**Features:**
- **SKILL.md system**: Load domain-specific rules from directories
- **#rules**: Reference rules by name with autocomplete
- **@files**: Reference files with fuzzy search
- **AGENT.md**: Auto-discovered context files in parent directories

---

### 🧹 Cleanup Pattern

```lua
---@param context _99.RequestContext
---@param name string
---@param clean_up_fn fun(): nil
---@return fun(): nil
return function(context, name, clean_up_fn)
  local called = false
  local function clean_up()
    if called then return end
    called = true
    clean_up_fn()
    context._99:remove_active_request(request_id)
  end
  
  request_id = context._99:add_active_request(clean_up, context.xid, name)
  return clean_up
end
```

**Ensures:**
- Idempotent cleanup (called once)
- Request removal from active list
- Resource cleanup (marks, status lines, processes)

---

## What to Adopt

| Component | Recommendation |
|-----------|---------------|
| **vim.system** | ✅ Modern async API (Neovim 0.10+) |
| **Request state machine** | ✅ Clear lifecycle (ready → calling → parsing → updating) |
| **Global request tracking** | ✅ Cancel all, view history, status overview |
| **Observer pattern** | ✅ Clean separation of request and UI |
| **Throbber with easing** | ✅ Polished visual feedback |
| **Virtual text status** | ✅ Non-intrusive progress indication |
| **Provider abstraction** | ✅ Easy to add new AI backends |
| **Rules system (#/@)** | ✅ Powerful context augmentation |
| **Cleanup guards** | ✅ Prevents double-cleanup bugs |

## What to Avoid/Improve

| Component | Issue | Better Approach |
|-----------|-------|----------------|
| **Polling for UI** | `vim.defer_fn(show_in_flight_requests, 1000)` | Event-driven updates |
| **Temp file for response** | `_retrieve_response` reads from disk | Capture stdout directly |
| **No bidirectional** | One-shot requests only | Session-based for multi-turn |
| **Limited error recovery** | Fatal on mark invalidation | Graceful degradation |
| **Global state** | `_99_state` singleton | Dependency injection for testability |

---

## Comparison: 99 vs Others

| Feature | 99 | pi-extensions | pi.nvim |
|---------|-----|---------------|---------|
| **Async model** | vim.system (true async) | Subprocess RPC | jobstart (legacy) |
| **Parallel requests** | ✅ Yes | ❌ No | ❌ No |
| **Cancellation** | ✅ SIGTERM | ❌ N/A | ❌ No |
| **Multi-provider** | ✅ 4 providers | ❌ Pi only | ❌ Pi only |
| **Visual feedback** | Virtual text + throbber | Custom TUI | Spinner only |
| **Request history** | ✅ Full history | Session-based | ❌ None |
| **Rules system** | ✅ SKILL.md + #/@ | Context files | ❌ None |
| **Session support** | ❌ One-shot | ✅ Yes | ❌ One-shot |

---

## Key Innovations

### 1. **True Parallel Execution**
Unlike pi-extensions and pi.nvim which handle one request at a time, 99 supports multiple concurrent AI requests with proper lifecycle management.

### 2. **Rich Visual Feedback Without Blocking**
Virtual text spinners at the location of change (above/below selection) rather than a separate window.

### 3. **Rules System**
Domain-specific SKILL.md files with `#rule` and `@file` completion for powerful context assembly.

### 4. **Provider Abstraction**
Clean separation allowing support for opencode, claude, cursor-agent, and kiro without code changes.

---

## Summary

**99** represents a **mature, async-first architecture** for AI-Neovim integration. Its use of `vim.system`, parallel request handling, and sophisticated visual feedback sets it apart from both pi-extensions (bidirectional but single-threaded) and pi.nvim (simple but blocking).

**For sasu:**
- Adopt the **async job architecture** (vim.system + state tracking)
- Consider the **rules system** for domain-specific context
- Take the **cancellation** and **cleanup patterns** for robustness
- The **virtual text feedback** is less intrusive than floating windows

**Gap to fill:** 99 is one-shot only - no session persistence or bidirectional communication. Combining 99's async architecture with pi-extensions' bidirectional hooks would be powerful.

---

## Project: Piotr1215/pairup.nvim

### Overview
An **inline AI pair programming** plugin that uses comment markers (`cc:`, `uu:`, `cc!:`, `ccp:`) to trigger Claude Code CLI actions directly in the editor. Unlike other plugins that manage complex state, pairup.nvim takes a radically simplified approach inspired by sidekick.nvim.

**Core Philosophy:**
> "Less complexity, more reliability. Claude edits files directly — no parsing, no overlays, no state management. Just write `cc:`, save, and Claude handles it."

---

## Architecture Analysis

### 🔄 v4 Architecture: The Great Simplification

**From v4-architecture.md:**

| Before (v3) | After (v4) |
|-------------|-----------|
| **Extmark-based indexing** | **Line-based scanning** |
| 4-state workflow (pending/accepted/rejected/edited) | Immediate accept/reject |
| Variant management (multiple alternatives) | Single best suggestion |
| Continuous position recalculation | Clear-and-rebuild pattern |
| Tight coupling between display/buffer | Stateless, functional approach |

### Why Extmark Indexing Was Abandoned

**The Problem with Extmark-Based Systems:**

```lua
-- OLD v3 approach (conceptual):
local overlay = {
  extmark_id = 42,        -- Neovim's extmark ID
  line = 10,              -- Original line number
  state = "pending",      -- pending/accepted/rejected/edited
  variants = {...},       -- Multiple suggestions
  current_variant = 1,
}

-- When buffer changes (lines inserted/deleted):
-- 1. Extmarks shift automatically ✓
-- 2. But overlay state is now OUT OF SYNC with actual buffer
-- 3. Need to re-sync: query extmark position, update overlay
-- 4. Race conditions when multiple overlays exist
-- 5. Complex state machine for "edited while pending"
```

**Issues with extmark indexing:**
1. **Synchronization overhead** - Every buffer change requires re-syncing extmark positions with overlay state
2. **State coupling** - Display state (extmark) tightly coupled with logical state (overlay)
3. **Race conditions** - Multiple overlays shifting simultaneously creates timing issues
4. **Complex transitions** - 4-state workflow (pending→accepted→rejected→edited) with edge cases
5. **Position drift** - Extmarks move with text, but semantic meaning of "line 10" changes

**The v4 Solution:**

```lua
-- NEW v4 approach:
local function detect_markers(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local markers = {}
  for i, line in ipairs(lines) do
    if line:find("cc:", 1, true) then
      table.insert(markers, { line = i, type = "command", content = line })
    end
  end
  return markers
end

-- On any change:
-- 1. Clear ALL signs/highlights
-- 2. Re-scan entire buffer
-- 3. Re-render everything
-- No state to sync - just scan, render, done
```

**Trade-offs:**
| Aspect | Extmark Indexing (v3) | Line-Based Scanning (v4) |
|--------|----------------------|------------------------|
| **Performance** | Incremental updates | Full re-scan on change |
| **Complexity** | High (state sync) | Low (stateless) |
| **Reliability** | Edge cases, race conditions | Deterministic, predictable |
| **Memory** | Overlay objects persist | Temporary scan results |
| **Debugging** | Hard (state machine) | Easy (pure functions) |

---

### 🏗️ Current Architecture Components

#### 1. **Marker Detection (Stateless Scanning)**

```lua
-- lua/pairup/inline.lua
function M.detect_markers(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local markers = {}
  local sorted_markers = get_sorted_markers()  -- Longest pattern first

  for i, line in ipairs(lines) do
    for _, m in ipairs(sorted_markers) do
      if line:find(m.pattern, 1, true) then
        table.insert(markers, { line = i, type = m.type, content = line })
        break  -- First match wins
      end
    end
  end
  return markers
end
```

**Marker types:**
| Marker | Purpose | Action |
|--------|---------|--------|
| `cc:` | Command | Execute instruction, remove marker |
| `uu:` | Question | Ask for clarification |
| `cc!:` | Constitution | Execute + extract rule to CLAUDE.md |
| `ccp:` | Plan | Wrap in conflict markers for review |

#### 2. **Clear-and-Rebuild Rendering**

```lua
-- lua/pairup/signs.lua
function M.update(bufnr)
  -- 1. Clear everything
  vim.fn.sign_unplace(sign_group, { buffer = bufnr })
  vim.api.nvim_buf_clear_namespace(bufnr, hl_ns, 0, -1)

  -- 2. Re-scan
  local markers = detect_markers(bufnr)
  
  -- 3. Re-render
  for _, m in ipairs(markers) do
    place_marker(bufnr, m.line, m.content, m.is_question)
  end
end

-- Triggered by: BufEnter, BufWritePost, TextChanged, TextChangedI
```

**Why this works:**
- No extmark IDs to track
- No position synchronization
- No state machine
- Deterministic: same buffer content = same markers

#### 3. **Conflict Markers for Review Flow**

For `ccp:` (plan) markers, Claude generates conflict-style markers:

```lua
-- User writes:
-- ccp: add error handling
function process(data) return data.value end

-- Claude converts to:
<<<<<<< CURRENT
function process(data)
  return data.value
end
=======
function process(data)
  if not data then return nil, "missing data" end
  return data.value
end
>>>>>>> PROPOSED: add error handling
```

**Accept/Reject mechanism:**
```lua
-- lua/pairup/conflict.lua
function M.accept()
  local block = find_block_at_cursor()
  if block.in_current then
    -- Keep original (lines between start_marker and separator)
    keep_lines(block.start_marker + 1, block.separator - 1)
  else
    -- Keep proposed (lines between separator and end_marker)
    keep_lines(block.separator + 1, block.end_marker - 1)
  end
end
```

**No state needed** - cursor position determines action.

---

### 🎯 Provider Integration

```lua
-- lua/pairup/providers/init.lua
function M.send_to_provider(message)
  if M.current and M.current.send_to_terminal then
    return M.current.send_to_terminal(message)
  end
end

-- Fast running check (O(1))
function M.is_running()
  local cached_buf = vim.g.pairup_terminal_buf
  return cached_buf and vim.api.nvim_buf_is_valid(cached_buf)
end
```

**Claude Code CLI integration:**
```lua
-- lua/pairup/providers/claude.lua
function M.start()
  local cmd = config.get('providers.claude.cmd') 
    -- "claude --permission-mode acceptEdits"
  
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, false, {
    split = position,
    ...
  })
  
  vim.fn.termopen(cmd, {
    on_exit = function() M.stop() end,
  })
end
```

---

### 📊 Progress Tracking (File-Based)

Instead of maintaining state, pairup uses **file-based IPC** via Claude hooks:

```bash
# Hook script: ~/.claude/scripts/__pairup_todo_hook.sh
# Triggered by PostToolUse hook on TodoWrite

# Writes to: /tmp/pairup-todo-{session_id}.json
{
  "total": 5,
  "completed": 2,
  "current": "Analyzing function signatures"
}
```

```lua
-- lua/pairup/utils/indicator.lua
local function check_hook_state()
  local hook_file = get_hook_file()  -- /tmp/pairup-todo-*.json
  local stat = vim.loop.fs_stat(hook_file)
  
  if mtime == last_file_mtime then return end  -- No change
  last_file_mtime = mtime
  
  local data = vim.json.decode(read_file(hook_file))
  set_indicator(string.format('[C:%d/%d]', data.completed, data.total))
  set_virtual_text(data.current)
end

-- Poll every 500ms
file_watcher:start(500, 500, vim.schedule_wrap(check_hook_state))
```

**Advantages:**
- No direct coupling between Neovim and Claude
- Survives Neovim restarts
- Simple JSON file as shared state
- Works across process boundaries

---

## What to Adopt

| Component | Recommendation |
|-----------|---------------|
| **Stateless scanning** | ✅ Clear-and-rebuild eliminates sync bugs |
| **Line-based detection** | ✅ Simple, deterministic, debuggable |
| **Conflict markers** | ✅ Standard format, no custom UI needed |
| **File-based IPC** | ✅ Decouples Neovim from AI process |
| **Immediate actions** | ✅ No pending state complexity |
| **Marker operators** | ✅ `gC{motion}` for quick marker insertion |
| **Progress via hooks** | ✅ Non-invasive progress tracking |

## What to Avoid/Improve

| Component | Issue | Better Approach |
|-----------|-------|----------------|
| **Full re-scan** | O(n) on every keystroke | Debounce + incremental for large files |
| **Polling for progress** | 500ms latency | File watcher events (if available) |
| **Conflict markers** | Verbose in prose files | Virtual text diff for non-code |
| **Single provider** | Only Claude Code | Provider abstraction (like 99) |
| **No session history** | One-shot requests | Request log (like 99) |

---

## Comparison: pairup.nvim vs Others

| Feature | pairup.nvim | 99 | pi-extensions | pi.nvim |
|---------|-------------|-----|---------------|---------|
| **State management** | Stateless | Global state | Hooks + tools | Simple state |
| **Position tracking** | Line scanning | Marks | Extmarks (via RPC) | N/A |
| **Suggestion display** | Conflict markers | Virtual text | TUI renderers | Spinner only |
| **Accept/Reject** | Cursor-based | Immediate | Tool confirmation | N/A |
| **Provider support** | Claude only | 4 providers | Pi only | Pi only |
| **Async model** | termopen | vim.system | Subprocess RPC | jobstart |
| **Progress tracking** | File-based hooks | vim.loop timer | Built-in | N/A |
| **Multi-turn** | Via `uu:` markers | ❌ | ✅ | ❌ |

---

## Key Innovations

### 1. **Radical Simplicity**
The v4 rewrite demonstrates that **statelessness beats smart state management**. By abandoning extmark indexing and state machines, the plugin became more reliable and maintainable.

### 2. **Conflict Markers as UI**
Using standard Git conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) for review flow means:
- No custom UI components to maintain
- Users already understand the format
- Works with existing diff tools
- Cursor position determines context

### 3. **File-Based IPC**
Instead of complex RPC or shared memory, simple JSON files in `/tmp` provide:
- Process isolation
- Persistence across restarts
- Easy debugging (just `cat` the file)
- Language-agnostic (any AI CLI can write to it)

---

## Summary

**pairup.nvim** represents a **philosophical rejection of complexity** in AI-Neovim integration. The v4 architecture demonstrates that for many use cases, **stateless line-scanning outperforms sophisticated extmark-based tracking**.

**For sasu:**
- Consider **stateless approaches** for simple marker-based workflows
- **Conflict markers** are a clever reuse of existing UI conventions
- **File-based IPC** is surprisingly effective for decoupling
- The **clear-and-rebuild pattern** eliminates an entire class of synchronization bugs

**Trade-off to consider:** pairup.nvim sacrifices some features (variants, staging, complex state) for reliability. Depending on your use case, this may be the right trade-off.

---

## Cross-Project Patterns Summary

| Pattern | Projects Using It | Best For |
|---------|------------------|----------|
| **Extmark indexing** | pi-extensions | Persistent overlays, rich UI |
| **Line scanning** | pairup.nvim (v4) | Simple markers, reliability |
| **vim.system** | 99 | True async, parallel requests |
| **RPC over socket** | pi-extensions | Bidirectional communication |
| **Stdio JSON RPC** | pi.nvim | Simple integration |
| **File-based IPC** | pairup.nvim | Decoupled progress tracking |
| **Conflict markers** | pairup.nvim | Review/accept flow |
| **Virtual text spinners** | 99 | Non-intrusive feedback |
| **Hooks (lifecycle)** | pi-extensions | Automatic context injection |

**Recommended architecture for sasu:**
1. **Async foundation**: `vim.system` from 99
2. **Bidirectional capabilities**: Socket RPC from pi-extensions
3. **Workspace change tracking**: Git-based delta (our gap analysis)
4. **State management**: Hybrid - stateless for simple markers, extmarks for rich overlays
5. **Visual feedback**: Virtual text spinners (99) + conflict markers (pairup) for review
6. **Provider abstraction**: From 99 (multi-provider support)
