# Lessons Learned

## Root Cause Analysis
- Multiple syntax errors and assumptions led to script failures.
- Dependency on external tools like `jq` caused fragility.

## Anti-Patterns to Avoid
- Broken variable assignments leading to runtime errors.
- Hardcoded paths using `~` causing script failures when not executed in the right context.
- Including live outputs in hashes leading to frequent and unnecessary changes.
- Running cron jobs at inappropriate times (e.g. night).

## Correct Patterns to Use Instead
- Ensure shell variable assignments use correct syntax.
- Always use absolute paths in scripts and cron jobs.
- Check for required dependencies before execution (e.g. `command -v jq`).
- Design logs for stability and deduplication.

## Minimal Checklist for Future Shell Scripts
- Variable assignment rules: include no whitespace around `=`.
- Path correctness: use absolute paths, avoid `~` in cron.
- Dependency checks: use `command -v` to verify.
- Stable logging: design for deduplication.
- Safe file writes: check permissions before writing.

## Cron Schedule Rule
- Time-windowed checks, no 24/7 noise.
- Example:
   - Daily metrics at 07:10
   - Scan at 06:00, 09:00, 12:00, 15:00, 18:00, 21:00

