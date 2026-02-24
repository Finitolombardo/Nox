# PB-notion-dedup-by-title

## Definition:
- **Duplicate** = same quest title (trimmed, case-insensitive).

## Rules:
- Never delete tasks. Only archive duplicates.
- Always keep the user-owned task.
- If ownership is unknown: keep the one that is older OR has more content; archive the rest.
- Responsible assignment: for the kept user task, do not change Responsible unless explicitly instructed.

## Steps:
1. **BEFORE list**: 
   - Title, URL/ID
   - Responsible
   - Status
2. **Actions**: 
   - Specify which items were archived and the reasons why.
3. **AFTER list**: 
   - Same fields to prove changes.
4. **Save via memory pipeline**:
   - Record initial state in the staging area, then move to stable, followed by proof in the VAULT.