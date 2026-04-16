const mongoose = require('mongoose');

const chatMessageSchema = new mongoose.Schema({
  sessionId: { type: String, ref: 'ChatSession', required: true },
  senderId: { type: String, required: true },
  text: { type: String, required: true },
  timestamp: { type: Date, default: Date.now },
  isSeen: { type: Boolean, default: false }
});

module.exports = mongoose.model('ChatMessage', chatMessageSchema);
