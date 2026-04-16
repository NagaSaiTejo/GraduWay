const express = require('express');
const router = express.Router();
const mentorshipController = require('../controllers/mentorshipController');

router.get('/mentor/:mentorId', mentorshipController.getMentorRequests);
router.put('/:id/status', mentorshipController.updateStatus);
router.get('/dashboard/:mentorId', mentorshipController.getDashboardSummary);

module.exports = router;
