# MEMORY.md (LEAN, DURABLE, ANTI-BLOAT)

## CORE PRINCIPLE
- LLM context = CACHE (temporary).
- Files on disk = SOURCE OF TRUTH (durable).
- Telemetry/JSONL = DEBUG LOG ONLY. Never load telemetry into the prompt.

## MEMORY TYPES (DURABLE SIGNALS ONLY)
Only write durable memory when it changes future behavior:

1) FACT
   - Stable facts: paths, ports, hostnames, DB IDs, schema property names, service URLs.

2) DECISION
   - What we decided + why + date.

3) PLAYBOOK
   - Repeatable procedure with Preconditions + Steps + Verification.
   - Prefer saving as a file in /workspace/playbooks/ and only store a short index entry here.

4) INCIDENT
   - Symptom + root cause + fix + prevention.

5) CONFIG-KNOWN-GOOD (REDACTED)
   - Verified working config summary (no secrets). Full config stays in files, not in prompt.

## WHAT TO READ (ON-DEMAND)
Read memory only when required to be correct:
- Notion DB IDs, schema properties, status values, relations
- Capability/skills availability and quick tests
- Known-good infrastructure facts (ports/routes/services)
- Relevant playbook selection

When reading:
- Retrieve the smallest relevant snippet(s)
- Summarize to <= 200 tokens before reasoning
- Load max 1–2 playbooks per request

## NEVER DO THIS
- Never paste secrets/API keys into memory.
- Never dump full configs into prompts.
- Never load telemetry JSONL into context.
- Never “re-read everything” every message.

---

# DURABLE MAPS (MUST MAINTAIN)

## A) CAPABILITY MAP (Skills/Tools)
The agent must maintain a durable map of installed skills/tools.

Store for each skill/tool:
- name
- purpose (1 line)
- quick test (lightweight call, limit=1)
- common auth failure symptom + fix path
- related playbook path (if exists)

Update rules:
- When a new skill is installed/removed/configured -> update immediately as FACT/DECISION.
- When a tool fails due to auth -> log an INCIDENT and link the fix playbook.
- Do not assume a tool works because it worked yesterday.

## B) NOTION MAP (Schema + Workflow)
The agent must maintain a durable map of Notion.

Store:
- DB names + IDs
- key properties (name, type, allowed values)
- relations between DBs
- "Quest/Task workflow":
  - how to query open items
  - how to mark done
  - how to log completion

Update rules:
- If schema changes -> update the Notion Map immediately.
- Always reference exact property names as stored in Notion.

---

# SESSION START ROUTINE (LOW COST, MUST)
When the user starts a new session and says things like:
- "check meine notion"
- "hack deine quests in notion ab"
- "sync quests"
Do this flow:

1) QUICK CAPABILITY CHECK (no heavy file loads)
   - Verify the relevant tool(s) with a minimal test call (limit=1).
   - If auth fails: report tool + exact error + next fix step. Do not guess.

2) LOAD NOTION MAP (minimal snippet)
   - Identify Quest/Task DB + required properties + valid status values.

3) EXECUTE REQUEST
   - Query open quests/tasks
   - Update statuses as requested
   - Write a short durable log entry (DECISION/FACT) of what changed

Constraints:
- No telemetry in prompt.
- No full config loads.
- Max 1–2 playbooks per request.
- Keep response concise.

---

# WRITE FORMAT (STRICT)
Every durable write must include:
- Type: FACT / DECISION / PLAYBOOK / INCIDENT / CONFIG-KNOWN-GOOD
- One-line summary
- Evidence (short): file path / command output snippet / tool response ID (no secrets)
- Date: YYYY-MM-DD

## CAPABILITY MAP (SEED)

### Workspace Facts
- FACT: OpenClaw workspace path = /home/agentadmin/.openclaw/workspace (2026-02-25)
- FACT: Playbooks directory = /home/agentadmin/.openclaw/workspace/playbooks (2026-02-25)
- FACT: Standalone PB files exist in workspace root: PB-notion-dedup-by-title.md, PB-server-health-snapshot.md, PB-zombie-process-triage.md (2026-02-25)
- FACT: Skills directory = /home/agentadmin/.openclaw/workspace/skills (2026-02-25)
- FACT: Questboard directory = /home/agentadmin/.openclaw/workspace/questboard (2026-02-25)
- FACT: Memory directory (workspace) = /home/agentadmin/.openclaw/workspace/memory (2026-02-25)
- FACT: Heartbeat control file = /home/agentadmin/.openclaw/workspace/HEARTBEAT.md (keep empty to avoid periodic calls) (2026-02-25)

### Tool/Skill Inventory (to be maintained)
For each skill, maintain:
- name:
- purpose:
- quick test (limit=1):
- auth required (yes/no):
- common failure + fix:
- related playbook path:- PLAYBOOK: /home/agentadmin/.openclaw/workspace/playbooks/PB-mission-control-dashboard-ops.md (2026-02-26) - SOP for Mission Control, Gateway, Agents stability and recovery.
