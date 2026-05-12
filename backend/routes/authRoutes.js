const express = require('express');
const bcrypt = require('bcryptjs');
const Student = require('../models/Student');
const Alumni = require('../models/Alumni');
const Admin = require('../models/Admin');
const { uploadStudentFiles, uploadProfileImage } = require('../middleware/upload');
const jwt = require('jsonwebtoken');
const { verifyToken, JWT_SECRET } = require('../middleware/auth');

const router = express.Router();

const allowedEmailDomains = new Set([
  'acet.ac.in',
  'aec.edu.in',
  'acoe.edu.in',
]);

const emailDomain = (email) => {
  if (!email || typeof email !== 'string') return null;
  const normalized = email.trim().toLowerCase();
  const atIndex = normalized.lastIndexOf('@');
  if (atIndex <= 0 || atIndex === normalized.length - 1) return null;
  return normalized.slice(atIndex + 1);
};

const hasAllowedEmailDomain = (email) => allowedEmailDomains.has(emailDomain(email));

// Helper to build a full URL for uploaded files
const fileUrl = (req, filePath) => {
  if (!filePath) return null;
  const normalizedPath = filePath.replace(/\\/g, '/');
  const configuredBase = process.env.PUBLIC_BASE_URL?.replace(/\/$/, '');
  const requestBase = `${req.protocol}://${req.get('host')}`;
  const base = configuredBase || requestBase;
  return `${base}/${normalizedPath}`;
};

const adminModelMap = {
  student: Student,
  alumni: Alumni,
  admin: Admin,
};

const normalizeRole = (role) => (role || '').toString().trim().toLowerCase();

const sanitizeUser = (user, role) => ({
  id: user._id,
  name: user.name,
  email: user.email,
  role,
  branch: user.branch ?? null,
  rollNumber: user.rollNumber ?? null,
  company: user.company ?? null,
  adminRole: user.role ?? null,
  isBanned: !!user.isBanned,
  createdAt: user.createdAt ?? null,
});

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
      if (!hasAllowedEmailDomain(email)) {
        return res.status(400).json({ message: 'Use your college email domain (@acet.ac.in, @aec.edu.in, or @acoe.edu.in).' });
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
      const profileImageUrl = req.uploadedToFirebase?.profileImageUrl
        || (req.files?.profileImage?.[0]
          ? fileUrl(req, `uploads/profiles/${req.files.profileImage[0].filename}`)
          : null);
      const resumeUrl = req.uploadedToFirebase?.resumeUrl
        || (req.files?.resume?.[0]
          ? fileUrl(req, `uploads/resumes/${req.files.resume[0].filename}`)
          : null);

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
      if (!hasAllowedEmailDomain(email)) {
        return res.status(400).json({ message: 'Use your college email domain (@acet.ac.in, @aec.edu.in, or @acoe.edu.in).' });
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
      const profileImageUrl = req.uploadedToFirebase?.profileImageUrl
        || (req.file
          ? fileUrl(req, `uploads/profiles/${req.file.filename}`)
          : null);

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

      if (!hasAllowedEmailDomain(email)) {
        return res.status(400).json({ message: 'Use your college email domain (@acet.ac.in, @aec.edu.in, or @acoe.edu.in).' });
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
      const profileImageUrl = req.uploadedToFirebase?.profileImageUrl
        || (req.file
          ? fileUrl(req, `uploads/profiles/${req.file.filename}`)
          : null);

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
  // Sanitize inputs — trim whitespace to prevent bypass via leading/trailing spaces
  const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : '';
  const password = typeof req.body.password === 'string' ? req.body.password.trim() : '';

  console.log('--- Login Attempt ---', email);
  try {
    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password are required.' });
    }
    if (!hasAllowedEmailDomain(email)) {
      return res.status(400).json({
        message: 'Use your registered college email domain (@acet.ac.in, @aec.edu.in, or @acoe.edu.in).',
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

    // Issue JWT — JWT_SECRET is required at startup (validated in middleware/auth.js).
    // Any signing error here is a genuine server misconfiguration and must NOT be swallowed.
    const token = jwt.sign(
      { id: user._id?.toString(), email: user.email, role },
      JWT_SECRET,
      { expiresIn: '7d' },
    );

    res.status(200).json({
      message: 'Login successful',
      role,
      token,
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

// ─── Admin Moderation ───────────────────────────────────────────────────────
router.get('/admin/users', async (req, res) => {
  try {
    const requestedRole = normalizeRole(req.query.role);
    const roles = requestedRole && requestedRole !== 'all'
      ? [requestedRole]
      : ['student', 'alumni'];

    const invalidRole = roles.find((r) => !adminModelMap[r]);
    if (invalidRole) {
      return res.status(400).json({ message: `Invalid role: ${invalidRole}` });
    }

    const results = await Promise.all(
      roles.map(async (role) => {
        const Model = adminModelMap[role];
        const docs = await Model.find({}).sort({ createdAt: -1 }).lean();
        return docs.map((doc) => sanitizeUser(doc, role));
      }),
    );

    return res.status(200).json({ users: results.flat() });
  } catch (error) {
    return res.status(500).json({ message: 'Server error', error: error.message });
  }
});

router.patch('/admin/users/:role/:id/ban', verifyToken, async (req, res) => {
  try {
    if (!req.user || req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Admin privileges required.' });
    }
    const role = normalizeRole(req.params.role);
    const Model = adminModelMap[role];
    if (!Model) {
      return res.status(400).json({ message: 'Invalid role.' });
    }

    const isBanned = req.body?.isBanned !== false;
    const updated = await Model.findByIdAndUpdate(
      req.params.id,
      {
        $set: {
          isBanned,
          bannedAt: isBanned ? new Date() : null,
        },
      },
      { new: true },
    ).lean();

    if (!updated) {
      return res.status(404).json({ message: 'User not found.' });
    }

    return res.status(200).json({
      message: isBanned ? 'User banned successfully.' : 'User unbanned successfully.',
      user: sanitizeUser(updated, role),
    });
  } catch (error) {
    return res.status(500).json({ message: 'Server error', error: error.message });
  }
});

router.delete('/admin/users/:role/:id', verifyToken, async (req, res) => {
  try {
    if (!req.user || req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Admin privileges required.' });
    }
    const role = normalizeRole(req.params.role);
    const Model = adminModelMap[role];
    if (!Model) {
      return res.status(400).json({ message: 'Invalid role.' });
    }

    const deleted = await Model.findByIdAndDelete(req.params.id).lean();
    if (!deleted) {
      return res.status(404).json({ message: 'User not found.' });
    }

    return res.status(200).json({ message: 'User removed successfully.' });
  } catch (error) {
    return res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;
