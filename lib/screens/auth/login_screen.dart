import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';

// ─── Role detection by email domain ──────────────────────────────────────────

UserRole _roleFromEmail(String email) {
  final lower = email.trim().toLowerCase();
  if (lower.endsWith('@admin.com')) return UserRole.admin;
  if (lower.endsWith('@alum.com')) return UserRole.alumni;
  return UserRole.student; // @stud.com or any other
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
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

              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'e.g. name@stud.com',
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 16),

              // Password field
              TextField(
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
                onChanged: (_) => setState(() => _errorMessage = null),
              ).animate().fadeIn(delay: 400.ms),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),

              // Sign In button
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
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              Center(
                child: TextButton(
                  onPressed: () => context.push('/register'),
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
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email and password.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).login(email, password);

      if (!mounted) return;

      final authState = ref.read(authProvider);
      if (authState.role == UserRole.student) {
        context.go('/home');
      } else if (authState.role == UserRole.alumni) {
        context.go('/alumni-home');
      } else if (authState.role == UserRole.admin) {
        context.go('/admin-home');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
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
