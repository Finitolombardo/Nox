# Playbook: Notion Deduplication by Title

## Definition
- **Duplicate** = same quest title (trimmed, case-insensitive).

## Rules
- **Never delete tasks.** Only archive duplicates.
- **Always keep the user-owned task.**
- If ownership is unknown: keep the one that is older OR has more content; archive the rest.
- **Responsible assignment:** for the kept user task, do not change Responsible unless explicitly instructed.

## Steps
1. **Identify duplicates:**
   - List all tasks with duplicate titles from the Notion database.

2. **BEFORE list:**  
   For each duplicate task:
   - Record the following fields:
     - **Title**  
     - **URL/ID**  
     - **Responsible**  
     - **Status**

3. **Archive duplicates:**  
   - For each identified duplicate, follow these conditions:
     - If the task is user-owned, keep it.
     - If ownership is unknown, compare ages/content and keep the appropriate one.
     - Archive the duplicates accordingly, noting the reason for archiving.

4. **AFTER list:**
   - For every kept task, list their updated information:
     - **Title**  
     - **URL/ID**  
     - **Responsible** (unchanged)  
     - **Status**  

5. **Documentation:**
   - Save the lists via the memory pipeline (staging -> stable -> VAULT proof)

## Sample Output

**BEFORE list:**
- Title: Sample Task 1, URL/ID: 1234, Responsible: UserA, Status: Active  
- Title: Sample Task 1, URL/ID: 5678, Responsible: UserB, Status: Inactive  

**AFTER list:**
- Title: Sample Task 1, URL/ID: 1234, Responsible: UserA, Status: Active

## Notes
- Ensure all tasks are reviewed properly to avoid accidental deletions.