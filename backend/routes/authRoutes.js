const express = require('express');
const bcrypt = require('bcryptjs');
const Student = require('../models/Student');
const Alumni = require('../models/Alumni');
const Admin = require('../models/Admin');
const { uploadStudentFiles, uploadProfileImage } = require('../middleware/upload');

const router = express.Router();

// Helper to build a full URL for uploaded files
const fileUrl = (req, filePath) =>
  filePath ? `http://127.0.0.1:5000/${filePath.replace(/\\/g, '/')}` : null;

// ─── Register Student ────────────────────────────────────────────────────────
router.post('/register/student', (req, res) => {
  uploadStudentFiles(req, res, async (err) => {
    if (err) {
      // Multer error (file too large or wrong type)
      return res.status(400).json({ message: err.message });
    }
    try {
      const { name, email, password, rollNumber, branch, currentYear, passingYear } = req.body;

      if (!name || !email || !password || !rollNumber || !branch || !currentYear) {
        return res.status(400).json({ message: 'All required fields must be filled.' });
      }

      const existingUser = await Student.findOne({ email });
      if (existingUser) return res.status(400).json({ message: 'Email already registered.' });

      // Frontend also validates size, but do a hard server-side check
      if (req.files?.profileImage?.[0] && req.files.profileImage[0].size > 2 * 1024 * 1024) {
        return res.status(400).json({ message: 'Profile image must be under 2 MB.' });
      }
      if (req.files?.resume?.[0] && req.files.resume[0].size > 5 * 1024 * 1024) {
        return res.status(400).json({ message: 'Resume must be under 5 MB.' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const profileImageUrl = req.files?.profileImage?.[0]
        ? fileUrl(req, `uploads/profiles/${req.files.profileImage[0].filename}`)
        : null;
      const resumeUrl = req.files?.resume?.[0]
        ? fileUrl(req, `uploads/resumes/${req.files.resume[0].filename}`)
        : null;

      const newStudent = new Student({
        name, email, password: hashedPassword, rollNumber, branch,
        currentYear: parseInt(currentYear), passingYear: passingYear ? parseInt(passingYear) : null,
        profileImageUrl, resumeUrl,
      });

      await newStudent.save();
      res.status(201).json({
        message: 'Student registered successfully',
        user: { id: newStudent._id, email, role: 'student' },
      });
    } catch (error) {
      res.status(500).json({ message: 'Server error', error: error.message });
    }
  });
});

// ─── Register Alumni ─────────────────────────────────────────────────────────
router.post('/register/alumni', (req, res) => {
  uploadProfileImage(req, res, async (err) => {
    if (err) return res.status(400).json({ message: err.message });
    try {
      const { name, email, password, passoutYear, branch, company, role } = req.body;

      if (!name || !email || !password || !passoutYear || !company || !role) {
        return res.status(400).json({ message: 'All required fields must be filled.' });
      }

      const existingUser = await Alumni.findOne({ email });
      if (existingUser) return res.status(400).json({ message: 'Email already registered.' });

      if (req.file && req.file.size > 2 * 1024 * 1024) {
        return res.status(400).json({ message: 'Profile image must be under 2 MB.' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const profileImageUrl = req.file
        ? fileUrl(req, `uploads/profiles/${req.file.filename}`)
        : null;

      const newAlumni = new Alumni({
        name, email, password: hashedPassword,
        passoutYear: parseInt(passoutYear),
        branch: branch || 'CSE',
        company, role, profileImageUrl,
      });

      await newAlumni.save();
      res.status(201).json({
        message: 'Alumni registered successfully',
        user: { id: newAlumni._id, email, role: 'alumni' },
      });
    } catch (error) {
      res.status(500).json({ message: 'Server error', error: error.message });
    }
  });
});

// ─── Register Admin ──────────────────────────────────────────────────────────
router.post('/register/admin', (req, res) => {
  uploadProfileImage(req, res, async (err) => {
    if (err) return res.status(400).json({ message: err.message });
    try {
      const { name, email, password, adminCode } = req.body;

      const SECRET_ADMIN_CODE = 'GRADUWAY_SECURE_KEY';
      if (adminCode !== SECRET_ADMIN_CODE) {
        return res.status(403).json({ message: 'Invalid Admin Verification Code.' });
      }

      const existingUser = await Admin.findOne({ email });
      if (existingUser) return res.status(400).json({ message: 'Email already registered.' });

      if (req.file && req.file.size > 2 * 1024 * 1024) {
        return res.status(400).json({ message: 'Profile image must be under 2 MB.' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const profileImageUrl = req.file
        ? fileUrl(req, `uploads/profiles/${req.file.filename}`)
        : null;

      const newAdmin = new Admin({ name, email, password: hashedPassword, profileImageUrl });

      await newAdmin.save();
      res.status(201).json({
        message: 'Admin registered successfully',
        user: { id: newAdmin._id, email, role: 'admin' },
      });
    } catch (error) {
      res.status(500).json({ message: 'Server error', error: error.message });
    }
  });
});

// ─── Login (All Roles) ───────────────────────────────────────────────────────
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required.' });
    }

    // Search all three collections
    let user = await Student.findOne({ email });
    let role = 'student';

    if (!user) {
      user = await Alumni.findOne({ email });
      role = 'alumni';
    }
    if (!user) {
      user = await Admin.findOne({ email });
      role = 'admin';
    }

    if (!user) {
      return res.status(404).json({ message: 'No account found with this email.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Incorrect password.' });
    }

    res.status(200).json({
      message: 'Login successful',
      role,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        profileImageUrl: user.profileImageUrl ?? null,
        // Student specific
        branch: user.branch ?? null,
        currentYear: user.currentYear ?? null,
        rollNumber: user.rollNumber ?? null,
        // Alumni specific
        company: user.company ?? null,
        jobRole: user.role ?? null,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
