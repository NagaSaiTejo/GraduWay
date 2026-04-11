const ChatSession = require('../models/ChatSession');
const ChatMessage = require('../models/ChatMessage');

exports.createOrGetSession = async (req, res) => {
  try {
    const { id, mentor, mentee } = req.body;
    let session = await ChatSession.findById(id);
    if (!session) {
      session = new ChatSession({ _id: id, mentor, mentee });
      await session.save();
    }
    res.status(200).json(session);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getUserSessions = async (req, res) => {
  try {
    const { userId } = req.params;
    const sessions = await ChatSession.find({
      $or: [{ 'mentor.id': userId }, { 'mentee.id': userId }]
    });
    res.status(200).json(sessions);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.sendMessage = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { id, senderId, text, timestamp } = req.body;
    
    const message = new ChatMessage({
      _id: id,
      sessionId,
      senderId,
      text,
      timestamp: timestamp || new Date()
    });
    
    await message.save();
    res.status(200).json(message);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getMessages = async (req, res) => {
  try {
    const { sessionId } = req.params;
    const messages = await ChatMessage.find({ sessionId }).sort({ timestamp: 1 });
    res.status(200).json(messages);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
