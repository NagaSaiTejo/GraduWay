const mongoose = require('mongoose');

const studentSchema = new mongoose.Schema({
    userId: { type: String, required: true, unique: true }, // Links to the User 'id' field
    bio: { type: String },
    branch: { type: String },
    year: { type: String },
    skills: [{ type: String }],
    interests: [{ type: String }],
    socialLinks: {
        linkedin: { type: String },
        github: { type: String },
        portfolio: { type: String }
    }
}, { timestamps: true });

module.exports = mongoose.model('Student', studentSchema);
