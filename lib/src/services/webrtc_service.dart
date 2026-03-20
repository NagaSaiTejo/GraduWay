// webrtc core peer connection and signaling management
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:developer' as dev;

/// Service to manage WebRTC peer connections and signaling.
class WebrtcService {
  late IO.Socket socket;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  Function(MediaStream)? onRemoteStream;
  Function(String from, String text)? onCommentReceived;
  String? _roomId;
  String? _userName;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
    'sdpSemantics': 'unified-plan',
  };

  /// Initializes the signaling connection and WebRTC.
  Future<void> init({required String serverUrl, required String roomId}) async {
    _roomId = roomId;
    dev.log('Initializing WebRTC Service for room: $_roomId');

    socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());

    socket.connect();

    socket.onConnect((_) {
      dev.log('Connected to signaling server');
      socket.emit('join-room', _roomId);
    });

    socket.on('offer', (data) async {
      dev.log('Received offer from ${data['from']}');
      await _handleOffer(data);
    });

    socket.on('answer', (data) async {
      dev.log('Received answer from ${data['from']}');
      await _handleAnswer(data);
    });

    socket.on('ice-candidate', (data) async {
      dev.log('Received ice-candidate from ${data['from']}');
      await _handleIceCandidate(data);
    });

    socket.on('new-comment', (data) {
      onCommentReceived?.call(data['userName'], data['text']);
    });

    socket.on('user-joined', (socketId) {
      dev.log('User joined: $socketId');
    });
  }

  /// Starts a new call as the host (Mentor).
  Future<void> startHostStream() async {
    dev.log('Starting stream as host');
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': 'user',
        'width': 640,
        'height': 480,
        'frameRate': 30,
      },
    });

    await _createPeerConnection();
    
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    dev.log('✅ [MENTOR] STEP 2: Offer created');
    await _peerConnection!.setLocalDescription(offer);
    dev.log('✅ [MENTOR] STEP 3: Local Description (Offer) set');

    dev.log('📱 [MENTOR] Sending offer to room $_roomId');
    socket.emit('offer', {
      'offer': offer.toMap(),
      'roomId': _roomId,
    });
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(_configuration);
    
    _peerConnection!.onIceCandidate = (candidate) {
      dev.log('📡 [LOCAL] ICE Candidate generated: ${candidate.candidate?.substring(0, 10)}...');
      socket.emit('ice-candidate', {
        'candidate': candidate.toMap(),
        'roomId': _roomId,
      });
    };

    _peerConnection!.onTrack = (event) {
      dev.log('🎥 [REMOTE] STEP 10: Remote track received!');
      if (event.streams.isNotEmpty) {
        onRemoteStream?.call(event.streams[0]);
      }
    };

    _peerConnection!.onConnectionState = (state) {
      dev.log('Connection state: $state');
    };

    _peerConnection!.onIceConnectionState = (state) {
      dev.log('ICE connection state: $state');
    };
  }

  Future<void> _handleOffer(dynamic data) async {
    dev.log('📥 [STUDENT] STEP 4: Offer received from ${data['from']}');
    if (_peerConnection == null) {
      await _createPeerConnection();
    }

    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(data['offer']['sdp'], data['offer']['type'])
    );
    dev.log('✅ [STUDENT] STEP 5: Remote Description (Offer) set');

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    dev.log('✅ [STUDENT] STEP 6: Answer created');
    await _peerConnection!.setLocalDescription(answer);
    dev.log('✅ [STUDENT] STEP 7: Local Description (Answer) set');

    dev.log('📱 [STUDENT] Sending answer to ${data['from']}');
    socket.emit('answer', {
      'answer': answer.toMap(),
      'to': data['from'],
    });
  }

  Future<void> _handleAnswer(dynamic data) async {
    dev.log('📥 [MENTOR] STEP 8: Answer received from ${data['from']}');
    if (_peerConnection != null) {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['answer']['sdp'], data['answer']['type'])
      );
      dev.log('✅ [MENTOR] STEP 9: Remote Description (Answer) set');
    }
  }

  Future<void> _handleIceCandidate(dynamic data) async {
    dev.log('📡 [REMOTE] Adding ICE candidate from ${data['from']}');
    if (_peerConnection != null) {
      await _peerConnection!.addCandidate(
        RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        ),
      );
    }
  }

  /// Disconnects the call and releases resources.
  void dispose() {
    dev.log('Disposing WebrtcService');
    _localStream?.getTracks().forEach((t) => t.stop());
    _localStream?.dispose();
    _peerConnection?.dispose();
    socket.disconnect();
  }

  MediaStream? get localStream => _localStream;

  void toggleAudio(bool enabled) {
    _localStream?.getAudioTracks().forEach((track) => track.enabled = enabled);
  }

  void toggleVideo(bool enabled) {
    _localStream?.getVideoTracks().forEach((track) => track.enabled = enabled);
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      await Helper.switchCamera(_localStream!.getVideoTracks()[0]);
    }
  }

  void sendComment(String text, String userName) {
    socket.emit('send-comment', {
      'text': text,
      'roomId': _roomId,
      'userName': userName,
    });
  }
}
