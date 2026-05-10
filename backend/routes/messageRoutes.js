const express = require('express');
const Message = require('../models/Message');
const Student = require('../models/Student');
const Alumni = require('../models/Alumni');
const router = express.Router();

// Get connection history (unique users someone has chatted with)
router.get('/connections/:email', async (req, res) => {
  try {
    const email = req.params.email;
    const messages = await Message.find({
      $or: [{ senderEmail: email }, { receiverEmail: email }]
    }).sort({ timestamp: -1 });

    // Extract unique connected emails
    const connectedEmails = new Set();
    messages.forEach(msg => {
      if (msg.senderEmail !== email) connectedEmails.add(msg.senderEmail);
      if (msg.receiverEmail !== email) connectedEmails.add(msg.receiverEmail);
    });

    const connections = Array.from(connectedEmails);
    
    // Fetch user details for these connections
    const users = [];
    for (const ce of connections) {
      let u = await Student.findOne({ email: ce }, 'name email profileImageUrl');
      if (!u) {
        u = await Alumni.findOne({ email: ce }, 'name email profileImageUrl company role');
      }
      if (u) {
        users.push({
          name: u.name,
          email: u.email,
          profileImageUrl: u.profileImageUrl,
          role: (u.company || u.role) ? 'alumni' : 'student'
        });
      } else {
        users.push({ name: 'Unknown User', email: ce, role: 'unknown' });
      }
    }

    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get messages between two users
router.get('/:email1/:email2', async (req, res) => {
  try {
    const { email1, email2 } = req.params;
    const messages = await Message.find({
      $or: [
        { senderEmail: email1, receiverEmail: email2 },
        { senderEmail: email2, receiverEmail: email1 }
      ]
    }).sort({ timestamp: 1 });
    
    res.status(200).json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Send a message
router.post('/send', async (req, res) => {
  try {
    const { senderEmail, receiverEmail, content } = req.body;
    if (!senderEmail || !receiverEmail || !content) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const newMessage = new Message({
      senderEmail,
      receiverEmail,
      content,
      timestamp: new Date()
    });
    await newMessage.save();

    res.status(201).json(newMessage);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
