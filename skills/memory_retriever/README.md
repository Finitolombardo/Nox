# Memory Retriever Skill

## Overview
This skill retrieves memory snippets based on user input while ensuring token efficiency.

## Usage
You can run the script as follows:
```bash
sh run.sh --q "your query here" [--proof]
```

### Example
To retrieve memory related to cron:
```bash
sh run.sh --q "cron heartbeat" --proof
```

## Integration
Always run this skill first for technical questions to retrieve the most relevant memory snippets.

## Notes
- The script provides structured output, whether a match is found or not.
- If using the proof flag, it will display the executed command and the first 30 lines of the output.