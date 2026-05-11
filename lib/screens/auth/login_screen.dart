import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  if (_overlayEntry == null) {
                    _overlayEntry = _createOverlayEntry(context);
                    Overlay.of(context).insert(_overlayEntry!);
                  } else {
                    _removeOverlay();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                ),
              );
            }
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Logo
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
              ).animate().fadeIn().scale(curve: Curves.elasticOut),

              const SizedBox(height: 32),

              const Text(
                'Welcome to GraduWay',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

              const SizedBox(height: 8),
              const Text(
                'Bridging the gap between students and success.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 40),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'e.g. name@stud.com',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Email is required';
                        if (!value.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
              ),

              // ── Error message (always in layout, animated in/out) ─────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                height: _errorMessage != null ? null : 0,
                padding: _errorMessage != null
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                    : EdgeInsets.zero,
                margin: _errorMessage != null
                    ? const EdgeInsets.only(top: 10)
                    : EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                ),
                child: _errorMessage != null
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // Sign In button — no animate() to prevent replay on setState
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                  elevation: 8,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Sign In'),
              ),

              const SizedBox(height: 24),

              Center(
                child: TextButton(
                  onPressed: () => _showRegistrationSheet(context),
                  child: const Text(
                    'New here? Create an account',
                    style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ── Path 1: Try Firebase Auth (production) ─────────────────────────────
    try {
      // Check if Firebase is actually initialized before trying to use it
      Firebase.app(); 
      
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = credential.user!.uid;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        final data = userDoc.data()!;
        ref.read(authProvider.notifier).setUser(
          email: email,
          roleStr: data['role'] as String,
          user: {'id': uid, ...data},
        );
        setState(() => _isLoading = false);
        return; // Firebase login succeeded — exit early
      }
    } catch (e) {
      // Firebase unavailable (no app or auth error) — fall through to backend
      debugPrint('Firebase login skipped/failed, using backend: $e');
    }

    // ── Path 2: Fall back to Node.js/MongoDB backend (development) ────────
    try {
      final uri = Uri.parse('http://127.0.0.1:5000/api/auth/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        ref.read(authProvider.notifier).setUser(
          email: email,
          roleStr: data['role'] as String,
          user: data['user'] as Map<String, dynamic>,
        );
      } else {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() =>
            _errorMessage = data['message'] as String? ?? 'Login failed. Please try again.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not connect to server.\nMake sure the backend is running.';
      });
    }
  }


  OverlayEntry _createOverlayEntry(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height, // Position right below the app bar
        right: 20,
        width: 280, // Made it a bit smaller/slimmer
        child: Material(
          color: Colors.transparent,
          child: Opacity(
            opacity: 0.9, // Semi-transparent
            child: const _CredentialHintCard(),
          ),
        ),
      ),
    );
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showRegistrationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create an Account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select your role to get started.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF3FF),
                    child: Icon(Icons.school_outlined, color: AppColors.primary),
                  ),
                  title: const Text('Student', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Join as a current student', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    context.pop();
                    context.push('/register-student');
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.alumni.withValues(alpha: 0.1),
                    child: const Icon(Icons.work_outline, color: AppColors.alumni),
                  ),
                  title: const Text('Alumni', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Join as an alumni', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    context.pop();
                    context.push('/register-alumni');
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.admin.withValues(alpha: 0.1),
                    child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.admin),
                  ),
                  title: const Text('Admin', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Platform administrator', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    context.pop();
                    context.push('/register-admin');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Credential Hint Card ─────────────────────────────────────────────────────

class _CredentialHintCard extends StatelessWidget {
  const _CredentialHintCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3FF), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'How to Login',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Student
          _HintRow(
            icon: Icons.school_outlined,
            role: 'Student',
            color: AppColors.primary,
            lines: const [
              'Email ending with  @stud.com',
              'e.g.  yourname@stud.com',
              'Password: anything',
            ],
          ),

          const Divider(height: 20, thickness: 1, color: Color(0xFFDDE3FF)),

          // Alumni
          _HintRow(
            icon: Icons.work_outline_rounded,
            role: 'Alumni',
            color: AppColors.alumni,
            lines: const [
              'Email ending with  @alum.com',
              'e.g.  yourname@alum.com',
              'Password: anything',
            ],
          ),

          const Divider(height: 20, thickness: 1, color: Color(0xFFDDE3FF)),

          // Admin
          _HintRow(
            icon: Icons.admin_panel_settings_outlined,
            role: 'Admin',
            color: AppColors.admin,
            lines: const [
              'Email ending with  @admin.com',
              'e.g.  yourname@admin.com',
              'Password: anything',
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05);
  }
}

class _HintRow extends StatelessWidget {
  final IconData icon;
  final String role;
  final Color color;
  final List<String> lines;

  const _HintRow({
    required this.icon,
    required this.role,
    required this.color,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Login as $role',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              ...lines.map((line) => Text(
                    line,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }
}
