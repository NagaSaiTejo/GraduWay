const mongoose = require('mongoose');

const adminSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, default: 'Moderator' }, // Super Admin, Moderator
  profileImageUrl: { type: String },
  isBanned: { type: Boolean, default: false },
  bannedAt: { type: Date, default: null },
  
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Admin', adminSchema);
