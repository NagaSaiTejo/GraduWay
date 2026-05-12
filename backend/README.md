Backend (Express + Mongoose) — README

Environment variables
- `PORT` — server port (default 5000)
- `MONGO_URI` — MongoDB connection string
- `ADMIN_REGISTRATION_CODE` — secret code to allow admin registration
- `PUBLIC_BASE_URL` — base URL used to build public file links (optional)
- `JWT_SECRET` — secret used to sign JWT tokens (set in production)
- `FIREBASE_BUCKET` — optional: enable Firebase Storage uploads when set
- `FIREBASE_SERVICE_ACCOUNT_JSON` — optional: JSON string of Firebase service account credentials (or rely on GOOGLE_APPLICATION_CREDENTIALS)

Quick commands
- Install dependencies: `npm install`
- Run tests: `npm test`
- Start server (development): `node server.js` or use `nodemon` if installed

Notes
- Uploads: the server will upload files to Firebase Storage when `FIREBASE_BUCKET` is configured. Otherwise files are stored on disk under `uploads/`.
- JWT: login endpoints now return a `token` field; admin-protected endpoints require a valid JWT with `role: 'admin'`.
