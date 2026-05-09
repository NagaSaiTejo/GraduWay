import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_config.dart';
import '../../providers/app_providers.dart';
import '../../data/models/student_model.dart';
import '../../data/models/alumni_model.dart';
import '../../data/models/admin_model.dart';
import '../../services/storage_service.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.student;

  // Common Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  // Student Specific
  final _rollController = TextEditingController();
  final _branchController = TextEditingController();
  final _yearController = TextEditingController();
  File? _profilePic;
  File? _resume;

  // Alumni Specific
  final _companyController = TextEditingController();
  final _jobRoleController = TextEditingController();
  final _batchController = TextEditingController();
  File? _idCard;

  // Admin Specific
  final _empIdController = TextEditingController();
  final _adminSecretController = TextEditingController();

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profilePic = File(pickedFile.path));
    }
  }

  Future<void> _pickFile(bool isResume) async {
    // Correct way for newer file_picker versions
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        if (isResume) _resume = File(result.files.single.path!);
        else _idCard = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join GraduWay')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('I am a...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SegmentedButton<UserRole>(
                segments: const [
                  ButtonSegment(value: UserRole.student, label: Text('Student'), icon: Icon(Icons.school)),
                  ButtonSegment(value: UserRole.alumni, label: Text('Alumni'), icon: Icon(Icons.work)),
                  ButtonSegment(value: UserRole.admin, label: Text('Admin'), icon: Icon(Icons.admin_panel_settings)),
                ],
                selected: {_selectedRole},
                onSelectionChanged: (Set<UserRole> newSelection) {
                  setState(() => _selectedRole = newSelection.first);
                },
              ),
              const SizedBox(height: 24),

              // Common Fields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'College Email', prefixIcon: Icon(Icons.email)),
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (!v.endsWith('@aec.edu.in') && !v.endsWith('@acet.ac.in')) {
                    return 'Must be a college email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                validator: (v) => v!.length < 6 ? 'Min 6 chars' : null,
              ),
              const SizedBox(height: 24),

              if (_selectedRole == UserRole.student) ..._buildStudentFields(),
              if (_selectedRole == UserRole.alumni) ..._buildAlumniFields(),
              if (_selectedRole == UserRole.admin) ..._buildAdminFields(),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegistration,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStudentFields() {
    return [
      TextFormField(controller: _rollController, decoration: const InputDecoration(labelText: 'Roll Number')),
      const SizedBox(height: 16),
      TextFormField(controller: _branchController, decoration: const InputDecoration(labelText: 'Branch (e.g. CSE)')),
      const SizedBox(height: 16),
      TextFormField(controller: _yearController, decoration: const InputDecoration(labelText: 'Current Year'), keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Mobile Number'), keyboardType: TextInputType.phone),
      const SizedBox(height: 16),
      ListTile(
        title: Text(_profilePic == null ? 'Upload Profile Picture' : 'Picture Selected'),
        trailing: const Icon(Icons.camera_alt),
        onTap: _pickImage,
      ),
      ListTile(
        title: Text(_resume == null ? 'Upload Resume (PDF)' : 'Resume Selected'),
        trailing: const Icon(Icons.picture_as_pdf),
        onTap: () => _pickFile(true),
      ),
    ];
  }

  List<Widget> _buildAlumniFields() {
    return [
      TextFormField(controller: _companyController, decoration: const InputDecoration(labelText: 'Current Company')),
      const SizedBox(height: 16),
      TextFormField(controller: _jobRoleController, decoration: const InputDecoration(labelText: 'Job Role')),
      const SizedBox(height: 16),
      TextFormField(controller: _batchController, decoration: const InputDecoration(labelText: 'Passout Batch (Year)')),
      const SizedBox(height: 16),
      ListTile(
        title: Text(_idCard == null ? 'Upload Alumni ID Card' : 'ID Card Selected'),
        trailing: const Icon(Icons.badge),
        onTap: () => _pickFile(false),
      ),
    ];
  }

  List<Widget> _buildAdminFields() {
    return [
      TextFormField(controller: _empIdController, decoration: const InputDecoration(labelText: 'Employee ID')),
      const SizedBox(height: 16),
      TextFormField(
        controller: _adminSecretController,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Admin Secret Key', helperText: 'Provided by college management'),
      ),
    ];
  }

  void _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final id = const Uuid().v4();

    try {
      String photoUrl = '';
      String? resumeUrl;
      String? idCardUrl;

      if (_profilePic != null) {
        photoUrl = await StorageService.uploadFile(_profilePic!, 'profiles');
      }

      if (_selectedRole == UserRole.student) {
        if (_resume != null) {
          resumeUrl = await StorageService.uploadFile(_resume!, 'resumes');
        }
        final student = StudentModel(
          id: id,
          name: _nameController.text,
          email: _emailController.text,
          branch: _branchController.text,
          year: int.parse(_yearController.text),
          targetCareer: '',
          skills: [],
          careerScore: 0,
          earnedBadges: [],
          questionsAsked: 0,
          mentorSessionsAttended: 0,
          photoUrl: photoUrl,
          rollNumber: _rollController.text,
          mobileNumber: _phoneController.text,
          resumeUrl: resumeUrl,
          isVerified: false,
          createdAt: DateTime.now(),
        );
        await ref.read(authProvider.notifier).registerStudent(student, _passwordController.text);
      } else if (_selectedRole == UserRole.alumni) {
        if (_idCard != null) {
          idCardUrl = await StorageService.uploadFile(_idCard!, 'id_cards');
        }
        final alumni = AlumniModel(
          id: id,
          name: _nameController.text,
          email: _emailController.text,
          batch: _batchController.text,
          branch: '',
          company: _companyController.text,
          role: _jobRoleController.text,
          location: '',
          package: 0,
          skills: [],
          photoUrl: photoUrl,
          advice: '',
          story: '',
          linkedIn: '',
          idCardUrl: idCardUrl,
          isVerified: false,
          menteeCount: 0,
          rating: 0,
          anonConfession: '',
          interviewRounds: [],
          targetRole: '',
          yearsOfExp: 0,
          createdAt: DateTime.now(),
        );
        await ref.read(authProvider.notifier).registerAlumni(alumni, _passwordController.text);
      } else if (_selectedRole == UserRole.admin) {
        if (_adminSecretController.text != AppConfig.adminSecretKey) {
          throw Exception("Invalid Admin Secret Key");
        }
        final admin = AdminModel(
          id: id,
          name: _nameController.text,
          email: _emailController.text,
          employeeId: _empIdController.text,
          department: '',
          photoUrl: '',
          createdAt: DateTime.now(),
        );
        await ref.read(authProvider.notifier).registerAdmin(admin, _passwordController.text);
      }

      if (mounted) context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
