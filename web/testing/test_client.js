const socket = io('http://localhost:3000');
const roomIdInput = document.getElementById('roomId');
const joinBtn = document.getElementById('joinBtn');
const startBtn = document.getElementById('startBtn');
const statusDiv = document.getElementById('status');
const localVideo = document.getElementById('localVideo');
const remoteVideo = document.getElementById('remoteVideo');

let localStream;
let peerConnection;
let roomId;

const configuration = {
    iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
        { urls: 'stun:stun1.l.google.com:19302' }
    ]
};

socket.on('connect', () => {
    statusDiv.innerText = 'Connected to Signaling Server';
    joinBtn.disabled = false;
});

socket.on('user-joined', (socketId) => {
    console.log('User joined room:', socketId);
    statusDiv.innerText = `User ${socketId} joined the room`;
});

socket.on('offer', async (data) => {
    console.log('Received offer from:', data.from);
    if (!peerConnection) createPeerConnection(data.from);
    
    await peerConnection.setRemoteDescription(new RTCSessionDescription(data.offer));
    const answer = await peerConnection.createAnswer();
    await peerConnection.setLocalDescription(answer);
    
    socket.emit('answer', {
        answer: answer,
        to: data.from
    });
});

socket.on('answer', async (data) => {
    console.log('Received answer from:', data.from);
    await peerConnection.setRemoteDescription(new RTCSessionDescription(data.answer));
});

socket.on('ice-candidate', async (data) => {
    console.log('Received ICE candidate from:', data.from);
    if (peerConnection) {
        await peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
    }
});

joinBtn.onclick = () => {
    roomId = roomIdInput.value;
    if (roomId) {
        socket.emit('join-room', roomId);
        statusDiv.innerText = `Joined room: ${roomId}`;
        joinBtn.disabled = true;
        startBtn.disabled = false;
    }
};

startBtn.onclick = async () => {
    statusDiv.innerText = 'Starting stream as Host...';
    localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
    localVideo.srcObject = localStream;
    
    // In this webinar model, the host waits for users to join and then sends offers
    // Or users can request an offer. For simplicity, let's just make it a call.
    createPeerConnection();
    
    localStream.getTracks().forEach(track => {
        peerConnection.addTrack(track, localStream);
    });

    const offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);
    
    socket.emit('offer', {
        offer: offer,
        roomId: roomId
    });
};

function createPeerConnection(targetId) {
    peerConnection = new RTCPeerConnection(configuration);

    peerConnection.onicecandidate = (event) => {
        if (event.candidate) {
            socket.emit('ice-candidate', {
                candidate: event.candidate,
                roomId: roomId,
                to: targetId
            });
        }
    };

    peerConnection.ontrack = (event) => {
        console.log('Received remote track');
        remoteVideo.srcObject = event.streams[0];
    };

    if (localStream) {
        localStream.getTracks().forEach(track => {
            peerConnection.addTrack(track, localStream);
        });
    }
}
