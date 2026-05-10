require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');

// Initialize app
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Serve static files from uploads folder
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Database Connection
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log('Successfully connected to MongoDB!'))
  .catch((err) => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  });

// Routes
const authRoutes = require('./routes/authRoutes');
const roadmapRoutes = require('./routes/roadmapRoutes');
const messageRoutes = require('./routes/messageRoutes');
app.use('/api/auth', authRoutes);
app.use('/api/roadmap', roadmapRoutes);
app.use('/api/messages', messageRoutes);

// Health Check
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'Backend is running' });
});

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
