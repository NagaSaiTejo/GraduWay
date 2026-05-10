import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../theme/app_colors.dart';
import '../../utils/platform_pdf_picker.dart';
import '../../core/api_config.dart';
import '../../services/firebase_service.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() =>
      _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState
    extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rollNumberController = TextEditingController();
  String _selectedBranch = 'CSE';
  int _selectedYear = 1;
  bool _isLoading = false;

  // File picks
  XFile? _profileImage;
  PlatformFile? _resumeFile;

  // Size limits
  static const int _maxImageBytes = 2 * 1024 * 1024; // 2 MB
  static const int _maxResumeBytes = 5 * 1024 * 1024; // 5 MB

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  // ─── Pick Profile Image ──────────────────────────────────────────────────
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    // imageQuality is not supported on Flutter Web — skip it to avoid delays
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (bytes.length > _maxImageBytes) {
      _showError('Profile image must be under 2 MB. Please choose a smaller image.');
      return;
    }
    setState(() => _profileImage = picked);
  }

  // ─── Pick Resume PDF ─────────────────────────────────────────────────────
  Future<void> _pickResume() async {
    if (kIsWeb) {
      // ── Web: use native <input type="file"> via dart:html (always works) ──
      try {
        final result = await pickPdfFilePlatform(_maxResumeBytes);
        if (result == null) return;
        setState(() => _resumeFile = PlatformFile(
          name: result['name'] as String,
          size: (result['bytes'] as List).length,
          bytes: result['bytes'] as Uint8List,
        ));
      } catch (e) {
        if (e == 'size_exceeded') {
          _showError('Resume must be under 5 MB. Please choose a smaller PDF.');
        } else {
          _showError('Could not open file picker. Please try again.');
        }
      }
    } else {
      // ── Native: use file_picker ──
      try {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
        );
        if (result == null || result.files.isEmpty) return;
        final file = result.files.first;
        final bytes = await File(file.path!).readAsBytes();
        if (bytes.length > _maxResumeBytes) {
          _showError('Resume must be under 5 MB. Please choose a smaller PDF.');
          return;
        }
        setState(() => _resumeFile = PlatformFile(
          name: file.name,
          size: bytes.length,
          bytes: bytes,
        ));
      } catch (e) {
        _showError('Could not open file picker. Please try again.');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  // ─── Register ────────────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // ── Step 1: Register in Firebase (Real-time/Auth) ──
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      await FirebaseService.registerUser(
        email: email,
        password: password,
        role: 'student',
        userData: {
          'name': _nameController.text.trim(),
          'rollNumber': _rollNumberController.text.trim(),
          'branch': _selectedBranch,
          'currentYear': _selectedYear,
        },
      );

      // ── Step 2: Register in Node.js/MongoDB (Relational) ──
      final uri = Uri.parse(ApiConfig.registerStudent);
      final request = http.MultipartRequest('POST', uri);

      // Text fields
      request.fields['name'] = _nameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['password'] = _passwordController.text;
      request.fields['rollNumber'] = _rollNumberController.text.trim();
      request.fields['branch'] = _selectedBranch;
      request.fields['currentYear'] = _selectedYear.toString();

      // Profile image — set correct MIME type so multer accepts it
      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        final ext = _profileImage!.name.split('.').last.toLowerCase();
        final mimeType = ext == 'png' ? 'image/png'
            : ext == 'gif' ? 'image/gif'
            : ext == 'webp' ? 'image/webp'
            : 'image/jpeg'; // default for jpg/jpeg
        request.files.add(http.MultipartFile.fromBytes(
          'profileImage',
          bytes,
          filename: _profileImage!.name,
          contentType: MediaType.parse(mimeType),
        ));
      }

      // Resume
      if (_resumeFile != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'resume',
          _resumeFile!.bytes!,
          filename: _resumeFile!.name,
        ));
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
        context.pop();
      } else {
        final data = response.body;
        _showError(data.contains('message') ? _parseMessage(data) : 'Registration failed.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Could not connect to server. Please ensure backend is running.');
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
        title: const Text('Student Registration',
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
                const Text('Join as a Student',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary))
                    .animate()
                    .fadeIn()
                    .slideY(),
                const SizedBox(height: 8),
                const Text(
                    'Create your account to connect with alumni and access resources.',
                    style: TextStyle(color: AppColors.textSecondary))
                    .animate()
                    .fadeIn(delay: 100.ms),
                const SizedBox(height: 28),

                // ── Profile Image ─────────────────────────────────────────
                _ProfileImagePicker(
                  image: _profileImage,
                  onTap: _pickProfileImage,
                  accentColor: AppColors.primary,
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 24),

                // ── Text Fields ───────────────────────────────────────────
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _rollNumberController,
                  label: 'Roll Number',
                  icon: Icons.badge_outlined,
                  validator: (v) => v!.isEmpty ? 'Please enter your roll number' : null,
                ).animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!v.contains('@')) return 'Enter a valid email';
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
                const SizedBox(height: 16),

                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedBranch,
                      decoration: _dropdownDecoration('Branch', Icons.account_tree_outlined),
                      items: ['CSE', 'ECE', 'MECH', 'CIVIL', 'IT', 'EEE']
                          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBranch = v!),
                    ).animate().fadeIn(delay: 400.ms),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedYear,
                      decoration: _dropdownDecoration('Year', Icons.school_outlined),
                      items: [1, 2, 3, 4]
                          .map((y) =>
                              DropdownMenuItem(value: y, child: Text('Year $y')))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedYear = v!),
                    ).animate().fadeIn(delay: 450.ms),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── Resume Upload ─────────────────────────────────────────
                _FilePicker(
                  fileName: _resumeFile?.name,
                  onTap: _pickResume,
                  label: 'Upload Resume (PDF, max 5 MB)',
                  icon: Icons.description_outlined,
                  accentColor: AppColors.primary,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Register',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ).animate().fadeIn(delay: 550.ms),
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

  InputDecoration _dropdownDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      );
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
                  ? Icon(Icons.person, size: 52, color: accentColor.withValues(alpha: 0.5))
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
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilePicker extends StatelessWidget {
  final String? fileName;
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final Color accentColor;

  const _FilePicker({
    required this.fileName,
    required this.onTap,
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
              color: fileName != null ? accentColor : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: fileName != null ? accentColor.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: fileName != null ? accentColor : Colors.grey.shade500),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fileName ?? label,
                style: TextStyle(
                  color:
                      fileName != null ? accentColor : Colors.grey.shade600,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (fileName != null)
              Icon(Icons.check_circle, color: accentColor, size: 18),
          ],
        ),
      ),
    );
  }
}
