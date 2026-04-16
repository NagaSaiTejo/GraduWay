const express = require('express');
const router = express.Router();
const chatController = require('../controllers/chatController');

router.post('/sessions', chatController.createOrGetSession);
router.get('/user/:userId', chatController.getUserSessions);
router.post('/:sessionId/messages', chatController.sendMessage);
router.get('/:sessionId/messages', chatController.getMessages);

module.exports = router;
