const fs = require('fs');
const redactMessage = require('./redaction_function');
const approvalGate = require('./approval_gate');

// Read the configuration
const config = JSON.parse(fs.readFileSync('./telegram_config.json'));

// Simulate incoming message payload
const incomingMessage = { message: 'Please send sk-test-123 to John', intent: 'send email' };

// Apply routing based on config
const outputTopic = config.output_topic;

// Redaction
const redactedMessage = redactMessage(incomingMessage.message);

// Approval gate check
const approvalCheck = approvalGate(incomingMessage.intent);
if (approvalCheck) {
    console.log(approvalCheck);
} else {
    console.log(`Routing to ${outputTopic}: ${redactedMessage}`);
}