# GraduWay — Alumni-Student Guidance Platform

A Flutter-based cross-platform application connecting Aditya Engineering College alumni with current students to accelerate placement outcomes through mentorship, skill sharing, and real-world insights.

## Architecture Overview

GraduWay uses a **deliberate hybrid cloud architecture** designed for resilience and real-time capability:

### Frontend
- **Flutter + Riverpod** — Cross-platform (iOS, Android, Web)
- GoRouter for declarative navigation
- Device Preview for responsive testing

### Backend Layer 1: Firebase (Real-time & Auth)
- **Firebase Auth** — OAuth2 email-based authentication with college email domain validation
- **Cloud Firestore** — Real-time Q&A, mentorship requests, notifications
- **Firebase Cloud Functions** — Placement analytics aggregation, Q&A notification triggers
- **Firebase Storage** — Profile images, resume PDFs

### Backend Layer 2: Node.js/Express + MongoDB (REST API)
- Handles: user registration, roadmap progress, messaging, ATS resume scanning
- Chosen for: complex relational queries, file upload processing (multer), REST endpoint flexibility
- MongoDB: user profiles, roadmap state, message history

### Why Dual Backend?
Firebase Firestore excels at real-time listeners (mentorship status, Q&A answers) but has limited complex querying. MongoDB handles relational data (user-roadmap-progress relationships) more efficiently. This is a standard enterprise hybrid pattern used by Swiggy, CRED, and similar scale apps.

### Data Flow
```
Flutter App
    │
    ├── Firebase Auth (login/register)
    ├── Firestore (real-time: Q&A, mentorship)  
    ├── Cloud Functions (analytics, notifications)
    └── Node.js REST API (profiles, roadmap, messages, ATS)
              │
              └── MongoDB Atlas
```

## Core Features

### For Students
- **Alumni Directory** — Search by company, skill, role, package with ratings
- **Mentorship** — Request mentorship from verified alumni, real-time status
- **Q&A Forum** — Ask placement/career questions, get verified alumni answers
- **Roadmap** — Personalized skill roadmaps with milestones and tier-based tests
- **Career Score** — Gamified metric tracking progress (questions, events, badges)
- **ATS Resume Scanner** — Gemini AI-powered resume vs JD analysis
- **Event Hub** — Alumni webinars, workshops, mock interviews

### For Alumni
- **Profile** — Showcase role, package, company, skills, hiring insights
- **Mentees** — Manage mentorship requests, track mentee progress
- **Contributions** — Post tips, confessions, career stories; answer Q&A

### For Admins
- **Moderation** — Review reported content, verify alumni, manage users
- **Analytics** — Placement rates by batch/branch, skill trends, company hires
- **Announcements** — College-wide placement news and event management

## Setup

### Prerequisites
- Flutter 3.16+
- Node.js 18+
- Firebase account
- MongoDB Atlas account

### Firebase Configuration
1. Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable: Authentication (Email), Firestore, Cloud Storage, Cloud Functions
3. Run `flutterfire configure --project=your-project-id`
4. Copy credentials from Firebase console

### Flutter Setup
```bash
# Clone the repository
git clone <repo-url>
cd GRADUWAY

# Install dependencies
flutter pub get

# Set Firebase API key via environment variable
flutter run --dart-define=FIREBASE_WEB_API_KEY=your_web_api_key

# Or for release build
flutter build apk --dart-define=FIREBASE_WEB_API_KEY=your_web_api_key
```

### Backend Setup
```bash
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Configure environment variables
# MONGODB_URI=mongodb+srv://user:pass@cluster.mongodb.net/graduway
# JWT_SECRET=your_jwt_secret_key
# ADMIN_REGISTRATION_CODE=your_secure_admin_code
# FIREBASE_PROJECT_ID=your_firebase_project_id
# GEMINI_API_KEY=your_gemini_api_key

# Start server
npm start
# Server runs on http://localhost:5000
```

### Firebase Cloud Functions
```bash
cd functions

# Install dependencies
npm install

# Deploy functions
firebase deploy --only functions
```

## Project Structure

```
lib/
├── app.dart                  # Main app configuration
├── main.dart                 # Entry point
├── firebase_options.dart     # Firebase configuration
├── core/                     # Core utilities
│   ├── constants/
│   ├── multi_college_config.dart  # Phase 3: Multi-college
│   └── theme/
├── data/
│   ├── models/              # Data models (AlumniModel, StudentModel, etc.)
│   └── mock/                # Seed data for development
├── providers/               # Riverpod state management
│   ├── app_providers.dart
│   ├── firestore_providers.dart
│   └── auth_providers.dart
├── screens/                 # Feature screens by role
│   ├── auth/                # Login, registration
│   ├── student/             # Student dashboard, roadmap, ATS
│   ├── alumni/              # Alumni profile, mentorship
│   ├── admin/               # Moderation, analytics
│   └── shared/              # Q&A, events, messaging
├── services/                # External service integrations
│   ├── firebase_service.dart
│   ├── api_service.dart
│   ├── ai_service.dart      # Phase 2: AI features
│   └── webrtc_service.dart  # Phase 2: Video mentorship
├── routing/                 # GoRouter navigation
├── theme/                   # Colors, typography, styles
└── utils/                   # Helpers, validators, extensions

backend/
├── server.js                # Express server
├── routes/                  # API endpoints
│   ├── authRoutes.js
│   ├── roadmapRoutes.js
│   ├── messageRoutes.js
│   └── atsRoutes.js
├── models/                  # Mongoose schemas
│   ├── Student.js
│   ├── Alumni.js
│   ├── Admin.js
│   └── Message.js
├── middleware/              # Auth, file upload
└── scratch/                 # Testing utilities

functions/
├── index.js                 # Cloud Function triggers
├── placement_stats.js       # Analytics aggregation
└── notifications.js         # Event-driven alerts
```

## Security

### API Keys & Secrets
- **Firebase API keys** → Injected via `flutter run --dart-define=FIREBASE_WEB_API_KEY=...` (never hardcoded)
- **Admin registration code** → Environment variable `ADMIN_REGISTRATION_CODE` (server-side only)
- **JWT secret** → Environment variable `JWT_SECRET` (Node.js backend)
- **Gemini API key** → Environment variable `GEMINI_API_KEY` (server-side only)

### File Uploads
- Server-side MIME type validation (only PDF, JPG, PNG allowed)
- File size limits: Profile images (2MB), Resumes (5MB)
- Cloud Storage signed URLs for secure access

### Authentication
- Firebase Auth primary → Email/password with college domain validation
- JWT fallback → Local MongoDB sessions for dev mode
- No sensitive data in SharedPreferences

## Features Specification

### Phase 1 (Current)
✅ Multi-role authentication (Student, Alumni, Admin)  
✅ Alumni directory with advanced search  
✅ Mentorship request + status tracking  
✅ Q&A forum with verified alumni answers  
✅ Roadmap with milestone tests (70% pass threshold)  
✅ Gamified career score system  
✅ ATS resume scanner (Gemini AI)  
✅ Event hub with RSVP  
✅ Real-time Firestore sync  

### Phase 2 (Roadmap)
🔜 AI-powered skill recommendations  
🔜 Smart mentorship matching (cosine similarity on skill vectors)  
🔜 Video mentorship with WebRTC + screen sharing  
🔜 Async video Q&A library  
🔜 Personalized career path builder  

### Phase 3 (Roadmap)
🔜 Multi-college data isolation (`CollegeConfig` architecture)  
🔜 ERP integration adapters  
🔜 Portable alumni profiles across colleges  
🔜 White-label SaaS deployment  

## API Endpoints

### Authentication
- `POST /api/auth/register` — Student/Alumni registration with profile
- `POST /api/auth/admin-register` — Admin registration (requires `ADMIN_REGISTRATION_CODE`)
- `POST /api/auth/login` — Email/password login
- `POST /api/auth/logout` — Clear session

### Roadmap
- `GET /api/roadmap/:studentId` — Fetch assigned roadmap
- `POST /api/roadmap/:studentId/select` — Select target role roadmap
- `POST /api/roadmap/:studentId/submit-test` — Submit milestone test
- `GET /api/roadmap/:studentId/progress` — Get completion percentage

### Messages
- `GET /api/messages/connections/:userId` — Connections list
- `GET /api/messages/:conversationId` — Message history
- `POST /api/messages` — Send message

### ATS
- `POST /api/ats/score` — Analyze resume vs job description
- Body: `{ resumeFile: File, jobDescription: string }`

### Analytics (Admin)
- `GET /api/admin/stats` — Placement statistics
- `GET /api/admin/reported` — Flagged content

## Testing

```bash
# Run unit tests for state management
flutter test test/provider_test.dart

# Run widget tests for UI flows
flutter test test/widget_test.dart

# Run all tests with coverage
flutter test --coverage
```

## Deployment

### Mobile (Android/iOS)
```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release
```

### Web
```bash
flutter build web --release
# Outputs to build/web — deploy to Firebase Hosting, Vercel, or Netlify
```

### Backend
```bash
cd backend

# Deploy to Railway, Render, or Heroku
npm run deploy
# Or manually:
# git push heroku main
```

## Roles & Permissions

- **Students**: Can search alumni, ask questions, view roadmaps, and participate in events.
- **Alumni**: Can mentor students, share experiences, and guide future graduates.
- **Admins**: Manage user verification, content moderation, and platform oversight.

## License

This project is part of Aditya Engineering College's technical initiative.

## Support

For issues, feature requests, or contributions:
- Open an issue on the GitHub repository
- Contact: graduway@aec.edu.in

---

*GraduWay — Bridging the Gap, Navigating the Future.*  
**Last Updated**: May 2026 | **Version**: 1.0.0
