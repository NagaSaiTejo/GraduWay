import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class AtsCheckScreen extends StatefulWidget {
  const AtsCheckScreen({super.key});

  @override
  State<AtsCheckScreen> createState() => _AtsCheckScreenState();
}

class _AtsCheckScreenState extends State<AtsCheckScreen> {
  final _jdController = TextEditingController();

  PlatformFile? _resumeFile;
  bool _isLoading = false;
  Map<String, dynamic>? _analysis;

  @override
  void dispose() {
    _jdController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    setState(() {
      _resumeFile = result.files.first;
    });
  }

  Future<void> _analyzeResume() async {
    final jd = _jdController.text.trim();

    if (_resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a resume PDF first.')),
      );
      return;
    }

    if (jd.length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a detailed job description.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _analysis = null;
    });

    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(ApiConfig.atsScore));
      request.fields['jd'] = jd;

      final bytes = _resumeFile!.bytes;
      if (bytes == null) {
        throw Exception(
            'Unable to read selected file bytes. Please reselect the PDF.');
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'resume',
          bytes,
          filename: _resumeFile!.name,
        ),
      );

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        setState(() {
          _analysis = jsonDecode(response.body) as Map<String, dynamic>;
        });
      } else {
        final body =
            response.body.isNotEmpty ? response.body : 'Unknown server error';
        throw Exception('ATS request failed (${response.statusCode}): $body');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to analyze resume: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'AI Resume Scan', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Upload your resume and compare it with a target job description using Gemini-powered ATS analysis.',
                style:
                    TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 20),
            const Text(
              'Resume PDF',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded,
                      color: AppColors.error),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _resumeFile?.name ?? 'No file selected',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: _isLoading ? null : _pickResume,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Choose'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Job Description',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _jdController,
              maxLines: 8,
              minLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Paste role requirements, skills, responsibilities, and preferred qualifications...',
                fillColor: AppColors.bgCard,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _analyzeResume,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics_rounded),
                label: Text(_isLoading ? 'Analyzing...' : 'Analyze Resume'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (_analysis != null) ...[
              const SizedBox(height: 26),
              _ResultCard(analysis: _analysis!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const _ResultCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final score = analysis['score']?.toString() ?? '0';
    final summary = analysis['summary']?.toString() ?? 'No summary returned.';

    List<String> listFrom(String key) {
      final value = analysis[key];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return const [];
    }

    final strengths = listFrom('strengths');
    final weaknesses = listFrom('weaknesses');
    final missing = listFrom('missingKeywords');

    Widget section(String title, List<String> items, Color color) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('No data returned.',
                style: TextStyle(color: AppColors.textMuted)),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ',
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold)),
                  Expanded(
                      child: Text(e, style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('ATS Score: $score',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(summary, style: const TextStyle(height: 1.35)),
          const SizedBox(height: 16),
          section('Strengths', strengths, AppColors.success),
          section('Weaknesses', weaknesses, AppColors.warning),
          section('Missing Keywords', missing, AppColors.error),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}
