# Memory System Overview

## Purpose
This system is designed for token-efficient keyword-based retrieval of memories.

## Structure
1. **Core Rules**: Always loaded, max 400 lines.
2. **Project Notes**: Retrieved by relevance.
3. **Knowledge Base**: Retrieved by keyword matching.

## Scripts
- **add_note.sh**: Use this script to add a note to the SQLite database.
- **retrieve.sh**: Use this script to retrieve the top K notes from the database based on keywords.
- **verify.sh**: Use this to verify the memory schema and test note retrieval.

## Usage
### Add Note
```bash
sh add_note.sh --title "Your note title here" --tags "tag1,tag2" --text "Your note content here"
```

### Retrieve Notes
```bash
sh retrieve.sh --q "question text" --k <number_of_notes> --budget_chars <max_characters>
```

### Verification
Run the verification script:
```bash
sh verify.sh
```