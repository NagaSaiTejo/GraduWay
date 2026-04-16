const Alumni = require('../models/Alumni');
const User = require('../../core/models/User');

exports.getProfile = async (req, res) => {
    try {
        const { userId } = req.params;
        const alumni = await Alumni.findOne({ userId });
        if (!alumni) return res.status(404).json({ message: 'Alumni profile not found' });
        res.status(200).json(alumni);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.updateProfile = async (req, res) => {
    try {
        const { userId } = req.params;
        const updateData = req.body;
        
        let alumni = await Alumni.findOneAndUpdate(
            { userId },
            { $set: updateData },
            { new: true, upsert: true }
        );
        
        res.status(200).json(alumni);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.submitVerification = async (req, res) => {
    try {
        const { userId } = req.params;
        const alumni = await Alumni.findOneAndUpdate(
            { userId },
            { $set: { verificationStatus: 'pending' } },
            { new: true }
        );
        res.status(200).json(alumni);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
