import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';

class AdminVerificationScreen extends ConsumerWidget {
  const AdminVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseServiceProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Pending Verifications'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: db.getPendingVerifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pending verifications'));
          }

          final pending = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final user = pending[index];
              final String name = user['name'] ?? 'Unknown';
              final String role = user['role'] ?? 'student';
              final String email = user['email'] ?? '';
              final String id = user['_id'].toHexString();

              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: Text('$role • $email'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () async {
                          await db.verifyUser(id, role, true);
                          (context as Element).markNeedsBuild(); // Force refresh
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          await db.verifyUser(id, role, false);
                          (context as Element).markNeedsBuild(); // Force refresh
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Show details dialog with ID Card/Resume
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('$name Profile'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Role: $role'),
                            Text('Email: $email'),
                            if (role == 'student') Text('Roll: ${user['rollNumber']}'),
                            if (role == 'alumni') Text('Company: ${user['company']}'),
                            const SizedBox(height: 16),
                            const Text('Attached Documents:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(role == 'student' ? 'Resume: Available' : 'ID Card: Available'),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
