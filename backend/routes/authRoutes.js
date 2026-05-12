const express = require('express');
const bcrypt = require('bcryptjs');
const Student = require('../models/Student');
const Alumni = require('../models/Alumni');
const Admin = require('../models/Admin');
const { uploadStudentFiles, uploadProfileImage } = require('../middleware/upload');

const router = express.Router();

const allowedEmailDomains = new Set(['stud.com', 'alum.com', 'admin.com']);

const emailDomain = (email) => {
  if (!email || typeof email !== 'string') return null;
  const normalized = email.trim().toLowerCase();
  const atIndex = normalized.lastIndexOf('@');
  if (atIndex <= 0 || atIndex === normalized.length - 1) return null;
  return normalized.slice(atIndex + 1);
};

const hasAllowedEmailDomain = (email) => allowedEmailDomains.has(emailDomain(email));

// Helper to build a full URL for uploaded files
const fileUrl = (req, filePath) =>
  filePath ? `http://127.0.0.1:5000/${filePath.replace(/\\/g, '/')}` : null;

// Helper: check if an email is already used in ANY collection
const emailExistsAnywhere = async (email) => {
  const [s, a, ad] = await Promise.all([
    Student.findOne({ email }).lean(),
    Alumni.findOne({ email }).lean(),
    Admin.findOne({ email }).lean(),
  ]);
  if (s) return 'student';
  if (a) return 'alumni';
  if (ad) return 'admin';
  return null;
};

router.post('/register/student', (req, res) => {
  console.log('--- Student Registration Attempt ---');
  uploadStudentFiles(req, res, async (err) => {
    if (err) {
      return res.status(400).json({ message: err.message });
    }
    try {
      const { name, email, password, rollNumber, branch, currentYear, passingYear } = req.body;

      if (!name || !email || !password || !rollNumber || !branch || !currentYear) {
        return res.status(400).json({ message: 'All required fields must be filled.' });
      }
      if (!hasAllowedEmailDomain(email) || emailDomain(email) !== 'stud.com') {
        return res.status(400).json({ message: 'Student email must end with @stud.com.' });
      }

      // Check email uniqueness across ALL collections
      const existingRole = await emailExistsAnywhere(email);
      if (existingRole) {
        return res.status(400).json({
          message: `This email is already registered as a ${existingRole}. Please use a different email.`,
        });
      }

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
      console.log('Student registered successfully:', email);
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
  console.log('--- Alumni Registration Attempt ---');
  uploadProfileImage(req, res, async (err) => {
    if (err) return res.status(400).json({ message: err.message });
    try {
      const { name, email, password, passoutYear, branch, company, role } = req.body;

      if (!name || !email || !password || !passoutYear || !company || !role) {
        return res.status(400).json({ message: 'All required fields must be filled.' });
      }
      if (!hasAllowedEmailDomain(email) || emailDomain(email) !== 'alum.com') {
        return res.status(400).json({ message: 'Alumni email must end with @alum.com.' });
      }

      // Check email uniqueness across ALL collections
      const existingRole = await emailExistsAnywhere(email);
      if (existingRole) {
        return res.status(400).json({
          message: `This email is already registered as a ${existingRole}. Please use a different email.`,
        });
      }

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
      console.log('Alumni registered successfully:', email);
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
  console.log('--- Admin Registration Attempt ---');
  uploadProfileImage(req, res, async (err) => {
    if (err) return res.status(400).json({ message: err.message });
    try {
      const { name, email, password, adminCode } = req.body;

      if (!hasAllowedEmailDomain(email) || emailDomain(email) !== 'admin.com') {
        return res.status(400).json({ message: 'Admin email must end with @admin.com.' });
      }

      // SECURITY: Admin code is stored in environment variable, never hardcoded
      const ADMIN_REGISTRATION_CODE = process.env.ADMIN_REGISTRATION_CODE;
      if (!ADMIN_REGISTRATION_CODE) {
        return res.status(500).json({ message: 'Server configuration error: ADMIN_REGISTRATION_CODE not set.' });
      }
      if (adminCode !== ADMIN_REGISTRATION_CODE) {
        return res.status(403).json({ message: 'Invalid Admin Verification Code.' });
      }

      // Check email uniqueness across ALL collections
      const existingRole = await emailExistsAnywhere(email);
      if (existingRole) {
        return res.status(400).json({
          message: `This email is already registered as a ${existingRole}. Please use a different email.`,
        });
      }

      if (req.file && req.file.size > 2 * 1024 * 1024) {
        return res.status(400).json({ message: 'Profile image must be under 2 MB.' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);
      const profileImageUrl = req.file
        ? fileUrl(req, `uploads/profiles/${req.file.filename}`)
        : null;

      const newAdmin = new Admin({ name, email, password: hashedPassword, profileImageUrl });

      await newAdmin.save();
      console.log('Admin registered successfully:', email);
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
  console.log('--- Login Attempt ---', req.body.email);
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required.' });
    }
    if (!hasAllowedEmailDomain(email)) {
      return res.status(400).json({
        message: 'Use your registered college email domain (@stud.com, @alum.com, or @admin.com).',
      });
    }

    // Search ALL three collections simultaneously
    const [studentUser, alumniUser, adminUser] = await Promise.all([
      Student.findOne({ email }).lean(),
      Alumni.findOne({ email }).lean(),
      Admin.findOne({ email }).lean(),
    ]);

    // Build list of all matches (in case same email was registered in multiple roles)
    const matches = [];
    if (studentUser) matches.push({ user: studentUser, role: 'student' });
    if (alumniUser) matches.push({ user: alumniUser, role: 'alumni' });
    if (adminUser) matches.push({ user: adminUser, role: 'admin' });

    if (matches.length === 0) {
      return res.status(404).json({ message: 'No account found with this email.' });
    }

    // If same email registered in multiple roles (shouldn't happen with new checks,
    // but handle old data gracefully): try password against each match in order
    let matchedEntry = null;
    for (const entry of matches) {
      const isMatch = await bcrypt.compare(password, entry.user.password);
      if (isMatch) { matchedEntry = entry; break; }
    }

    if (!matchedEntry) {
      return res.status(401).json({ message: 'Incorrect password.' });
    }

    const { user, role } = matchedEntry;

    // Safely serialize roadmapProgress regardless of whether it's a Map, plain object, or undefined
    let roadmapProgressObj = {};
    try {
      if (user.roadmapProgress instanceof Map) {
        roadmapProgressObj = Object.fromEntries(user.roadmapProgress);
      } else if (user.roadmapProgress && typeof user.roadmapProgress === 'object') {
        roadmapProgressObj = user.roadmapProgress;
      }
    } catch (_) {
      roadmapProgressObj = {};
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
        activeRoadmap: user.activeRoadmap ?? null,
        roadmapProgress: roadmapProgressObj,
        // Alumni specific
        company: user.company ?? null,
        jobRole: user.role ?? null,
        passoutYear: user.passoutYear ?? null,
      },
    });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
