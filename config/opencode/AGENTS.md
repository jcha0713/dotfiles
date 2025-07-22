# AGENTS.md - Development Guidelines

## Core Development Principles

### 1. Documentation-First Development

- **Always consult the latest official documentation** before implementing any library, framework, or language feature
- **Verify API usage** through official sources before writing code or providing technical guidance
- When in doubt about syntax, methods, or parameters, research first, implement second

### 2. Never Invent APIs or Syntax

- **Do not create non-existing functions, methods, or syntax** under any circumstances
- **When uncertain about implementation details, ASK** rather than guessing or inventing
- If documentation is unclear or conflicting, seek clarification before proceeding
- Better to pause for verification than to implement incorrectly

### 3. Test-Driven Development

- **Write tests before implementing features** as the default approach
- **Exceptions permitted only when:**
  - Initial setup requires more than 4 hours of configuration
  - Testing framework integration blocks development timeline
  - Third-party dependencies make testing impractical
- **After implementation, verify ALL functionality** (new and existing features work correctly)
- **Iterate until all tests pass** - no exceptions

### 4. Verification Protocol

Before any code commit:

- [ ] Documentation consulted and API usage verified
- [ ] No invented functions or syntax used
- [ ] Tests written and passing (or valid exception documented)
- [ ] Existing functionality confirmed working
- [ ] Any uncertainties resolved through clarification

## When in Doubt

**Stop. Ask. Verify. Then implement.**
