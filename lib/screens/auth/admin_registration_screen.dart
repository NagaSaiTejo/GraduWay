import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../theme/app_colors.dart';
import '../../core/api_config.dart';

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() =>
      _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminCodeController = TextEditingController();

  bool _isLoading = false;
  XFile? _profileImage;
  static const int _maxImageBytes = 2 * 1024 * 1024; // 2 MB
  static const Set<String> _allowedEmailDomains = {
    'acet.ac.in',
    'aec.edu.in',
    'acoe.edu.in',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    // imageQuality is not supported on Flutter Web — skip it to avoid delays
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (bytes.length > _maxImageBytes) {
      _showError(
          'Profile image must be under 2 MB. Please choose a smaller image.');
      return;
    }
    setState(() => _profileImage = picked);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(ApiConfig.registerAdmin);
      final request = http.MultipartRequest('POST', uri);

      request.fields['name'] = _nameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['password'] = _passwordController.text;
      request.fields['adminCode'] = _adminCodeController.text.trim();

      // Profile image — set correct MIME type so multer accepts it
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        final ext = _profileImage!.name.split('.').last.toLowerCase();
        final mimeType = ext == 'png'
            ? 'image/png'
            : ext == 'gif'
                ? 'image/gif'
                : ext == 'webp'
                    ? 'image/webp'
                    : 'image/jpeg';
        request.files.add(http.MultipartFile.fromBytes(
          'profileImage',
          bytes,
          filename: _profileImage!.name,
          contentType: MediaType.parse(mimeType),
        ));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Registration successful! Please login.')),
        );
        context.pop();
      } else {
        _showError(_parseMessage(response.body));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(
          'Could not connect to server. Please ensure backend is running.');
    }
  }

  String _parseMessage(String json) {
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(json);
    return match?.group(1) ?? 'Registration failed.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin Registration',
            style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Join as an Admin',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.admin))
                    .animate()
                    .fadeIn()
                    .slideY(),
                const SizedBox(height: 8),
                const Text(
                        'Manage users, verify alumni, and oversee the platform.',
                        style: TextStyle(color: AppColors.textSecondary))
                    .animate()
                    .fadeIn(delay: 100.ms),
                const SizedBox(height: 28),

                // Profile Image
                _ProfileImagePicker(
                  image: _profileImage,
                  onTap: _pickProfileImage,
                  accentColor: AppColors.admin,
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),

                _buildTextField(
                  controller: _adminCodeController,
                  label: 'Secret Admin Code',
                  icon: Icons.vpn_key_outlined,
                  obscureText: true,
                  validator: (v) =>
                      v!.isEmpty ? 'Required for admin registration' : null,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v!.isEmpty ? 'Please enter your name' : null,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please enter your email';
                    }
                    final email = v.trim().toLowerCase();
                    final atIndex = email.lastIndexOf('@');
                    if (atIndex <= 0 || atIndex == email.length - 1) {
                      return 'Enter a valid email';
                    }
                    final domain = email.substring(atIndex + 1);
                    if (!_allowedEmailDomains.contains(domain)) {
                      return 'Use college email: @acet.ac.in, @aec.edu.in, or @acoe.edu.in';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) =>
                      v != null && v.length < 6 ? 'Min 6 characters' : null,
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.admin,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Register',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _ProfileImagePicker extends StatelessWidget {
  final XFile? image;
  final VoidCallback onTap;
  final Color accentColor;

  const _ProfileImagePicker({
    required this.image,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: accentColor.withValues(alpha: 0.1),
              backgroundImage: image != null
                  ? (kIsWeb
                      ? NetworkImage(image!.path)
                      : FileImage(File(image!.path))) as ImageProvider
                  : null,
              child: image == null
                  ? Icon(Icons.person,
                      size: 52, color: accentColor.withValues(alpha: 0.5))
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
