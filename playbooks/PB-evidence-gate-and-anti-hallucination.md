# PB-evidence-gate-and-anti-hallucination.md

## Rule 0 (hard)
Never claim WORKING/BROKEN without a test executed in THIS session.

## Required fields in every status update
- Integration name
- Test name
- Exact command/tool call
- Timestamp (UTC)
- Result: WORKING / BROKEN / UNVERIFIED
- Output snippet or exact error line

## Evidence Gate
1) Run at least one real quick-test.
2) Capture raw output snippet (no secrets).
3) If test cannot run, set UNVERIFIED and state exact blocker.
4) Only then update playbook status.

## Missing tool handling
If required tool is missing:
1) Verify runtime tool/skill availability (tool registry / CLI evidence).
2) Record blocker with command output.
3) Mark UNVERIFIED.
4) Ask user for required action (enable skill/auth/install credentials).

## Auto-update policy for integration playbooks
After each test, update the target playbook immediately with:
- Status
- Last checked (UTC)
- Test command/tool call
- Result/error snippet
Do not defer updates to later turns.

## Prohibited patterns
- No "should work" claims without test.
- No status inherited from old sessions without re-test.
- No environment/user-path assumptions without command evidence.
