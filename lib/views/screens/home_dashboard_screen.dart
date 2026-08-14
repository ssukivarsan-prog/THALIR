import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/teacher_repository.dart';
import 'ocr_scanner_screen.dart';
import 'meeting_brief_screen.dart';
import 'activity_recording_screen.dart';
import '../widgets/speech_note_dialog.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();
    final teacher = repo.teacher;
    final students = repo.students;
    final upcomingMeetings = repo.upcomingMeetings;
    final screenWidth = MediaQuery.of(context).size.width;

    final highRiskCount = students.where((s) => s.calculatedDropoutRiskLevel == 'High').length;
    final lowAttCount = students.where((s) => s.attendancePercentage < 75).length;
    final activeInterv = students.fold(0, (sum, s) => sum + s.interventions.length);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Greeting Banner with soft indigo-teal gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE11D48), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${_getGreeting()}, ${teacher.name.split(' ').first} 🛡',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Class ${teacher.activeClass}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Dropout Prevention System • Monitoring ${students.length} students',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFFE4E6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Today's Summary Section
          const Text(
            'Dropout Warning Indicators',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'High Risk Alert',
                  value: '$highRiskCount',
                  icon: Icons.error_outline_rounded,
                  color: Colors.red,
                  bgColor: Colors.red.shade50,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Absence Warning',
                  value: '$lowAttCount',
                  icon: Icons.running_with_errors_rounded,
                  color: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFEF3C7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  title: 'Interventions',
                  value: '$activeInterv',
                  icon: Icons.shield_outlined,
                  color: const Color(0xFF0D9488),
                  bgColor: const Color(0xFFCCFBF1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Quick Action Bar
          const Text(
            'Action Loggers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildActionButton(
                context,
                width: (screenWidth - 42) / 2,
                label: 'Scan Attendance',
                icon: Icons.qr_code_scanner_rounded,
                color: const Color(0xFF4F46E5),
                bgColor: const Color(0xFFEEF2FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OcrScannerScreen(initialTab: 0),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                width: (screenWidth - 42) / 2,
                label: 'Scan Test Marks',
                icon: Icons.fact_check_rounded,
                color: const Color(0xFF0D9488),
                bgColor: const Color(0xFFCCFBF1),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OcrScannerScreen(initialTab: 1),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                width: (screenWidth - 42) / 2,
                label: 'Log Risk Signal',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ActivityRecordingScreen(),
                    ),
                  );
                },
              ),
              _buildActionButton(
                context,
                width: (screenWidth - 42) / 2,
                label: 'Log Voice Note',
                icon: Icons.mic_rounded,
                color: const Color(0xFF9333EA),
                bgColor: const Color(0xFFF3E8FF),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const SpeechNoteDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 22),

          // My Classes Overview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monitoring Classes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Active: Class ${teacher.activeClass}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF4F46E5), fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: teacher.assignedClasses.asMap().entries.map((entry) {
              final idx = entry.key;
              final cls = entry.value;
              final isSelected = cls == teacher.activeClass;
              final count = cls == 'VIII-A' ? 42 : 39;
              return Expanded(
                child: InkWell(
                  onTap: () => repo.setActiveClass(cls),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: EdgeInsets.only(right: idx < teacher.assignedClasses.length - 1 ? 8 : 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Class $cls',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF0F172A),
                              ),
                            ),
                            if (isSelected) const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF4F46E5)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count Students Monitored',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          // Upcoming Meetings & Briefs Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scheduled Interventions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${upcomingMeetings.length} Pending',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (upcomingMeetings.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'No prevention meetings scheduled today.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ),
              ),
            )
          else
            ...upcomingMeetings.map((meeting) {
              final student = repo.getStudentById(meeting.studentId) ?? students.first;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFFEF3C7),
                        child: Text(
                          student.name.isNotEmpty ? student.name[0] : 'S',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${student.name} (${student.rollNumber})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text('Topic: ${meeting.topic}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D48),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.bolt_rounded, size: 14),
                        label: const Text('Brief', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MeetingBriefScreen(student: student),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 12),

          // Core Philosophy Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: Color(0xFFE11D48), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '“Predict dropout. Target anxiety. Save students.”',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFFBE123C)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'OCR Data → Dynamic Risk Level → Custom Prevention Plans',
                        style: TextStyle(fontSize: 10, color: Color(0xFF4B5563)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required double width,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
