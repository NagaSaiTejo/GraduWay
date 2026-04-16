const MentorshipRequest = require('../../core/models/MentorshipRequest');
const User = require('../../core/models/User');
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
        
        let student = await User.findOne({ id: studentId });
        if (!student && studentId) {
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
