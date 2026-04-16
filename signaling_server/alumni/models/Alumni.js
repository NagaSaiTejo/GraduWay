const mongoose = require('mongoose');

const alumniSchema = new mongoose.Schema({
    userId: { type: String, required: true, unique: true }, // Links to the User 'id' field
    bio: { type: String },
    techField: { type: String },
    company: { type: String },
    yoe: { type: String },
    skills: [{ type: String }],
    socialLinks: {
        linkedin: { type: String },
        github: { type: String },
        portfolio: { type: String }
    },
    verificationStatus: {
        type: String,
        enum: ['incomplete', 'pending', 'verified', 'rejected'],
        default: 'incomplete'
    }
}, { timestamps: true });

module.exports = mongoose.model('Alumni', alumniSchema);
