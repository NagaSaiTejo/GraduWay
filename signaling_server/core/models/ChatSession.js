const mongoose = require('mongoose');

const chatSessionSchema = new mongoose.Schema({
  _id: { type: String, required: true },
  mentor: { type: Object, required: true }, // Simplified for now to match legacy behavior
  mentee: { type: Object, required: true },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('ChatSession', chatSessionSchema);
