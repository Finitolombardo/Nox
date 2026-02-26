# Playbook: Error Validation for API Calls

## Definition
Every API call must be proven with a debug log of the HTTP response code. 'Completed' without code is considered a failure.

## Rules
- **Mandatory debug logging**: Every API call must include the HTTP response code
- **No completion without proof**: 'Completed' is invalid without response code
- **Response code validation**: Only 200-299 are considered successful
- **Error handling**: All non-2xx codes must trigger immediate investigation
- **Truth protocol**: Never report success if response code is missing or invalid

## Steps
1. **Before API call**: Log the request URL, method, and headers
2. **After API call**: Capture and log the HTTP response code
3. **Validation**: Check if response code is in 200-299 range
4. **Error handling**: If code is missing or not 2xx, log error and stop execution
5. **Success reporting**: Only report 'Completed' if valid 2xx code is present

## Sample Implementation
```bash
# Before call
log "API Request: GET https://api.notion.com/v1/databases/{id}"

# Call
response=$(curl -s -w "%{http_code}" -o response.json "https://api.notion.com/v1/databases/{id}" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03")

# Extract code
http_code=$(echo "$response" | tail -n1)

# Validate
if [[ "$http_code" =~ ^2[0-9][0-9]$ ]]; then
  log "API Success: $http_code"
  # Process response.json
else
  log "API Error: $http_code - Operation failed"
  exit 1
fi
```

## Error Scenarios
- **Missing response code**: Treat as critical failure
- **4xx errors**: Invalid request, log details and stop
- **5xx errors**: Server error, retry with exponential backoff
- **Timeout**: Log timeout and retry

## Documentation
- Save all API calls with response codes in memory pipeline
- Include timestamps and request details
- Never omit response codes in any logs

## Notes
- This playbook prevents false success reporting
- Ensures technical truth in all operations
- Mandatory for all API integrations