const io = require('socket.io-client');

const SERVER_URL = 'https://signaling-server-23mh1a05n6-dev.apps.rm2.thpm.p1.openshiftapps.com';
const PATH = '/api/socket';

async function testClassroom() {
  console.log('📡 Starting Production Classroom Verification...');
  console.log(`🔗 Target: ${SERVER_URL}${PATH}`);

  const roomId = 'test-room-' + Date.now();

  // 1. Simulate Alumni (Mentor) creating a class
  console.log('👨‍🏫 Connecting as Alumnus (Mentor)...');
  const mentor = io(SERVER_URL, {
    path: PATH,
    transports: ['polling', 'websocket'], // Matches our resilient config
    query: { userName: 'Mentor_Test' }
  });

  const mentorConnected = new Promise((resolve, reject) => {
    mentor.on('connect', () => {
      console.log('✅ Mentor Connected!');
      mentor.emit('join-room', {
        roomId: roomId,
        role: 'mentor', // Backend logic will now verify this role based on the connection session
        userName: 'Mentor_Test',
        title: 'Stabilized Handshake Test'
      });
      resolve();
    });
    mentor.on('connect_error', (err) => reject('Mentor Connect Error: ' + err));
    setTimeout(() => reject('Mentor Connection Timeout'), 15000);
  });

  try {
    await mentorConnected;

    // 2. Simulate Student joining
    console.log('🎓 Connecting as Student...');
    const student = io(SERVER_URL, {
      path: PATH,
      transports: ['polling', 'websocket'],
      query: { userName: 'Student_Test' }
    });

    const studentJoined = new Promise((resolve, reject) => {
      student.on('connect', () => {
        console.log('✅ Student Connected!');
        student.emit('join-room', {
          roomId: roomId,
          role: 'student',
          userName: 'Student_Test'
        });
      });

      // Mentor should receive 'user-joined' when student joins
      mentor.on('user-joined', (data) => {
        console.log('🎉 Mentor notified: Student has joined the room!');
        resolve();
      });

      student.on('connect_error', (err) => reject('Student Connect Error: ' + err));
      setTimeout(() => reject('Student Handshake Timeout'), 15000);
    });

    await studentJoined;

    // 3. Verify Message Relay
    console.log('💬 Testing chat relay...');
    const messageRelayed = new Promise((resolve) => {
      student.on('new-message', (data) => {
        if (data.text === 'Handshake Success!') {
          console.log('✅ Chat Relay Verified: Message received by Student');
          resolve();
        }
      });
      mentor.emit('send-message', { roomId, text: 'Handshake Success!', userName: 'Mentor_Test' });
    });

    await messageRelayed;

    console.log('\n🌟 PRODUCTION VERIFICATION COMPLETE: Handshake is STABLE.');

  } catch (error) {
    console.error('\n❌ VERIFICATION FAILED:', error);
  } finally {
    mentor.disconnect();
    if (typeof student !== 'undefined') student.disconnect();
    process.exit(0);
  }
}

testClassroom();
