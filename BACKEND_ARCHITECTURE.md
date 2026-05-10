# GraduWay Backend Architecture

This document clarifies the relationship between the **Firebase/Google Cloud** and **Node.js/MongoDB** backends used in GraduWay. This dual-backend strategy is intentional and leverages the strengths of each platform.

## 1. Dual-Backend Strategy

GraduWay uses a hybrid architecture to ensure both real-time responsiveness and high-performance complex data management.

### Firebase (Google Cloud)
**Role**: Real-time Engine & Event-Driven Logic
- **Firestore**: Used for real-time messaging, Q&A notifications, and mentorship request status changes.
- **Cloud Functions**: Triggered by Firestore events to aggregate placement statistics, send push notifications, and manage weekly roadmap reminders.
- **Firebase Auth**: Provides secure social and email login across all platforms.
- **Firebase Storage**: Handles user profile photos and alumni verification documents.

### Node.js (OpenShift/Local)
**Role**: Primary Relational Data & Complex Workflows
- **Express API**: Handles student/alumni registration, roadmap step selection, and core profile data.
- **MongoDB**: The authoritative source for student progress, career interests, and the curated alumni directory.
- **Why Node.js?**: Allows for complex query logic and easier integration with potential college ERP systems in the future.

## 2. Data Synchronization

- **Authoritative Source**: The MongoDB database is the primary source for user profiles.
- **Triggers**: When a student updates their progress or an alumni verifies their profile in MongoDB, a background sync service (or Cloud Function) ensures the relevant fields are updated in Firestore to trigger real-time UI updates.
- **Real-time Interactions**: Any chat or Q&A interaction happens directly on Firestore for <100ms latency.

## 3. Future Scope

This architecture allows GraduWay to:
1. Scale the real-time chat horizontally via Firestore.
2. Maintain a flexible schema in MongoDB for rapidly evolving career roadmap features.
3. Migrate fully to either backend in the future if required, thanks to the repository pattern implemented in the Flutter `lib/providers` layer.
