const { io } = require('socket.io-client');
const http = require('http');

// We need to start the actual server or connect to a running one.
// Since we want to verify the logic, we'll try to connect to localhost:3000
// assuming the user might have it running, or we can try to spawn it.
// For simplicity, let's assume it's running on 3000 if we are to "check it".

const URL = 'http://localhost:3000';
const socketOptions = {
    path: '/api/socket',
    transports: ['websocket'],
    forceNew: true
};

async function verify() {
    console.log('🔍 Starting Classroom Visibility Verification...');

    const mentor = io(URL, { ...socketOptions, query: { userName: 'Mentor-Tester' } });
    const student = io(URL, { ...socketOptions, query: { userName: 'Student-Tester' } });

    let studentReceivedUpdate = false;

    return new Promise((resolve, reject) => {
        const timeout = setTimeout(() => {
            mentor.close();
            student.close();
            reject(new Error('Verification timed out after 10s'));
        }, 10000);

        student.on('connect', () => {
            console.log('✅ Student connected');
            // Student joins global-lobby (this was rejected before the fix)
            student.emit('join-room', { roomId: 'global-lobby', role: 'student' });
        });

        student.on('error', (msg) => {
            console.error('❌ Student received error:', msg);
            if (msg.includes('not been started by the faculty')) {
                console.error('FAILED: Student was rejected from lobby!');
            }
        });

        student.on('room-list', (rooms) => {
            console.log('📊 Student received room-list:', JSON.stringify(rooms));
            const hasTestRoom = rooms.some(r => r.id === 'test-verification-room');
            if (hasTestRoom) {
                console.log('🎉 SUCCESS: Student detected the live room!');
                studentReceivedUpdate = true;
                cleanup();
                resolve(true);
            }
        });

        mentor.on('connect', () => {
            console.log('✅ Mentor connected');
            setTimeout(() => {
                console.log('📡 Mentor starting "test-verification-room"...');
                mentor.emit('join-room', { 
                    roomId: 'test-verification-room', 
                    role: 'mentor', 
                    title: 'Verification Session' 
                });
            }, 1000);
        });

        function cleanup() {
            clearTimeout(timeout);
            mentor.close();
            student.close();
        }
    });
}

verify().catch(err => {
    console.error('❌ Verification failed:', err.message);
    process.exit(1);
});
