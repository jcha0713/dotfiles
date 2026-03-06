# SASU Memory v0 — Manual Smoke Checklist (Milestone 5.3)

Date:
Operator:
Pi version:
SASU branch/commit:

## Prepared repos

- Fresh repo path:
- Existing repo path:

## Commands to run in each repo

1. `/sasu-memory-status`
2. `/sasu-memory-tail 20`
3. `/sasu-review smoke check intent`
4. While review is in-flight, run `/sasu-review` again (queue path)

---

## 5.3 Checklist

- [ ] Fresh repo: DB auto-creates
  - Evidence:
    - `.sasu/context.db` exists after first memory/review command
    - `/sasu-memory-status` reports non-error DB path and counts

- [ ] Existing repo: no crash/regression
  - Evidence:
    - Commands return successfully
    - Existing memory/session data remains readable

- [ ] No visible chat prompt spam regression
  - Evidence:
    - One request per command path (no duplicate spam blocks)
    - Busy-state follow-up behavior remains expected

- [ ] Memory commands produce useful output
  - Evidence:
    - `/sasu-memory-status` includes totals + event counts + state keys
    - `/sasu-memory-tail 20` prints meaningful recent events

---

## Fresh repo output capture

### `/sasu-memory-status`

```
(paste output)
```

### `/sasu-memory-tail 20`

```
(paste output)
```

### `/sasu-review smoke check intent`

```
(paste key chat/notification evidence)
```

### Busy follow-up `/sasu-review`

```
(paste key chat/notification evidence)
```

---

## Existing repo output capture

### `/sasu-memory-status`

```
(paste output)
```

### `/sasu-memory-tail 20`

```
(paste output)
```

### `/sasu-review smoke check intent`

```
(paste key chat/notification evidence)
```

### Busy follow-up `/sasu-review`

```
(paste key chat/notification evidence)
```

---

## Final verdict

- [ ] Milestone 5.3 PASS
- Notes / follow-up items:
