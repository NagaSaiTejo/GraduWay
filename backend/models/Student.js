const mongoose = require('mongoose');

const studentSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  rollNumber: { type: String, required: true },
  branch: { type: String, required: true },
  currentYear: { type: Number, required: true },
  passingYear: { type: Number },
  
  // AI Extracted Fields (populated later via Resume Upload)
  extractedSkills: [{ type: String }],
  careerInterests: [{ type: String }],
  targetRole: { type: String },
  resumeUrl: { type: String },
  profileImageUrl: { type: String },

  // Roadmap Tracking
  activeRoadmap: { type: String, default: null },
  roadmapProgress: { type: Map, of: Number, default: {} },

  // App usage stats
  careerScore: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Student', studentSchema);
