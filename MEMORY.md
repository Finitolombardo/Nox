# MEMORY ROUTER (LEAN)

Memory system exists outside Core. Use it ON-DEMAND.

Rule:
- By default, do not load memory.
- If task needs prior context, retrieve only the smallest relevant snippet.

Memory retrieval:
1) Identify topic (e.g. Notion schema, lead rotation, playbook usage).
2) Retrieve only the matching memory note(s).
3) Summarize into <= 200 tokens before using in reasoning.

Never paste secrets or API keys into memory.