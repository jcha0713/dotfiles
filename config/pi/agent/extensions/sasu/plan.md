# SASU - Structured Agentic Software Understanding

## Vision

A human-driven, AI-validated pair programming environment where the human writes code and the AI reviews, validates, and guides.

### Core Philosophy

**"You code, AI validates."**

Traditional AI coding tools have the AI write code for the human to review. SASU inverts this: the human writes code, and the AI reviews it. This puts the human in the driver's seat while leveraging AI for validation, error detection, and guidance.

### Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                     SASU WORKFLOW OVERVIEW                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. DISCUSS                                                      │
│     └─ User and Pi discuss the implementation plan              │
│     └─ Pi breaks down into concrete tasks                        │
│     └─ Session persists across invocations                       │
│                                                                  │
│  2. IMPLEMENT                                                    │
│     └─ Pi's turn ends, hook triggers                             │
│     └─ $EDITOR opens at specified file:line (or cwd)            │
│     └─ User edits ANY files in the codebase                     │
│                                                                  │
│  3. VALIDATE                                                     │
│     └─ User runs :BackToPi [optional message]                   │
│     └─ Pi sees FULL codebase changes (git diff)                 │
│     └─ Pi validates, discusses, suggests, or auto-fixes         │
│                                                                  │
│  4. ITERATE                                                      │
│     └─ Repeat 2-3 until task complete                           │
│                                                                  │
│  5. PROGRESS                                                     │
│     └─ Move to next task, update session state                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Example Session

```
User: "I want to add user authentication to my app"

Pi: "Let's break this down:
  1. Create User model with email/password
  2. Add password hashing
  3. Create login endpoint
  4. Add JWT token generation

  I'll open the editor for you to start with task 1."

[Hook fires, $EDITOR opens at src/models/user.ts:1]

User: [implements User interface]
User: :BackToPi

Pi: [analyzes git diff]
"Good start! I see you created the User interface with:
  - email: string
  - passwordHash: string
  - createdAt: Date

  But I notice you're missing:
  1. Input validation (email format, password strength)
  2. The createUser function returns User but doesn't initialize fields

  Would you like me to:
  a) Open the editor with suggestions
  b) Explain what validation to add
  c) Move to task 2 and come back to this later"

User: "b"

Pi: [explains validation approaches]

[Cycle continues until task 1 complete, then task 2, etc.]
```

---

## Phase 1: Minimal Viable Workflow (MVP)

### Scope

The goal is to get the core workflow functional with minimal complexity.

### Features

| Feature             | Description                        | Priority |
| ------------------- | ---------------------------------- | -------- |
| Session persistence | Save plan and progress to file     | Required |
| Hook-based editor   | Open $EDITOR on turn_end           | Required |
| Git checkpoint      | Stash changes before editor opens  | Required |
| :BackToPi command   | Capture changes and send to Pi     | Required |
| Git diff analysis   | Show Pi full codebase changes      | Required |
| Simple session file | JSON with plan, tasks, checkpoints | Required |

### Technical Architecture

#### Components

```
sasu/
├── lua/sasu/
│   ├── init.lua           -- Main API, setup()
│   ├── session.lua        -- File-based persistence
│   ├── editor.lua         -- $EDITOR control
│   ├── diff.lua           -- Git delta tracking
│   └── hooks.lua          -- Pi lifecycle hooks
├── plugin/sasu.lua        -- :BackToPi command
└── README.md
```

#### Session File Format

```json
{
  "version": 1,
  "project": "/home/user/myapp",
  "created_at": "2025-01-20T10:30:00Z",
  "updated_at": "2025-01-20T11:45:00Z",
  "plan": "Add user authentication to the app",
  "tasks": [
    {
      "id": 1,
      "description": "Create User model with email/password",
      "status": "in_progress",
      "checkpoint": "stash@{0}"
    },
    {
      "id": 2,
      "description": "Add password hashing",
      "status": "pending"
    },
    {
      "id": 3,
      "description": "Create login endpoint",
      "status": "pending"
    },
    {
      "id": 4,
      "description": "Add JWT token generation",
      "status": "pending"
    }
  ],
  "current_task": 1
}
```

#### Workflow Implementation

**1. Discussion Phase**

```lua
-- During Pi conversation, when plan is agreed upon:
-- Pi calls hook: sasu_plan_accepted(plan, tasks)

function M.plan_accepted(plan, tasks)
	local session = {
		version = 1,
		project = vim.fn.getcwd(),
		plan = plan,
		tasks = tasks,
		current_task = 1,
	}
	save_session(session)
end
```

**2. Editor Opening**

```lua
-- On turn_end, Pi triggers: sasu_open_editor(file, line)

function M.open_editor(filepath, line)
	-- 1. Save checkpoint
	local task = get_current_task()
	vim.fn.system('git stash push -m "sasu-before-task-' .. task.id .. '"')
	task.checkpoint = "stash@{0}"
	save_session(session)

	-- 2. Open editor
	local target = filepath or "."
	if line then
		target = target .. ":" .. line
	end

	-- Block until editor closes
	vim.fn.system("$EDITOR " .. target)

	-- 3. Editor closed, now what?
	-- Pi is waiting for :BackToPi command
	-- Show hint to user
	vim.notify("Edit complete. Run :BackToPi when ready for review.", vim.log.levels.INFO)
end
```

**3. BackToPi Command**

```lua
-- User runs :BackToPi or :BackToPi "I need help with..."

function M.back_to_pi(user_message)
	-- 1. Get git diff since checkpoint
	local task = get_current_task()
	local diff = vim.fn.system("git diff " .. task.checkpoint .. "..HEAD")

	-- 2. Get list of changed files
	local files = vim.fn.systemlist("git diff --name-only " .. task.checkpoint .. "..HEAD")

	-- 3. Format message for Pi
	local context = {
		task = task.description,
		files_changed = files,
		diff = diff,
		user_message = user_message or "Please review my changes",
	}

	-- 4. Send to Pi (how depends on Pi integration)
	-- For now: write to file that Pi extension reads
	local context_file = vim.fn.stdpath("data") .. "/sasu/context.json"
	write_json(context_file, context)

	-- 5. Notify Pi (via hook or file watcher)
	vim.fn.system("touch " .. vim.fn.stdpath("data") .. "/sasu/ready")
end
```

### User Interface

**Commands:**

- `:BackToPi` - Submit changes for review
- `:BackToPi "message"` - Submit with context
- `:SasuStatus` - Show current task and progress
- `:SasuPlan` - Show full plan

**Workflow Indicators:**

- Statusline: `[sasu: task 1/4]` or empty if no session
- Notifications: "Editor opened at src/models/user.ts:1"

### Success Criteria

1. User can discuss plan with Pi
2. Pi can trigger editor opening
3. User can edit files
4. :BackToPi captures changes
5. Pi sees diff and can discuss
6. Session persists across :BackToPi calls
7. Tasks advance when complete

---

## Phase 2: Enhanced Context (Future Exploration)

### Motivation

Phase 1 only shows Pi the git diff. Pi doesn't know about:

- TypeScript errors that exist after your changes
- What files you looked at but didn't modify
- The full context of your project structure

### Features to Explore

| Feature              | Description                    | User Benefit                   |
| -------------------- | ------------------------------ | ------------------------------ |
| LSP error query      | Pi asks Neovim for diagnostics | Catches errors before runtime  |
| Buffer context       | Pi knows what files are open   | Better understanding of intent |
| Plan buffer          | Side panel showing plan/tasks  | User doesn't forget context    |
| File browser context | Pi sees project structure      | Can suggest related files      |

### Example Use Cases

**LSP Error Detection:**

```
User: :BackToPi

Pi: [queries Neovim for diagnostics]
"I see your changes, but TypeScript reports:
  - Line 5: Cannot find name 'bcrypt'
  - Line 12: Type 'string' not assignable to 'Date'

  Should I open the editor with these fixes?"
```

**Plan Buffer:**

```
┌─────────────────────┬─────────────────────────────────────────┐
│  SASU PLAN          │  // src/models/user.ts                  │
│  ─────────          │  export interface User {                │
│                     │    email: string;                       │
│  ✅ 1. User model   │    passwordHash: string;                │
│  🔄 2. Hashing      │    createdAt: Date;                     │
│  ⏳ 3. Login        │  }                                      │
│  ⏳ 4. JWT          │                                         │
│                     │  export function createUser(...)        │
│  Hint: Use argon2   │    // TODO: implement                   │
│  for hashing        │  }                                      │
└─────────────────────┴─────────────────────────────────────────┘
```

### Technical Notes

- Requires bidirectional communication (Pi queries Neovim)
- Can use socket/RPC (like pi-extensions) or file polling
- Plan buffer is a secondary window that updates on session changes

---

## Phase 3: Rich Feedback (Future Exploration)

### Motivation

Phase 1-2 are functional but lack polish. Phase 3 adds visual feedback for better UX.

### Features to Explore

| Feature              | Description                | User Benefit             |
| -------------------- | -------------------------- | ------------------------ |
| Virtual text spinner | Show "Analyzing..." inline | Know Pi is working       |
| Multi-file diff view | Rich diff for many changes | Better review experience |
| Parallel tasks       | Background analysis        | Faster workflow          |
| Accept/reject UI     | Conflict-style markers     | Clear decision points    |
| Task queue           | Queue multiple tasks       | Batch operations         |

### Example Use Cases

**Virtual Text Feedback:**

```typescript
// src/models/user.ts
export interface User {
  email: string;
  passwordHash: string;
  createdAt: Date;
}

  ⠙ Analyzing changes...              ← virtual text
    Checking TypeScript errors...
```

**Rich Diff View:**

```
┌─────────────────────────────────────────────────────────────────┐
│ Changes Summary                                                  │
│ src/models/user.ts              [+45 lines]  NEW FILE           │
│ src/db/schema.ts                [+12 -3 lines]  MODIFIED        │
│                                                                  │
│ Press 'd' for diff view, 'c' to continue                        │
└─────────────────────────────────────────────────────────────────┘
```

**Conflict-Style Review:**

```typescript
<<<<<<< BEFORE
  users: defineTable({
    id: integer(),
    name: varchar(255)
  })
=======
  users: defineTable({
    id: integer(),
    email: varchar(255).unique(),
    passwordHash: varchar(255)
  })
>>>>>>> AFTER
```

### Technical Notes

- Virtual text requires extmark API
- Diff view can reuse conflict.lua from pairup.nvim
- Parallel tasks need job management (like 99)
- May need nvim 0.10+ for best results

---

## Comparison with Existing Tools

| Tool        | Model              | Human Role         | AI Role       | Session        |
| ----------- | ------------------ | ------------------ | ------------- | -------------- |
| Copilot     | Inline suggestions | Review suggestions | Generate code | None           |
| Claude Code | Chat               | Ask questions      | Do tasks      | Persistent     |
| Aider       | Chat + edit        | Guide              | Edit files    | Git-based      |
| pi.nvim     | Terminal           | Prompt             | Execute       | One-shot       |
| 99          | Visual selection   | Review             | Replace       | One-shot       |
| pairup.nvim | Markers            | Trigger            | Edit          | Claude manages |
| **SASU**    | **Human codes**    | **Implement**      | **Validate**  | **Persistent** |

### Key Differentiators

1. **Human-driven**: You write code, AI doesn't
2. **Validation-focused**: AI reviews your work, not vice versa
3. **Full codebase awareness**: Git diff shows all changes
4. **Persistent sessions**: Plan and progress survive restarts
5. **Task-oriented**: Breaks work into discrete, trackable tasks

---

## Implementation Timeline

### Phase 1: MVP (4-6 weeks)

**Week 1-2: Core infrastructure**

- Session file format
- Save/load session
- Git checkpoint/stash

**Week 3-4: Editor integration**

- Hook for turn_end
- $EDITOR opening
- Blocking mechanism

**Week 5-6: BackToPi flow**

- :BackToPi command
- Git diff capture
- Context formatting for Pi
- Task advancement

### Phase 2: Context (2-3 months)

**Month 2: Bidirectional queries**

- Socket/RPC setup
- LSP diagnostics query
- Buffer context query

**Month 3: Plan buffer**

- Side panel window
- Plan visualization
- Task status updates

### Phase 3: Polish (Ongoing)

**Month 4+: Rich feedback**

- Virtual text spinners
- Diff view
- Parallel tasks

---

## Open Questions

### Technical

1. **Pi integration**: How exactly does Pi receive the context after :BackToPi?

   - File watcher on context.json?
   - RPC call to Pi extension?
   - Stdin write if Pi is subprocess?

2. **Editor blocking**: How to properly block Pi until :BackToPi?

   - Coroutine yield?
   - Async await?
   - Process signal?

3. **Git integration**: Require git repo or make optional?
   - With git: full diff, checkpointing
   - Without: file content snapshot, diff via temp files

### UX

1. **Task granularity**: Who decides when a task is complete?

   - User declares: "This is done"
   - Pi validates and confirms
   - Automatic on :BackToPi with no issues

2. **Error handling**: What if user exits editor without :BackToPi?

   - Session stays in "editing" state
   - :BackToPi still works
   - Or auto-capture on editor close?

3. **Multi-project**: Can user work on multiple projects simultaneously?
   - One session per project (recommended)
   - Or global session with project switching?

---

## Success Metrics

### Phase 1

- [ ] Can create a session from Pi discussion
- [ ] Editor opens on turn_end
- [ ] :BackToPi captures changes
- [ ] Pi receives and can analyze diff
- [ ] Session persists across invocations
- [ ] Tasks advance when complete
- [ ] Works with any $EDITOR (nvim, vim, code, etc.)

### Phase 2

- [ ] Pi can query LSP errors
- [ ] Plan buffer shows current task
- [ ] Pi understands project structure

### Phase 3

- [ ] Visual feedback during analysis
- [ ] Rich diff view for multi-file changes
- [ ] Background tasks run in parallel

---

## Appendix: Reference Implementations

### Session Persistence

From **pairup.nvim** (file-based IPC):

```lua
-- Write session to JSON
local f = io.open(session_path, "w")
f:write(vim.json.encode(session))
f:close()
```

### Git Checkpoint

```lua
-- Create checkpoint before editor
vim.fn.system('git stash push -m "sasu-task-' .. task_id .. '"')
-- Later: get diff
local diff = vim.fn.system("git diff stash@{0}..HEAD")
```

### Editor Opening

From **99** (vim.system):

```lua
-- Open editor and wait
vim.system({ os.getenv("EDITOR"), filepath }, { detach = false }):wait()
```

Or simpler with vim.fn:

```lua
-- Block until editor closes
vim.fn.system("$EDITOR " .. filepath)
```

### Hook Integration

From **pi-extensions**:

```lua
-- Register hook
pi.on("turn_end", function(event, ctx)
	-- Check if sasu session active
	-- Open editor
end)
```

---

## Conclusion

SASU fills a gap in AI-assisted development: tools that let the human code while the AI validates. This is the natural inverse of current tools (Copilot, Aider, etc.) where AI codes and human validates.

Phase 1 delivers the core workflow. Phases 2-3 enhance with context and polish, but the MVP should prove the concept first.

**Next step**: Implement Phase 1 infrastructure and core workflow.
