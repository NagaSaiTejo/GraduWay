// Unified Backend: WebRTC signaling + REST API
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const morgan = require('morgan');

const authRoutes = require('./routes/authRoutes');
const mentorshipRoutes = require('./routes/mentorshipRoutes');
const chatRoutes = require('./routes/chatRoutes');

const app = express();
const http = require('http').createServer(app);
const io = require('socket.io')(http, {
  cors: { origin: "*" }
});

// Middleware
app.use(cors());
app.use(morgan('dev'));
app.use(bodyParser.json());

// MongoDB Connection
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/alumni_app';
mongoose.connect(MONGODB_URI)
  .then(() => console.log('🍃 Connected to MongoDB'))
  .catch(err => console.error('❌ MongoDB Connection Error:', err));

// API Routes
app.use('/auth', authRoutes);
app.use('/api/mentorship', mentorshipRoutes);
app.use('/api/chats', chatRoutes);

// Root Health Check (Used by OpenShift Readiness/Liveness probes)
app.get('/', (req, res) => {
  const mongoStatus = mongoose.connection.readyState === 1 ? 'CONNECTED' : 'DISCONNECTED';
  res.status(mongoStatus === 'CONNECTED' ? 200 : 503).send({ 
    status: 'UP', 
    mongodb: mongoStatus,
    message: 'Alumni Signaling Server is running',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).send({ status: 'OK' });
});

const PORT = process.env.PORT || 3000;

// Only run Media Server locally if FFMPEG is available or explicitly requested
// For Render free tier, we focus strictly on P2P signaling to stay within limits
if (process.env.START_MEDIA_SERVER === 'true') {
  try {
    const nms = require('./media_server');
    nms.run();
    console.log('📺 Node Media Server started');
  } catch (err) {
    console.error('⚠️ Could not start Media Server:', err.message);
  }
}

// Track rooms: { roomId: { mentorSocketId, students: [socketId] } }
const rooms = {};

io.on('connection', (socket) => {
  console.log(`[CONNECT] User: ${socket.id}`);

  // Join Room: { roomId, role: 'mentor' | 'student' }
  socket.on('join-room', (data) => {
    const roomId = typeof data === 'string' ? data : data.roomId;
    const role   = typeof data === 'object' ? data.role : 'mentor';

    socket.join(roomId);
    socket.data.roomId = roomId;
    socket.data.role   = role;

    if (!rooms[roomId]) {
      rooms[roomId] = { mentorSocketId: null, students: [] };
    }

    if (role === 'mentor') {
      rooms[roomId].mentorSocketId = socket.id;
      console.log(`[ROOM] Mentor (${socket.id}) created: ${roomId}`);
    } else {
      if (!rooms[roomId].mentorSocketId) {
        socket.emit('error', { message: 'Mentor not in room yet' });
        return;
      }
      if (!rooms[roomId].students.includes(socket.id)) {
        rooms[roomId].students.push(socket.id);
      }
      console.log(`[ROOM] Student (${socket.id}) joined: ${roomId}`);

      // Notify mentor that a student joined
      io.to(rooms[roomId].mentorSocketId).emit('user-joined', socket.id);
    }
  });

  // Relay Offer: { target, offer }
  socket.on('offer', (data) => {
    io.to(data.target).emit('offer', { 
      offer: data.offer, 
      from: socket.id 
    });
  });

  // Relay Answer: { target, answer }
  socket.on('answer', (data) => {
    io.to(data.target).emit('answer', { 
      answer: data.answer, 
      from: socket.id 
    });
  });

  // Relay ICE Candidate: { target, candidate }
  socket.on('ice-candidate', (data) => {
    io.to(data.target).emit('ice-candidate', { 
      candidate: data.candidate, 
      from: socket.id 
    });
  });

  // Interaction Events
  socket.on('send-message', (data) => {
    io.to(data.roomId).emit('new-message', data);
  });

  socket.on('send-comment', (data) => {
    io.to(data.roomId).emit('new-comment', data);
  });

  socket.on('raise-hand', (data) => {
    socket.to(data.roomId).emit('user-raised-hand', data);
  });

  // Cleanup on disconnect
  socket.on('disconnecting', () => {
    const roomId = socket.data.roomId;
    if (roomId && rooms[roomId]) {
      if (socket.data.role === 'mentor') {
        socket.to(roomId).emit('mentor-left');
        delete rooms[roomId];
      } else {
        rooms[roomId].students = rooms[roomId].students.filter(id => id !== socket.id);
        socket.to(roomId).emit('user-left', socket.id);
      }
    }
  });
});

http.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Signaling Server ready on port ${PORT}`);
});

