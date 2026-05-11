import '../models/models.dart';

final List<PostModel> mockPosts = [
  PostModel(
    id: 'p001',
    alumniId: 'a001',
    alumniName: 'Ravi Kumar Reddy',
    alumniCompany: 'Amazon',
    alumniPhotoUrl: 'https://i.pravatar.cc/150?img=11',
    content:
        'Pro tip: For FAANG, solve 150 LeetCode problems (50 Easy, 80 Medium, 20 Hard) before applying. Quality over quantity — understand each solution deeply.',
    type: 'tip',
    tags: ['FAANG', 'DSA', 'LeetCode'],
    likes: 142,
    saves: 87,
    isAnonymous: false,
    postedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  PostModel(
    id: 'p002',
    alumniId: 'a002',
    alumniName: 'Priya Lakshmi Venkat',
    alumniCompany: 'Zoho',
    alumniPhotoUrl: 'https://i.pravatar.cc/150?img=5',
    content:
        'Zoho hiring insight: They care zero about your CGPA. They want to see real apps you built and deployed. Put your Play Store links on your resume.',
    type: 'advice',
    tags: ['Zoho', 'Placement', 'Tips'],
    likes: 98,
    saves: 54,
    isAnonymous: false,
    postedAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
  PostModel(
    id: 'p003',
    alumniId: 'a003',
    alumniName: 'Anonymous Alumni',
    alumniCompany: 'Top MNC',
    alumniPhotoUrl: 'https://i.pravatar.cc/150?img=8',
    content:
        'Honest truth: I got placed with a 6.8 CGPA and zero internships. What got me through was 1 real project with 500+ GitHub stars and solid DSA. Stop obsessing over marks.',
    type: 'confession',
    tags: ['Reality', 'CGPA', 'Placement'],
    likes: 234,
    saves: 156,
    isAnonymous: true,
    postedAt: DateTime.now().subtract(const Duration(days: 8)),
  ),
];

final List<QAModel> mockQA = [
  QAModel(
    id: 'q001',
    question:
        'Which is better for a CSE student targeting FAANG — Flutter or React Native for mobile projects in resume?',
    askedBy: 'Arjun Reddy',
    askedById: '21K81A0501',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    upvotes: 24,
    tags: ['Flutter', 'FAANG', 'Resume'],
    answers: [
      QAAnswer(
        id: 'ans001',
        alumniId: 'a001',
        alumniName: 'Ravi Kumar Reddy',
        alumniCompany: 'Amazon',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=11',
        answer:
            'For FAANG, the framework matters less than what you built with it. Flutter is great for cross-platform. But more importantly: build something people actually use, put it on Play Store, and highlight the engineering decisions you made — architecture, state management, performance. That is what FAANG interviewers probe.',
        isBestAnswer: true,
        upvotes: 18,
        answeredAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ],
    isAnswered: true,
  ),
  QAModel(
    id: 'q002',
    question:
        'How do I prepare for Zoho interview with only 3 months left? I am a 4th year student with basic DSA knowledge.',
    askedBy: 'Meena Kumari',
    askedById: '21K81A0502',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    upvotes: 31,
    tags: ['Zoho', 'Interview', 'Preparation'],
    answers: [
      QAAnswer(
        id: 'ans002',
        alumniId: 'a002',
        alumniName: 'Priya Lakshmi Venkat',
        alumniCompany: 'Zoho',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=5',
        answer:
            'Zoho 3-month plan: Month 1 — finish SQL fundamentals and build one real CRUD web app and deploy it. Month 2 — strengthen DSA basics (arrays, strings, trees). Month 3 — mock interviews and project polishing. Deploy everything to Vercel or Railway. Zoho interviewers will ask you to walk through your code line by line.',
        isBestAnswer: true,
        upvotes: 27,
        answeredAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
    isAnswered: true,
  ),
  QAModel(
    id: 'q003',
    question:
        'Is it worth doing AWS Cloud Practitioner certification in 2nd year or should I focus only on DSA?',
    askedBy: 'Vikram Rao',
    askedById: '22K81A0503',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    upvotes: 19,
    tags: ['AWS', 'Certification', 'DSA'],
    answers: [],
    isAnswered: false,
  ),
  QAModel(
    id: 'q004',
    question:
        'I am from MECH branch in 3rd year. Is it too late to switch to software? What should I start with?',
    askedBy: 'Suresh Babu',
    askedById: '22K81A0504',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    upvotes: 45,
    tags: ['Branch Switch', 'Software', 'Beginner'],
    answers: [
      QAAnswer(
        id: 'ans004',
        alumniId: 'a005',
        alumniName: 'Kiran Babu Naidu',
        alumniCompany: 'TCS Digital',
        alumniPhotoUrl: 'https://i.pravatar.cc/150?img=12',
        answer:
            'I switched from MECH to software — it is absolutely not too late in 3rd year. Start with Python (learn in 4 weeks via CS50P), then do Java + Spring Boot basics. Target TCS Digital or Infosys Systems Engineer roles. They specifically look for freshers who demonstrate initiative. Your MECH background is a differentiation, not a disadvantage — play it up.',
        isBestAnswer: true,
        upvotes: 38,
        answeredAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ],
    isAnswered: true,
  ),
  QAModel(
    id: 'q005',
    question:
        'What are the best open source projects to contribute to as a Flutter developer to get noticed by companies?',
    askedBy: 'Lakshmi Prasad',
    askedById: '23K81A0505',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    upvotes: 22,
    tags: ['Flutter', 'Open Source', 'GitHub'],
    answers: [],
    isAnswered: false,
  ),
];

final List<EventModel> mockEvents = [
  EventModel(
    id: 'e001',
    title:
        'FAANG Interview Masterclass: DSA Patterns That Actually Get You Hired',
    description:
        'Ravi walks through the exact 15 DSA patterns that cover 80% of FAANG interview questions. Live coding, Q&A, and real rejection stories.',
    hostAlumniName: 'Ravi Kumar Reddy',
    hostCompany: 'Amazon',
    eventDate: DateTime.now().add(const Duration(days: 5)),
    type: 'webinar',
    registeredCount: 134,
    isRsvped: false,
  ),
  EventModel(
    id: 'e002',
    title: 'Zoho Product Engineer Hiring: What They Really Look For',
    description:
        'Priya shares the inside hiring process at Zoho, what projects impressed the panel, and how to demonstrate product thinking as a fresher.',
    hostAlumniName: 'Priya Lakshmi Venkat',
    hostCompany: 'Zoho',
    eventDate: DateTime.now().add(const Duration(days: 12)),
    type: 'career_talk',
    registeredCount: 89,
    isRsvped: true,
  ),
  EventModel(
    id: 'e003',
    title: 'MECH to Software Switch: A Realistic 6-Month Plan',
    description:
        'Kiran Babu shares his exact roadmap for switching from MECH to TCS Digital, including what to study, how to frame your resume, and what companies actually hire branch switchers.',
    hostAlumniName: 'Kiran Babu Naidu',
    hostCompany: 'TCS Digital',
    eventDate: DateTime.now().add(const Duration(days: 18)),
    type: 'workshop',
    registeredCount: 67,
    isRsvped: false,
  ),
  EventModel(
    id: 'e004',
    title: 'Mock Interview Session: System Design for Mid-Level Roles',
    description:
        'Ajay Kumar runs live mock system design interviews. 4 slots available for students. Must register early. Feedback provided.',
    hostAlumniName: 'Ajay Kumar Thota',
    hostCompany: 'Microsoft',
    eventDate: DateTime.now().add(const Duration(days: 25)),
    type: 'mockinterview',
    registeredCount: 28,
    isRsvped: false,
  ),
];

final List<BadgeModel> mockBadges = [
  const BadgeModel(
      id: 'b001',
      title: 'First Connect',
      description: 'Viewed your first alumni profile',
      icon: '🤝',
      isEarned: false,
      category: 'networking'),
  const BadgeModel(
      id: 'b002',
      title: 'Curious Mind',
      description: 'Asked your first question in Q&A',
      icon: '❓',
      isEarned: false,
      category: 'learning'),
  const BadgeModel(
      id: 'b003',
      title: 'Skill Seeker',
      description: 'Set your target career goal',
      icon: '🎯',
      isEarned: false,
      category: 'roadmap'),
  const BadgeModel(
      id: 'b004',
      title: 'Event Goer',
      description: 'RSVPed to your first event',
      icon: '🎓',
      isEarned: false,
      category: 'events'),
  const BadgeModel(
      id: 'b005',
      title: 'Early Bird',
      description: 'Joined GraduWay in first 100 students',
      icon: '🌅',
      isEarned: false,
      category: 'special'),
  const BadgeModel(
      id: 'b006',
      title: 'Road Warrior',
      description: 'Completed first roadmap milestone',
      icon: '🏁',
      isEarned: false,
      category: 'roadmap'),
  const BadgeModel(
      id: 'b007',
      title: 'Network Builder',
      description: 'Viewed 5 different alumni profiles',
      icon: '🌐',
      isEarned: false,
      category: 'networking'),
  const BadgeModel(
      id: 'b008',
      title: 'Community Hero',
      description: 'Asked 5 questions in Q&A',
      icon: '💬',
      isEarned: false,
      category: 'learning'),
  const BadgeModel(
      id: 'b009',
      title: 'Goal Setter',
      description: 'Completed your full profile with bio',
      icon: '🏁',
      isEarned: false,
      category: 'profile'),
  const BadgeModel(
      id: 'b010',
      title: 'Placement Ready',
      description: 'Reached Career Score of 50+',
      icon: '🚀',
      isEarned: false,
      category: 'achievement'),
];

final Map<String, List<Map<String, dynamic>>> skillPackageData = {
  'CSE': [
    {'skill': 'Flutter + Firebase', 'minPkg': 6.0, 'maxPkg': 22.0, 'count': 28},
    {'skill': 'Full Stack (MERN)', 'minPkg': 5.5, 'maxPkg': 18.0, 'count': 34},
    {'skill': 'DSA + CP', 'minPkg': 8.0, 'maxPkg': 45.0, 'count': 22},
    {'skill': 'AWS Cloud', 'minPkg': 7.0, 'maxPkg': 28.0, 'count': 19},
    {'skill': 'Data Science', 'minPkg': 6.0, 'maxPkg': 20.0, 'count': 15},
    {'skill': 'ServiceNow', 'minPkg': 5.5, 'maxPkg': 12.0, 'count': 31},
  ],
  'ECE': [
    {'skill': 'Embedded Systems', 'minPkg': 4.5, 'maxPkg': 14.0, 'count': 18},
    {'skill': 'Python + ML', 'minPkg': 5.0, 'maxPkg': 16.0, 'count': 12},
    {'skill': 'VLSI Design', 'minPkg': 6.0, 'maxPkg': 18.0, 'count': 9},
    {'skill': 'Full Stack Switch', 'minPkg': 5.5, 'maxPkg': 22.0, 'count': 14},
    {'skill': 'DSP + Signal', 'minPkg': 5.0, 'maxPkg': 12.0, 'count': 8},
  ],
  'MECH': [
    {'skill': 'CAD/CAM', 'minPkg': 3.5, 'maxPkg': 8.0, 'count': 22},
    {'skill': 'Python Switch', 'minPkg': 5.0, 'maxPkg': 14.0, 'count': 11},
    {'skill': 'AutoCAD', 'minPkg': 3.0, 'maxPkg': 7.5, 'count': 18},
    {'skill': 'Manufacturing', 'minPkg': 3.5, 'maxPkg': 9.0, 'count': 25},
    {'skill': 'Java Switch', 'minPkg': 4.5, 'maxPkg': 12.0, 'count': 8},
  ],
};
