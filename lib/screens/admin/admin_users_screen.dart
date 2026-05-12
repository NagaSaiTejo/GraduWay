// ignore_for_file: unused_import
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../data/mock/alumni_data.dart';
import '../../core/api_config.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'User Management',
        showBackButton: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.bgCard,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, roll no, or company...',
                prefixIcon: Icon(Icons.search_rounded),
                fillColor: AppColors.bgPage,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Students'),
              Tab(text: 'Alumni'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _UserListView(role: 'Student'),
                _UserListView(role: 'Alumni'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListView extends StatelessWidget {
  final String role;
  const _UserListView({required this.role});

  Future<List<_AdminUser>> _fetchUsers() async {
    final roleQuery = role.toLowerCase();
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/auth/admin/users?role=$roleQuery');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Could not fetch users');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final users = (decoded['users'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(_AdminUser.fromMap)
        .toList();

    if (users.isNotEmpty) return users;

    // Fallback keeps old behavior if backend has no data yet.
    if (role == 'Student') {
      return List.generate(
        10,
        (i) => _AdminUser(
          id: 'mock_student_$i',
          role: 'student',
          name: 'Student ${i + 1}',
          subtitle: '21K81A050${i + 1} • CSE',
          isBanned: false,
          isMock: true,
        ),
      );
    }

    return List.generate(
      10,
      (i) => _AdminUser(
        id: 'mock_alumni_$i',
        role: 'alumni',
        name: mockAlumni[i % mockAlumni.length].name,
        subtitle: mockAlumni[i % mockAlumni.length].company,
        isBanned: false,
        isMock: true,
      ),
    );
  }

  Future<void> _toggleBan(_AdminUser user) async {
    if (user.isMock) return;
    final endpoint =
        '${ApiConfig.baseUrl}/auth/admin/users/${user.role}/${user.id}/ban';
    await http.patch(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isBanned': !user.isBanned}),
    );
  }

  Future<void> _removeUser(_AdminUser user) async {
    if (user.isMock) return;
    final endpoint =
        '${ApiConfig.baseUrl}/auth/admin/users/${user.role}/${user.id}';
    await http.delete(Uri.parse(endpoint));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_AdminUser>>(
      future: _fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Could not load users right now.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        final users = snapshot.data ?? const <_AdminUser>[];
        if (users.isEmpty) {
          return const Center(
            child: Text(
              'No users found.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final user = users[i];
            final name = user.name;
            final sub = user.subtitle;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(name.isEmpty ? '?' : name[0].toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
                title: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                subtitle: Text(sub,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) async {
                    try {
                      if (value == 'ban') {
                        await _toggleBan(user);
                      } else if (value == 'remove') {
                        await _removeUser(user);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Action completed for $name')),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Action failed. Please try again.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'ban',
                      child: Text(
                        user.isBanned ? 'Unban User' : 'Ban User',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('Remove User',
                          style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: i * 50))
                .slideY(begin: 0.1);
          },
        );
      },
    );
  }
}

class _AdminUser {
  final String id;
  final String role;
  final String name;
  final String subtitle;
  final bool isBanned;
  final bool isMock;

  const _AdminUser({
    required this.id,
    required this.role,
    required this.name,
    required this.subtitle,
    required this.isBanned,
    required this.isMock,
  });

  factory _AdminUser.fromMap(Map<String, dynamic> map) {
    final role = (map['role']?.toString() ?? '').toLowerCase();
    final branch = map['branch']?.toString() ?? '';
    final roll = map['rollNumber']?.toString() ?? '';
    final company = map['company']?.toString() ?? '';
    final subtitle = role == 'student'
        ? [roll, branch].where((e) => e.isNotEmpty).join(' • ')
        : company;

    return _AdminUser(
      id: map['id']?.toString() ?? '',
      role: role,
      name: map['name']?.toString() ?? 'Unknown User',
      subtitle: subtitle.isEmpty ? (map['email']?.toString() ?? '') : subtitle,
      isBanned: map['isBanned'] == true,
      isMock: false,
    );
  }
}
