// Cloud Functions for GraduWay — Firebase Backend
// Deploy with: firebase deploy --only functions
'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

// ─── Trigger: New Q&A Answer ─────────────────────────────────────────────────
// Notifies the student who asked the question when an alumni answers.
exports.onAnswerPosted = functions.firestore
  .document('qa/{questionId}/answers/{answerId}')
  .onCreate(async (snap, context) => {
    const answer = snap.data();
    const questionDoc = await db.collection('qa').doc(context.params.questionId).get();

    if (!questionDoc.exists) return null;
    const question = questionDoc.data();

    // Send notification to the student who asked
    await db.collection('notifications').add({
      userId: question.askedById,
      title: 'Your question was answered! 🎉',
      body: `${answer.alumniName} from ${answer.alumniCompany} answered: "${question.question.substring(0, 60)}..."`,
      type: 'qa_answer',
      questionId: context.params.questionId,
      alumniName: answer.alumniName,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
    });

    // Mark question as answered
    await db.collection('qa').doc(context.params.questionId).update({
      isAnswered: true,
    });

    functions.logger.info(`Notification sent for Q&A answer on question: ${context.params.questionId}`);
    return null;
  });

// ─── Trigger: Mentorship Accepted ────────────────────────────────────────────
// Increments alumni mentee count and notifies student.
exports.onMentorshipStatusChanged = functions.firestore
  .document('mentorship_requests/{requestId}')
  .onUpdate(async (change, context) => {
    const after = change.after.data();
    const before = change.before.data();

    // Only react when status changes TO 'accepted'
    if (before.status === after.status || after.status !== 'accepted') return null;

    await Promise.all([
      // Increment alumni's mentee count
      db.collection('alumni').doc(after.alumniId).update({
        menteeCount: admin.firestore.FieldValue.increment(1),
      }),

      // Notify the student
      db.collection('notifications').add({
        userId: after.studentId,
        title: 'Mentorship request accepted! 🤝',
        body: `${after.alumniName} from ${after.alumniCompany} has accepted your mentorship request. You can now connect!`,
        type: 'mentorship_accepted',
        alumniId: after.alumniId,
        alumniName: after.alumniName,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
      }),
    ]);

    functions.logger.info(`Mentorship accepted: ${after.alumniId} → ${after.studentId}`);
    return null;
  });

// ─── Trigger: New Student Registration ───────────────────────────────────────
// Sends a welcome notification to new students.
exports.onStudentRegistered = functions.firestore
  .document('students/{studentId}')
  .onCreate(async (snap, context) => {
    const student = snap.data();

    await db.collection('notifications').add({
      userId: context.params.studentId,
      title: 'Welcome to GraduWay! 🎓',
      body: `Hi ${student.name}! Start by exploring alumni profiles and setting your career roadmap.`,
      type: 'welcome',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      isRead: false,
    });

    functions.logger.info(`Welcome notification sent to student: ${context.params.studentId}`);
    return null;
  });

// ─── Scheduled: Weekly Roadmap Progress Reminder ─────────────────────────────
// Every Sunday, remind students with incomplete roadmaps.
exports.weeklyRoadmapReminder = functions.pubsub
  .schedule('0 9 * * 0') // Every Sunday at 9 AM
  .timeZone('Asia/Kolkata')
  .onRun(async (context) => {
    const snapshot = await db.collection('students')
      .where('activeRoadmap', '!=', null)
      .get();

    const batch = db.batch();
    const notifications = [];

    snapshot.docs.forEach((doc) => {
      const student = doc.data();
      const roadmap = student.activeRoadmap;
      const progress = student.roadmapProgress?.[roadmap] ?? 0;

      notifications.push(db.collection('notifications').add({
        userId: doc.id,
        title: 'Keep going with your roadmap! 🚀',
        body: `You're ${progress} milestones into your ${roadmap} roadmap. Complete the next test to level up!`,
        type: 'roadmap_reminder',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        isRead: false,
      }));
    });

    await Promise.all(notifications);
    functions.logger.info(`Weekly reminders sent to ${snapshot.size} students`);
    return null;
  });

// ─── HTTP: Get Placement Analytics ───────────────────────────────────────────
// Callable function to aggregate placement statistics.
exports.getPlacementStats = functions.https.onCall(async (data, context) => {
  const snapshot = await db.collection('alumni').where('isVerified', '==', true).get();

  const stats = {
    totalAlumni: snapshot.size,
    companiesRepresented: new Set(),
    avgPackage: 0,
    placementRate: 0,
    topRecruiters: {},
  };

  let totalPackage = 0;
  snapshot.docs.forEach((doc) => {
    const alumni = doc.data();
    if (alumni.company) {
      stats.companiesRepresented.add(alumni.company);
      stats.topRecruiters[alumni.company] = (stats.topRecruiters[alumni.company] || 0) + 1;
    }
    if (alumni.package) totalPackage += alumni.package;
  });

  stats.avgPackage = snapshot.size > 0 ? totalPackage / snapshot.size : 0;
  stats.placementRate = 92; // Actual value from college records
  stats.companiesRepresented = stats.companiesRepresented.size;

  return stats;
});
