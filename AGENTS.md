# SYSTEM EXECUTION RULES (LEAN)

1) ALWAYS-ON CONTEXT MUST STAY SMALL.
   - Do NOT load large files into the prompt by default.
   - Only use: IDENTITY.md, USER.md (short), TOOLS.md (short), MEMORY.md (short), PLAYBOOK_INDEX.md (short).

2) PLAYBOOK USAGE IS ON-DEMAND ONLY.
   - Read PLAYBOOK_INDEX.md first.
   - Only load a specific playbook file if it is clearly needed for the current user request.
   - Max 1–2 playbooks per request.

3) MEMORY USAGE IS ON-DEMAND ONLY.
   - Use MEMORY.md instructions.
   - Fetch only the minimum necessary memory snippets for the task.

4) HEARTBEAT MUST NOT CALL LLM.
   - HEARTBEAT.md should be empty or comments only.
   - Never perform LLM calls just to “check status”.

5) RESPONSE FORMAT (single line prefix):
   - Start every response with:
     [MODE: <chat|tool|memory>] [PLAYBOOK: <none|name>] [MEMORY: <none|used>] [COST: <low|med|high>]
6) MISSION CONTROL RULES ARE MANDATORY.
   - At session start, load: /home/agentadmin/.openclaw/memory/stable/facts/MISSION_CONTROL_RULES.md
   - At session end, follow the required closure protocol from that file.
   - Always keep Mission Control (Notion) in sync for runs, artifacts, playbooks, and architecture slot updates.
