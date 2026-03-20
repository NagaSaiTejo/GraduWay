// webrtc one-to-many live video broadcasting with interactive features
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:alumini_screen/src/providers/auth_provider.dart';
import 'package:alumini_screen/src/providers/notification_provider.dart';
import '../../../services/webrtc_service.dart';
import 'dart:io' show Platform;
import 'dart:async';

class BroadcastStreamingPage extends StatefulWidget {
  final String streamId;

  const BroadcastStreamingPage({
    super.key, 
    required this.streamId,
  });

  @override
  State<BroadcastStreamingPage> createState() => _BroadcastStreamingPageState();
}

class _BroadcastStreamingPageState extends State<BroadcastStreamingPage> with TickerProviderStateMixin {
  final WebrtcService _webrtcService = WebrtcService();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  int _heartCount = 0;
  final List<Widget> _floatingHearts = [];
  final List<Map<String, String>> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _initWebRTC();
    _startTimer();
  }

  void _setupListeners() {
    _webrtcService.onCommentReceived = (from, text) {
      if (mounted) {
        setState(() {
          _comments.add({'user': from, 'text': text});
        });
      }
    };
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Future<void> _initWebRTC() async {
    await _localRenderer.initialize();

    // Use 10.0.2.2 for Android Emulator, localhost for others (like Windows/Web)
    String serverUrl = 'http://localhost:3000';
    try {
      if (Platform.isAndroid) {
        serverUrl = 'http://10.0.2.2:3000';
      }
    } catch (_) {}

    await _webrtcService.init(
      serverUrl: serverUrl,
      roomId: widget.streamId,
    );
    _setupListeners();

    await _webrtcService.startHostStream();
    setState(() {
      _localRenderer.srcObject = _webrtcService.localStream;
    });

    // Add a notification for the live stream
    if (mounted) {
      context.read<NotificationProvider>().addNotification({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'Streaming Live!',
        'body': 'Your followers have been notified that you are live in session: ${widget.streamId}',
        'time': 'Just now',
        'isRead': false,
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _webrtcService.dispose();
    _localRenderer.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _addHeart() {
    setState(() {
      _heartCount++;
      _floatingHearts.add(_FloatingHeart(
        key: UniqueKey(),
        onComplete: (key) {
          if (mounted) {
            setState(() => _floatingHearts.removeWhere((h) => h.key == key));
          }
        },
      ));
    });
  }

  void _postComment() {
    if (_commentController.text.isNotEmpty) {
      final auth = context.read<AuthProvider>();
      _webrtcService.sendComment(_commentController.text, auth.userName);
      setState(() {
        _comments.add({
          'user': auth.userName,
          'text': _commentController.text,
        });
        _commentController.clear();
      });
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _webrtcService.localStream?.getAudioTracks().forEach((track) {
        track.enabled = !_isMuted;
      });
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
      _webrtcService.localStream?.getVideoTracks().forEach((track) {
        track.enabled = !_isCameraOff;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-screen Video Layer
          _buildVideoLayer(),

          // 2. Gradient Overlays for readability
          _buildGradientOverlay(),

          // 3. Top Header Section
          _buildTopHeader(),

          // 4. Right-side Controls Sidebar
          _buildSideControls(),

          // 5. Interaction Layer (Comments & Input)
          _buildInteractionLayer(),

          // 6. Floating Hearts Animation Layer
          ..._floatingHearts,
        ],
      ),
    );
  }

  Widget _buildVideoLayer() {
    return Container(
      color: Colors.black,
      child: RTCVideoView(
        _localRenderer,
        mirror: true,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black54,
              Colors.transparent,
              Colors.transparent,
              Colors.black87,
            ],
            stops: const [0.0, 0.2, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final auth = context.read<AuthProvider>();
    return Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Host Info
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(auth.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(auth.techField, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
              const SizedBox(width: 15),
              // Live Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Text("LIVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(_formatTime(_secondsElapsed), style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          // Viewer Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.visibility_outlined, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text("245", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideControls() {
    return Positioned(
      right: 20,
      top: 150,
      child: Column(
        children: [
          _buildSideButton(Icons.cameraswitch, "Flip", onPressed: _webrtcService.switchCamera),
          _buildSideButton(Icons.auto_fix_high, "Effects", onPressed: () {}),
          _buildSideButton(Icons.lightbulb_outline, "Light", onPressed: () {}),
          _buildSideButton(_isMuted ? Icons.mic_off : Icons.mic, "Mic", 
            onPressed: _toggleMute, isActive: _isMuted),
          _buildSideButton(_isCameraOff ? Icons.videocam_off : Icons.videocam, "Cam", 
            onPressed: _toggleCamera, isActive: _isCameraOff),
          const SizedBox(height: 20),
          _buildSideButton(Icons.close, "End", color: Colors.redAccent, onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  Widget _buildSideButton(IconData icon, String label, {required VoidCallback onPressed, Color color = Colors.white24, bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          GestureDetector(
            onTap: onPressed,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: isActive ? Colors.red.withOpacity(0.5) : color,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildInteractionLayer() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Comments Panel
            SizedBox(
              height: 200,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _comments.length,
                reverse: true, // Newest at bottom
                itemBuilder: (context, index) {
                  final comment = _comments[_comments.length - 1 - index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(radius: 14, backgroundColor: Colors.white12, child: Icon(Icons.person, size: 16, color: Colors.white)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment['user']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(comment['text']!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // Bottom Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: "Add a comment...",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _postComment(),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _postComment),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _addHeart,
                  child: const Icon(Icons.favorite, color: Colors.redAccent, size: 32),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.card_giftcard, color: Colors.orangeAccent, size: 30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingHeart extends StatefulWidget {
  final Function(Key?) onComplete;
  const _FloatingHeart({super.key, required this.onComplete});

  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<double> _alignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)));
    _scale = Tween<double>(begin: 0.5, end: 1.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _alignment = Tween<double>(begin: 0.0, end: -0.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward().then((_) => widget.onComplete(widget.key));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          bottom: 150 + (250 * (1 - _opacity.value)), // Float higher
          right: 30 + (40 * _alignment.value), // Drifts horizontally
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
            ),
          ),
        );
      },
    );
  }
}
