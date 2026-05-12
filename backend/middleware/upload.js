const multer = require('multer');
const path = require('path');
const fs = require('fs');
let admin = null;
let firebaseBucket = null;
let firebaseEnabled = false;

// Optional Firebase Admin initialization (non-breaking fallback to disk storage)
try {
  if (process.env.FIREBASE_BUCKET) {
    admin = require('firebase-admin');
    if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
      const svc = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON);
      admin.initializeApp({ credential: admin.credential.cert(svc), storageBucket: process.env.FIREBASE_BUCKET });
    } else {
      // If GOOGLE_APPLICATION_CREDENTIALS is set in the environment to a file path,
      // firebase-admin will pick it up automatically.
      admin.initializeApp({ storageBucket: process.env.FIREBASE_BUCKET });
    }
    firebaseBucket = admin.storage().bucket();
    firebaseEnabled = true;
    console.log('Firebase Storage enabled for uploads.');
  }
} catch (e) {
  console.warn('Firebase Storage not initialized (optional). Continuing with disk storage.', e?.message || e);
}

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

// Helper: upload a local file to Firebase Storage and return a signed URL
const uploadToFirebase = async (localPath, destPath) => {
  if (!firebaseEnabled || !firebaseBucket) return null;
  try {
    await firebaseBucket.upload(localPath, { destination: destPath });
    const file = firebaseBucket.file(destPath);
    // Generate a long-lived signed URL (very far expiry)
    const [url] = await file.getSignedUrl({ action: 'read', expires: '2491-03-09' });
    return url;
  } catch (e) {
    console.warn('Firebase upload failed, falling back to disk URL:', e?.message || e);
    return null;
  }
};

// Wrap multer middlewares so we can optionally upload files to Firebase and
// attach resulting URLs on `req.uploadedToFirebase` while preserving disk copy.
const _profileMulter = multer({ storage, fileFilter, limits: { fileSize: 2 * 1024 * 1024 } });
const _studentMulter = multer({ storage, fileFilter, limits: { fileSize: 5 * 1024 * 1024 } });

const uploadProfileImage = (req, res, next) => {
  _profileMulter.single('profileImage')(req, res, async (err) => {
    if (err) return next(err);
    try {
      if (firebaseEnabled && req.file && req.file.path) {
        const dest = `profiles/${req.file.filename}`;
        const url = await uploadToFirebase(req.file.path, dest);
        req.uploadedToFirebase = req.uploadedToFirebase || {};
        if (url) req.uploadedToFirebase.profileImageUrl = url;
      }
      return next();
    } catch (e) {
      return next(e);
    }
  });
};

const uploadStudentFiles = (req, res, next) => {
  _studentMulter.fields([
    { name: 'profileImage', maxCount: 1 },
    { name: 'resume', maxCount: 1 },
  ])(req, res, async (err) => {
    if (err) return next(err);
    try {
      if (firebaseEnabled) {
        if (req.files?.profileImage?.[0]?.path) {
          const f = req.files.profileImage[0];
          const dest = `profiles/${f.filename}`;
          const url = await uploadToFirebase(f.path, dest);
          req.uploadedToFirebase = req.uploadedToFirebase || {};
          if (url) req.uploadedToFirebase.profileImageUrl = url;
        }
        if (req.files?.resume?.[0]?.path) {
          const r = req.files.resume[0];
          const dest = `resumes/${r.filename}`;
          const url = await uploadToFirebase(r.path, dest);
          req.uploadedToFirebase = req.uploadedToFirebase || {};
          if (url) req.uploadedToFirebase.resumeUrl = url;
        }
      }
      return next();
    } catch (e) {
      return next(e);
    }
  });
};

module.exports = { uploadProfileImage, uploadStudentFiles };
