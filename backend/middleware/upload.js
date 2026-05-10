const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure directories exist
const profilesDir = path.join(__dirname, '../uploads/profiles');
const resumesDir = path.join(__dirname, '../uploads/resumes');
if (!fs.existsSync(profilesDir)) fs.mkdirSync(profilesDir, { recursive: true });
if (!fs.existsSync(resumesDir)) fs.mkdirSync(resumesDir, { recursive: true });

// ─── Storage Engine ─────────────────────────────────────────────────────────
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    if (file.fieldname === 'resume') {
      cb(null, resumesDir);
    } else {
      cb(null, profilesDir);
    }
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  },
});

// ─── File Type Filter ────────────────────────────────────────────────────────
const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();

  if (file.fieldname === 'resume') {
    // Accept if MIME is PDF or extension is .pdf
    if (file.mimetype === 'application/pdf' || ext === '.pdf') {
      cb(null, true);
    } else {
      cb(new Error('Resume must be a PDF file.'), false);
    }
  } else if (file.fieldname === 'profileImage') {
    // Accept if MIME starts with image/ OR extension is a known image type
    const imageExts = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    if (file.mimetype.startsWith('image/') || imageExts.includes(ext)) {
      cb(null, true);
    } else {
      cb(new Error('Profile picture must be an image file (JPG, PNG, etc.).'), false);
    }
  } else {
    cb(new Error('Unknown file field.'), false);
  }
};

// ─── Limits ──────────────────────────────────────────────────────────────────
// Profile image: max 2MB
// Resume:        max 5MB
const uploadLimits = (fieldname) => ({
  fileSize: fieldname === 'resume' ? 5 * 1024 * 1024 : 2 * 1024 * 1024, // 5MB / 2MB
});

// ─── Multer instances ────────────────────────────────────────────────────────

// For routes that only accept a profile image
const uploadProfileImage = multer({
  storage,
  fileFilter,
  limits: { fileSize: 2 * 1024 * 1024 }, // 2MB
}).single('profileImage');

// For student registration: accepts both profile image + resume
const uploadStudentFiles = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB outer limit (per file checked inside filter)
}).fields([
  { name: 'profileImage', maxCount: 1 },
  { name: 'resume', maxCount: 1 },
]);

module.exports = { uploadProfileImage, uploadStudentFiles };
