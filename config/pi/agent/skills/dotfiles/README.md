# Dotfiles Skill

Pi skill for navigating Nix-based dotfiles.

## Philosophy: Documentation as Navigation, Not State

**This skill teaches *how to find* things, not *what's there*.**

The dotfiles repo changes frequently. To avoid documentation drift:

1. **Patterns over paths** - We document conventions, not every file
2. **Discovery over listing** - We teach `rg`, not static lists
3. **Auto-generated state** - `structure.md` is machine-generated
4. **Minimal core** - SKILL.md only covers stable concepts

## Files

| File | Purpose | Auto-Generated |
|------|---------|----------------|
| `SKILL.md` | Core navigation guide | ❌ Manual |
| `references/nix-patterns.md` | Reusable code patterns | ❌ Manual |
| `references/platform-notes.md` | Platform-specific quirks | ❌ Manual |
| `references/structure.md` | Full current structure | ✅ Yes |

## Maintenance

### After Major Restructures

```bash
# Verify documented paths still exist
./scripts/verify-structure.sh

# Regenerate auto-generated docs
./scripts/generate-structure.sh
```

### When Adding New Tools

**Don't update the skill immediately.** Instead:

1. Add the tool to your dotfiles first
2. Follow existing patterns (symlink from `config/`, define in `home/`)
3. Use `rg` to find it when needed
4. Only update the skill if it's a *new pattern*, not a new instance

### What's Worth Documenting

| Worth Documenting | Not Worth Documenting |
|-------------------|----------------------|
| "Configs live in `config/` and are symlinked" | Every config directory |
| "Use `home/common.nix` for shared tools" | Every shared package |
| "Themes are centralized in `lib/themes/`" | The 4 specific theme names |
| "NixOS uses niri, macOS uses aerospace" | Every keybinding |

## When This Skill is Wrong

**Trust the code, not this guide.**

If something seems off:
1. Check the actual files in `home/` and `config/`
2. Use `rg "tool-name" home/ config/` to find current location
3. Update the skill only if the *pattern* changed

## Testing

```bash
# Test skill loads
pi --skill . --no-skills "test"

# Verify structure
./scripts/verify-structure.sh
```
