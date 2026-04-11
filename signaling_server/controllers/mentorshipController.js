const MentorshipRequest = require('../models/MentorshipRequest');
const User = require('../models/User');
const { v4: uuidv4 } = require('uuid');

// Helper to map to DTO format expected by Flutter app
const mapToDTO = (request) => {
    if (!request) return null;
    return {
        id: request.id,
        studentName: request.student ? request.student.name : 'Unknown Student',
        message: request.reason,
        status: request.status,
        createdAt: request.createdAt,
        updatedAt: request.updatedAt
    };
};

exports.submitRequest = async (req, res) => {
    try {
        const { id, reason, topics, preferredSchedule, studentId, mentorId } = req.body;
        
        // Find or create student/mentor
        let student = await User.findOne({ id: studentId });
        if (!student && studentId) {
            // Should usually exist, but handle demo case
            student = new User({ id: studentId, name: 'Demo Student', email: `${studentId}@demo.com` });
            await student.save();
        }

        const newRequest = new MentorshipRequest({
            id: id || uuidv4(),
            student: student ? student._id : null,
            mentor: mentorId ? (await User.findOne({ id: mentorId }))?._id : null,
            reason,
            topics,
            preferredSchedule,
            status: 'pending'
        });

        await newRequest.save();
        const populated = await MentorshipRequest.findById(newRequest._id).populate('student');
        res.status(201).json(mapToDTO(populated));
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.getMentorRequests = async (req, res) => {
    try {
        const { mentorId } = req.params;
        const { status } = req.query;
        
        const mentor = await User.findOne({ id: mentorId });
        if (!mentor) return res.status(404).json({ message: 'Mentor not found' });

        const query = { mentor: mentor._id };
        if (status) query.status = status;

        const requests = await MentorshipRequest.find(query)
            .populate('student')
            .sort({ createdAt: -1 });

        res.status(200).json(requests.map(mapToDTO));
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.updateStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { mentorId, status } = req.body;

        const request = await MentorshipRequest.findOne({ id }).populate('mentor');
        if (!request) return res.status(404).json({ message: 'Request not found' });

        if (!request.mentor || request.mentor.id !== mentorId) {
            return res.status(403).json({ message: 'Unauthorized mentor' });
        }

        if (request.status !== 'pending') {
            return res.status(400).json({ message: 'Can only update pending requests' });
        }

        request.status = status;
        await request.save();
        
        const updated = await MentorshipRequest.findById(request._id).populate('student');
        res.status(200).json(mapToDTO(updated));
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

exports.getDashboardSummary = async (req, res) => {
    try {
        const { mentorId } = req.params;
        const mentor = await User.findOne({ id: mentorId });
        if (!mentor) return res.status(404).json({ message: 'Mentor not found' });

        const pendingCount = await MentorshipRequest.countDocuments({ mentor: mentor._id, status: 'pending' });
        const acceptedCount = await MentorshipRequest.countDocuments({ mentor: mentor._id, status: 'accepted' });
        const rejectedCount = await MentorshipRequest.countDocuments({ mentor: mentor._id, status: 'rejected' });

        res.status(200).json({
            pendingCount,
            acceptedCount,
            rejectedCount
        });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
