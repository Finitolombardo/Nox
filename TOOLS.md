# TOOLS (LEAN)

- Use tools only when needed.
- Prefer minimal tool calls.
- When using external services (Google/Notion/etc), verify auth errors and report the exact failing step.

Rules:
1) Never assume access works. If a tool returns auth/permission error, stop and report: tool name + error.
2) Do not read large files unless explicitly necessary.
3) For file retrieval: use PLAYBOOK_INDEX.md first, then load only the referenced file.