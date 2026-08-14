import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/teacher_repository.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();
    final teacher = repo.teacher;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      teacher.name.isNotEmpty ? teacher.name[0] : 'T',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    teacher.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ID: ${teacher.id} • ${teacher.email}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.school, size: 16),
                    label: Text(teacher.schoolName),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.class_outlined, color: Colors.indigo),
                  title: const Text('Assigned Classes'),
                  subtitle: Text(teacher.assignedClasses.join(', ')),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.book_outlined, color: Colors.indigo),
                  title: const Text('Subjects Handled'),
                  subtitle: Text(teacher.subjects.join(', ')),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sync, color: Colors.teal),
                  title: const Text('Sync Engine Status'),
                  subtitle: Text(repo.isOnline ? 'Online - Auto Syncing Active' : 'Offline Mode Enabled'),
                  trailing: Switch(
                    value: repo.isOnline,
                    onChanged: (_) => repo.toggleOnlineStatus(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Core Philosophy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '“Every student is more than their marks.”\n\nThis application captures Academic Growth, Attendance, Activities, Talents, Achievements, and Positive Contributions to support complete student development.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
