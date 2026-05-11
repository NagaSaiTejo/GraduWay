import '../models/alumni_model.dart';

const List<AlumniModel> mockAlumni = [
  AlumniModel(
    id: 'a001',
    name: 'Ravi Kumar Reddy',
    batch: '2022',
    branch: 'CSE',
    company: 'Amazon',
    role: 'Software Development Engineer',
    location: 'Hyderabad',
    package: 18.0,
    skills: ['Flutter', 'Dart', 'AWS', 'System Design', 'DSA'],
    photoUrl: 'https://i.pravatar.cc/150?img=11',
    advice:
        'Start DSA from 2nd year. Build real projects, not tutorial clones. Your GitHub is your resume.',
    story:
        'Got rejected by 12 companies before Amazon. Each rejection taught me something. Amazon was offer #13.',
    linkedIn: 'https://linkedin.com/in/ravikumar',
    isVerified: true,
    menteeCount: 24,
    rating: 4.8,
    anonConfession:
        'I cried after my 8th rejection. Kept it from my parents for 3 months.',
    interviewRounds: [
      'Online Assessment (DSA)',
      'Technical Round 1 (Algorithms)',
      'Technical Round 2 (System Design)',
      'Bar Raiser Round',
      'Hiring Manager Round'
    ],
    targetRole: 'FAANG',
    email: 'ravi@alum.com',
    yearsOfExp: 2,
  ),
  AlumniModel(
    id: 'a002',
    name: 'Priya Lakshmi Venkat',
    batch: '2021',
    branch: 'CSE',
    company: 'Zoho',
    role: 'Product Engineer',
    location: 'Chennai',
    package: 12.0,
    skills: ['React', 'Node.js', 'PostgreSQL', 'System Design', 'Python'],
    photoUrl: 'https://i.pravatar.cc/150?img=5',
    advice:
        'Zoho values genuine skill over certificates. Build real apps and deploy them.',
    story:
        'Failed Zoho twice. Third attempt with 3 real deployed projects — got ₹12 LPA. Persistence matters.',
    linkedIn: 'https://linkedin.com/in/priyalakshmi',
    isVerified: true,
    menteeCount: 18,
    rating: 4.7,
    anonConfession:
        'My CGPA was 7.2. Everyone said I would not get placed. Proved them wrong.',
    interviewRounds: [
      'Written Test (Aptitude + Coding)',
      'Technical Interview 1',
      'Technical Interview 2 (Project deep dive)',
      'HR Round'
    ],
    targetRole: 'Product',
    email: 'priya@alum.com',
    yearsOfExp: 3,
  ),
  AlumniModel(
    id: 'a003',
    name: 'Ajay Kumar Thota',
    batch: '2017',
    branch: 'ECE',
    company: 'Microsoft',
    role: 'Senior Software Engineer',
    location: 'Bangalore',
    package: 42.0,
    skills: ['C++', 'Azure', 'System Design', 'DSA', 'Machine Learning'],
    photoUrl: 'https://i.pravatar.cc/150?img=8',
    advice:
        'Compound your skills patiently. TCS in year 1, Microsoft in year 7. Do not compare.',
    story:
        'Started at TCS for ₹3.5 LPA. Felt embarrassed. Focused on learning instead of comparing. Microsoft at ₹42 LPA after 7 years.',
    linkedIn: 'https://linkedin.com/in/ajaythota',
    isVerified: true,
    menteeCount: 41,
    rating: 4.9,
    anonConfession:
        'I almost quit engineering after 2 years. ECE to software switch felt impossible at the time.',
    interviewRounds: [
      'Resume Screen',
      'Phone Screen (DSA)',
      'Virtual Onsite Day (4 rounds: DSA + System Design + Behavioral + Hiring Manager)'
    ],
    targetRole: 'FAANG',
    email: 'ajay@alum.com',
    yearsOfExp: 7,
  ),
  AlumniModel(
    id: 'a004',
    name: 'Sneha Varma',
    batch: '2023',
    branch: 'IT',
    company: 'Freshworks',
    role: 'Frontend Engineer',
    location: 'Chennai',
    package: 9.5,
    skills: ['React', 'TypeScript', 'Flutter', 'CSS', 'GraphQL'],
    photoUrl: 'https://i.pravatar.cc/150?img=47',
    advice:
        'UI/UX skills + coding is a rare and valuable combo. Learn Figma alongside Flutter.',
    story:
        'Built 5 apps during college. Freshworks hired me because of my portfolio, not my CGPA (7.8).',
    linkedIn: 'https://linkedin.com/in/snehavarma',
    isVerified: true,
    menteeCount: 12,
    rating: 4.6,
    anonConfession:
        'Used to copy assignments. Regret not learning properly. Self-taught everything post graduation.',
    interviewRounds: [
      'Coding Challenge (3 problems, 90 min)',
      'Technical Interview (React deep dive)',
      'Cultural Fit Interview'
    ],
    targetRole: 'Product',
    email: 'sneha@alum.com',
    yearsOfExp: 1,
  ),
  AlumniModel(
    id: 'a005',
    name: 'Kiran Babu Naidu',
    batch: '2020',
    branch: 'MECH',
    company: 'TCS Digital',
    role: 'Full Stack Developer',
    location: 'Pune',
    package: 7.2,
    skills: ['Java', 'Spring Boot', 'React', 'MySQL', 'Docker'],
    photoUrl: 'https://i.pravatar.cc/150?img=12',
    advice:
        'MECH to software is hard but not impossible. Java + Spring Boot is the fastest route to TCS Digital.',
    story:
        'MECH branch, nobody believed I could switch to software. Cleared TCS Digital through sheer consistency in Java.',
    linkedIn: 'https://linkedin.com/in/kiranbabu',
    isVerified: true,
    menteeCount: 9,
    rating: 4.4,
    anonConfession:
        'Failed TCS NQT twice. Third attempt after 6 months of dedicated prep. Keep going.',
    interviewRounds: [
      'TCS NQT (Aptitude + Coding)',
      'Technical Interview',
      'Managerial Round',
      'HR Round'
    ],
    targetRole: 'Service',
    email: 'kiran@alum.com',
    yearsOfExp: 4,
  ),
  AlumniModel(
    id: 'a006',
    name: 'Divya Sree Patel',
    batch: '2022',
    branch: 'EEE',
    company: 'Infosys',
    role: 'Systems Engineer',
    location: 'Bangalore',
    package: 6.5,
    skills: ['Python', 'SQL', 'ServiceNow', 'ITIL', 'Selenium'],
    photoUrl: 'https://i.pravatar.cc/150?img=25',
    advice:
        'ServiceNow certification + Python scripting opened doors I did not expect. Get certified early.',
    story:
        'EEE student, took ServiceNow CSA certification in 3rd year. Infosys hired me specifically for that skill.',
    linkedIn: 'https://linkedin.com/in/divyasree',
    isVerified: true,
    menteeCount: 7,
    rating: 4.3,
    anonConfession:
        'Cried before every interview. Anxiety is real. What helped: mock interviews with friends.',
    interviewRounds: [
      'InfyTQ Assessment',
      'Technical Interview (Python + SQL)',
      'HR Interview'
    ],
    targetRole: 'Service',
    email: 'divya@alum.com',
    yearsOfExp: 2,
  ),
];
