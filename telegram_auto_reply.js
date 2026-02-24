const fs = require('fs');
const axios = require('axios');

const botToken = process.env.TELEGRAM_BOT_TOKEN;
if (!botToken) {
  throw new Error('Missing TELEGRAM_BOT_TOKEN environment variable');
}
const chatId = "7458143895";
let offset = 0;

setInterval(async () => {
    try {
        const response = await axios.get(`https://api.telegram.org/bot${botToken}/getUpdates?offset=${offset}`);
        const updates = response.data.result;

        for (const update of updates) {
            if (update.message) {
                const message = update.message;
                offset = update.update_id + 1; // Update the offset for the next response

                // Process audio messages
                if (message.voice) {
                    const audioFileId = message.voice.file_id;
                    const audioResponse = await axios.get(`https://api.telegram.org/bot${botToken}/getFile?file_id=${audioFileId}`);
                    // Handle transcription here
                }

                // Process image messages
                if (message.photo) {
                    const fileId = message.photo[message.photo.length - 1].file_id;
                    const imageResponse = await axios.get(`https://api.telegram.org/bot${botToken}/getFile?file_id=${fileId}`);
                    // Handle image analysis here
                }

                const replyText = `Received your message: ${message.text}`;
                await axios.post(`https://api.telegram.org/bot${botToken}/sendMessage`, {
                    chat_id: chatId,
                    text: replyText
                });
            }
        }
    } catch (error) {
        console.error('Error fetching updates:', error);
    }
}, 5000); // Adjust time as needed (5 seconds)