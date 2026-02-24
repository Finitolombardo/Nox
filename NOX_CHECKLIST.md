# NOX Execution Checklist (Preflight → Execute → Verify)

Use this checklist for every non-trivial task.

## 0) Task Framing (Leverage Gate)
- [ ] What is the real outcome (not just activity)?
- [ ] Which metric moves most: **Business / Health / Relationships**?
- [ ] Is this the highest-leverage next action?

## 1) Preflight (Before any command/API call)
- [ ] Read relevant playbooks/docs (`.md`) first; do not guess commands.
- [ ] Confirm scope, constraints, and success criteria.
- [ ] Inspect current state first (**read before write**).
- [ ] For API calls: validate payload structure (JSON/schema) before sending.
- [ ] Define rollback/safe fallback if change fails.

## 2) Execution Discipline
- [ ] Run smallest safe step first.
- [ ] Capture raw outputs and exit codes.
- [ ] If failure (exit code > 0): stop success claims immediately.
- [ ] On repeated failures: apply backoff; no blind retry spam.
- [ ] If loops/cost/time spikes: halt and escalate with telemetry.

## 3) Truth Verification (Mandatory)
- [ ] Verify objective evidence of success (not assumptions).
- [ ] Confirm exit code `0` for commands claimed successful.
- [ ] Validate resulting state matches requested outcome.
- [ ] Document any partial success or unresolved risk explicitly.

## 4) Report Format (to user)
- [ ] What was done (facts only)
- [ ] What failed (if anything)
- [ ] Evidence (exit code/output/state)
- [ ] Next best action

## 5) Memory & Logging
- [ ] Log critical decisions/system-state changes to persistent memory (Notion when configured).
- [ ] Update local memory/docs for reusable lessons.

---

## Quick Response Templates

### Success
- Result: <outcome>
- Evidence: exit code `0`; <state/output proof>
- Risk: <none/known>
- Next: <recommended next step>

### Failure
- Result: failed at <step>
- Evidence: exit code `<code>`; error: `<raw message>`
- Containment: <what was stopped/rolled back>
- Next: <best corrective action>

### Partial
- Result: <what succeeded> / <what did not>
- Evidence: <proof>
- Risk: <impact>
- Next: <decision options>
