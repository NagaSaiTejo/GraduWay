const express = require('express');
const router = express.Router();
const mentorshipController = require('../controllers/mentorshipController');

router.post('/submit', mentorshipController.submitRequest);

module.exports = router;
