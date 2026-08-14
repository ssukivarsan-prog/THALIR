import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/teacher_repository.dart';

class TalentMapScreen extends StatelessWidget {
  const TalentMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();
    final students = repo.students;

    final categories = {
      '⚠ Chronic Absenteeism Risk': students.where((s) => s.attendancePercentage < 75).length,
      '📚 Mathematics Failure Risk': students.where((s) => s.skippingAnxietySubjects.contains('Mathematics')).length,
      '💻 Computer Skills Anxiety': students.where((s) => s.skippingAnxietySubjects.contains('Python Programming')).length,
      '💬 Counseling Consultations Logged': students.where((s) => s.previousMeetings.isNotEmpty).length,
      '🛡 Active Preventive Interventions': students.where((s) => s.interventions.isNotEmpty).length,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Class ${repo.teacher.activeClass} Risk Warning Map', maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.redAccent, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This Early Warning Risk Map lists key dropout triggers and subject anxiety indicators across the class, highlighting active preventative interventions.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Early Warning Risk Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...categories.entries.map((e) {
              final totalStudents = students.isNotEmpty ? students.length.toDouble() : 42.0;
              final percentage = (e.value / totalStudents).clamp(0.0, 1.0);
              final isRedAlert = e.key.contains('Chronic') || e.key.contains('Failure');
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              e.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('${e.value} Students', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: isRedAlert ? Colors.red.shade50 : Colors.indigo.shade50,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 8,
                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                          color: isRedAlert ? Colors.redAccent : Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
