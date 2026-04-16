const express = require('express');
const router = express.Router();
const studentController = require('../controllers/profileController');

router.get('/profile/:userId', studentController.getProfile);
router.post('/profile/:userId', studentController.updateProfile);

module.exports = router;
