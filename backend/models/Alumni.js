const mongoose = require('mongoose');

const alumniSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  passoutYear: { type: Number, required: true },
  branch: { type: String, required: true },
  
  // Professional Data
  company: { type: String, required: true },
  role: { type: String, required: true },
  
  // Mentorship / Matchmaking Data
  techStack: [{ type: String }],
  industry: { type: String },
  linkedInUrl: { type: String },
  mentorshipTopics: [{ type: String }],
  bio: { type: String },
  
  profileImageUrl: { type: String },
  isVerified: { type: Boolean, default: false },
  isBanned: { type: Boolean, default: false },
  bannedAt: { type: Date, default: null },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Alumni', alumniSchema);
