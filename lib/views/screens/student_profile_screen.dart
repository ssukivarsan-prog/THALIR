import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/student_model.dart';
import '../../services/teacher_repository.dart';
import 'meeting_brief_screen.dart';
import 'activity_recording_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  final Student student;

  const StudentProfileScreen({super.key, required this.student});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange.shade700;
      default: return Colors.green;
    }
  }

  Color _getRiskBgColor(String riskLevel) {
    switch (riskLevel) {
      case 'High': return Colors.red.shade50;
      case 'Medium': return Colors.orange.shade50;
      default: return Colors.green.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();
    final currentStudent = repo.getStudentById(widget.student.id) ?? widget.student;
    final riskLevel = currentStudent.calculatedDropoutRiskLevel;
    final riskScore = currentStudent.calculatedDropoutRiskScore.toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentStudent.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt, color: Colors.amber),
            tooltip: 'Prepare Prevention Brief',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MeetingBriefScreen(student: currentStudent),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Record Intervention',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ActivityRecordingScreen(preselectedStudentId: currentStudent.id),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '📊 Risk Overview'),
            Tab(text: '📚 Subject Struggle'),
            Tab(text: '📅 Absence Patterns'),
            Tab(text: '📝 Interventions & Notes'),
            Tab(text: '🕒 Warning Timeline'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Student 360° Header Summary
          Container(
            padding: const EdgeInsets.all(14),
            color: _getRiskBgColor(riskLevel),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _getRiskColor(riskLevel),
                  child: Text(
                    currentStudent.name.isNotEmpty ? currentStudent.name[0] : 'S',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStudent.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'ID: ${currentStudent.rollNumber} • Class ${currentStudent.className}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dropout Risk Status: $riskLevel ($riskScore%)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getRiskColor(riskLevel)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(currentStudent),
                _buildAcademicsTab(currentStudent),
                _buildAttendanceTab(currentStudent),
                _buildInterventionsTab(currentStudent),
                _buildTimelineTab(currentStudent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Overview Tab
  Widget _buildOverviewTab(Student s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('Attendance Rate', '${s.attendancePercentage}%', s.attendanceTrend == 'declining' ? 'Declining ↓' : 'Stable ✓', s.attendanceTrend == 'declining' ? Colors.red : Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricCard('Academic Average', '${s.academicAverage}%', s.academicTrend == 'declining' ? 'Declining ↓' : 'Stable ✓', s.academicTrend == 'declining' ? Colors.red : Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text('Primary Warning Factors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          if (s.dropoutRiskProfile.primaryRiskFactors.isEmpty)
            const Text('No current warning flags detected.', style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            ...s.dropoutRiskProfile.primaryRiskFactors.map((factor) {
              return Card(
                color: const Color(0xFFFEF3C7),
                margin: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                  title: Text(factor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF92400E))),
                ),
              );
            }),
          const SizedBox(height: 16),

          const Text('Protective Indicators', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text('Factors keeping student tied to school cohesion.', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          const SizedBox(height: 10),

          ...s.positiveDimensions.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('${e.value.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF4F46E5))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: e.value / 100.0,
                      minHeight: 6,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      color: e.value >= 70 ? Colors.green : (e.value >= 50 ? const Color(0xFF4F46E5) : Colors.amber),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 2. Subject Struggle Tab
  Widget _buildAcademicsTab(Student s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subjects Causing School-Skipping Anxiety', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          if (s.skippingAnxietySubjects.isEmpty)
            const Text('No school-skipping anxiety subjects recorded.', style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            Wrap(
              spacing: 8,
              children: s.skippingAnxietySubjects.map((sub) {
                return Chip(
                  avatar: const Icon(Icons.crisis_alert_rounded, color: Colors.red, size: 14),
                  label: Text(sub, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                  backgroundColor: Colors.red.shade50,
                  side: BorderSide(color: Colors.red.shade200),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),

          const Text('Recent Assessment & Fail Risk History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ...s.recentMarks.map((m) {
            final isFailRisk = m.percentage < 55;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isFailRisk ? Colors.red.shade200 : const Color(0xFFE2E8F0))),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: CircleAvatar(
                  backgroundColor: isFailRisk ? Colors.red.shade50 : const Color(0xFFEEF2FF),
                  radius: 18,
                  child: Icon(Icons.book, color: isFailRisk ? Colors.red : const Color(0xFF4F46E5), size: 16),
                ),
                title: Text('${m.subject} - ${m.assessmentName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text('Date: ${DateFormat('dd MMM yyyy').format(m.date)}', style: const TextStyle(fontSize: 11)),
                trailing: Text(
                  '${m.marks.toInt()}/${m.maxMarks.toInt()} (${m.percentage.toInt()}%)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isFailRisk ? Colors.red : Colors.green,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // 3. Attendance Tab
  Widget _buildAttendanceTab(Student s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Overall Term Attendance', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text('${s.attendancePercentage}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  const SizedBox(height: 6),
                  Text(
                    s.attendanceTrend == 'declining' ? '⚠ Declining attendance increases dropout risk' : '✓ Attendance stable',
                    style: TextStyle(color: s.attendanceTrend == 'declining' ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Specific School-Skipping Triggers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          if (s.schoolSkippingReasons.isEmpty)
            const Text('No triggers logged.', style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            ...s.schoolSkippingReasons.map((reason) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right, color: Colors.red),
                    Expanded(child: Text(reason, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // 4. Interventions Tab
  Widget _buildInterventionsTab(Student s) {
    final repo = context.watch<TeacherRepository>();
    final studentRecs = repo.recommendations.where((r) => r.studentId == s.id).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Municipal 4-Pillar Recommendations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.indigo)),
          const SizedBox(height: 10),
          if (studentRecs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No municipal 4-pillar recommendations logged yet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          else
            ...studentRecs.map((rec) {
              Color statusColor = Colors.orange.shade700;
              if (rec.status.contains('Municipality')) {
                statusColor = Colors.green;
              } else if (rec.status.contains('Approved')) {
                statusColor = Colors.blue;
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: statusColor.withOpacity(0.3))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    radius: 18,
                    child: Icon(Icons.account_balance, color: statusColor, size: 16),
                  ),
                  title: Text('${rec.pillarType.replaceAll('_', ' ').toUpperCase()}: ${rec.targetEntity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Notes: ${rec.reasonNotes}', style: const TextStyle(fontSize: 11)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rec.status,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),

          const Text('Active Prevention Interventions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          if (s.interventions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No prevention interventions logged yet.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          else
            ...s.interventions.map((interv) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEEF2FF),
                    radius: 18,
                    child: Icon(Icons.shield, color: Color(0xFF4F46E5), size: 16),
                  ),
                  title: Text(interv.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('${interv.description}\nAction taken: ${interv.actionTaken}', style: const TextStyle(fontSize: 11)),
                ),
              );
            }),
          const SizedBox(height: 20),

          const Text('Teacher Early Warning Observations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          if (s.observations.isEmpty)
            const Text('No warning observations logged.', style: TextStyle(color: Colors.grey, fontSize: 12))
          else
            ...s.observations.map((obs) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  leading: Icon(obs.isVoiceDerived ? Icons.mic : Icons.note_alt, color: const Color(0xFF4F46E5), size: 20),
                  title: Text(obs.category, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text(obs.text, style: const TextStyle(fontSize: 11)),
                  trailing: Text(DateFormat('dd MMM').format(obs.date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              );
            }),
        ],
      ),
    );
  }

  // 5. Timeline Tab
  Widget _buildTimelineTab(Student s) {
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: s.timeline.length,
      itemBuilder: (ctx, i) {
        final ev = s.timeline[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: Text(ev.badgeIcon ?? '📌', style: const TextStyle(fontSize: 20)),
            title: Text(ev.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('${ev.description}\n${DateFormat('dd MMM yyyy, hh:mm a').format(ev.date)}', style: const TextStyle(fontSize: 11)),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String val, String status, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 2),
            Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
