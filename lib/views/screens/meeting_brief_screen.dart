import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/student_model.dart';
import '../../models/meeting_brief_model.dart';
import '../../services/teacher_repository.dart';
import '../../services/speech_ai_service.dart';
import '../widgets/speech_note_dialog.dart';

class MeetingBriefScreen extends StatefulWidget {
  final Student student;

  const MeetingBriefScreen({super.key, required this.student});

  @override
  State<MeetingBriefScreen> createState() => _MeetingBriefScreenState();
}

class _MeetingBriefScreenState extends State<MeetingBriefScreen> {
  bool _isSpeaking = false;
  late MeetingBrief _brief;

  @override
  void initState() {
    super.initState();
    _generateBrief();
  }

  void _generateBrief() {
    final s = widget.student;

    final primaryRiskFactors = <String>[];
    if (s.attendancePercentage < 75) {
      primaryRiskFactors.add('Chronic absenteeism: ${s.attendancePercentage}% attendance rate.');
    } else {
      primaryRiskFactors.add('Attendance level is currently stable at ${s.attendancePercentage}%.');
    }

    if (s.recentMarks.isNotEmpty) {
      final latest = s.recentMarks.first;
      if (latest.percentage < 55) {
        primaryRiskFactors.add('Failed latest assessment: Scored ${latest.marks.toInt()}/${latest.maxMarks.toInt()} in ${latest.subject}.');
      }
    }

    final skippingTriggers = <String>[];
    for (var sub in s.skippingAnxietySubjects) {
      skippingTriggers.add('High class-skipping anxiety triggered by: $sub');
    }
    if (s.schoolSkippingReasons.isNotEmpty) {
      skippingTriggers.addAll(s.schoolSkippingReasons);
    }

    final protectiveFactors = <String>[];
    s.positiveDimensions.forEach((key, val) {
      if (val >= 65) {
        protectiveFactors.add('Protective: Strong $key score of ${val.toInt()}%');
      }
    });

    final suggestedInterventions = <String>[];
    if (s.calculatedDropoutRiskLevel == 'High') {
      suggestedInterventions.add('Draft mandatory parent-school attendance contract.');
      suggestedInterventions.add('Relax homework timeline guidelines in anxiety subjects.');
    } else {
      suggestedInterventions.add('Assign student a peer-buddy helper.');
    }

    final actionPlan = [
      'Schedule counseling review next week.',
      'Log warning flags if homework triggers avoidance.',
    ];

    final conciseText =
        'Student ${s.name} (Risk: ${s.calculatedDropoutRiskLevel}) has ${s.attendancePercentage}% attendance and a ${s.academicAverage}% academic average. ' +
        (s.skippingAnxietySubjects.isNotEmpty ? 'Main risk trigger is anxiety in ${s.skippingAnxietySubjects.join(', ')} causing class skips. ' : '') +
        'Action: schedule early intervention parent meeting.';

    _brief = MeetingBrief(
      studentId: s.id,
      studentName: s.name,
      className: s.className,
      attendancePercentage: s.attendancePercentage,
      academicAverage: s.academicAverage,
      dropoutRiskScore: s.calculatedDropoutRiskScore,
      dropoutRiskLevel: s.calculatedDropoutRiskLevel,
      primaryRiskFactors: primaryRiskFactors,
      skippingTriggers: skippingTriggers,
      protectiveFactors: protectiveFactors,
      suggestedInterventions: suggestedInterventions,
      actionPlan: actionPlan,
      conciseText: conciseText,
    );
  }

  void _toggleTts() {
    final tts = context.read<SpeechAiService>();
    if (_isSpeaking) {
      tts.stopSpeaking(onStateChange: (speaking) {
        setState(() => _isSpeaking = speaking);
      });
    } else {
      tts.speakBrief(
        _brief.conciseText,
        onStateChange: (speaking) {
          setState(() => _isSpeaking = speaking);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();
    final currentStudent = repo.getStudentById(widget.student.id) ?? widget.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡 Early Intervention Brief'),
        actions: [
          IconButton(
            icon: Icon(_isSpeaking ? Icons.volume_off : Icons.volume_up, color: const Color(0xFF0D9488)),
            tooltip: _isSpeaking ? 'Stop Reading' : '🔊 Read Brief Aloud (TTS)',
            onPressed: _toggleTts,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Header Snapshot Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFEEF2FF),
                        child: Text(
                          currentStudent.name.isNotEmpty ? currentStudent.name[0] : 'S',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4F46E5)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentStudent.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              'Roll No: ${currentStudent.rollNumber} • Class ${currentStudent.className}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${currentStudent.calculatedDropoutRiskLevel} Risk',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // TTS Controls Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isSpeaking ? const Color(0xFFCCFBF1) : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(_isSpeaking ? Icons.graphic_eq : Icons.volume_up_rounded, color: const Color(0xFF0D9488), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isSpeaking ? 'Reading Brief Aloud...' : '🔊 Read Brief Aloud',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          icon: Icon(_isSpeaking ? Icons.pause : Icons.play_arrow, size: 14),
                          label: Text(_isSpeaking ? 'Pause' : 'Listen', style: const TextStyle(fontSize: 11)),
                          onPressed: _toggleTts,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Concise AI Brief Summary Box
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Dropout Prediction Analysis',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.amber.shade900, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _brief.conciseText,
                    style: TextStyle(fontSize: 12, height: 1.4, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Academic Snapshot Row
            Row(
              children: [
                Expanded(
                  child: _buildSnapshotTile('Attendance', '${_brief.attendancePercentage}%', currentStudent.attendanceTrend == 'declining' ? 'Declining ↓' : 'Stable ✓', currentStudent.attendanceTrend == 'declining' ? Colors.red : const Color(0xFF0D9488)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSnapshotTile('Risk Score', '${_brief.dropoutRiskScore.toInt()}%', currentStudent.calculatedDropoutRiskLevel == 'High' ? 'Urgent Alert ⚠' : 'Monitored', currentStudent.calculatedDropoutRiskLevel == 'High' ? Colors.red : const Color(0xFF0D9488)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Primary Risk Factors
            _buildSectionCard(
              title: '⚠ Primary Risk Drivers',
              icon: Icons.warning_amber_rounded,
              iconColor: Colors.red,
              items: _brief.primaryRiskFactors,
            ),
            const SizedBox(height: 10),

            // Skipping Triggers
            _buildSectionCard(
              title: '📉 Class-Skipping Triggers & Subject anxiety',
              icon: Icons.trending_down_rounded,
              iconColor: Colors.orange.shade800,
              items: _brief.skippingTriggers,
            ),
            const SizedBox(height: 10),

            // Protective Factors
            _buildSectionCard(
              title: '⭐ Protective / Cohesion Factors',
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF4F46E5),
              items: _brief.protectiveFactors,
            ),
            const SizedBox(height: 10),

            // Action Plan
            _buildSectionCard(
              title: '💡 Suggested Action & Interventions',
              icon: Icons.checklist_rounded,
              iconColor: const Color(0xFF0D9488),
              items: _brief.actionPlan,
            ),
            const SizedBox(height: 16),

            // Post-Meeting Speech Recording Action
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.mic_rounded, color: Color(0xFF9333EA), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🎤 Record Intervention Action Notes',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Speak meeting outcome and AI will extract structured prevention notes.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9333EA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.mic_rounded, size: 18),
                      label: const Text('Speak Intervention Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => SpeechNoteDialog(initialStudentId: currentStudent.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Previous Meetings History
            const Text(
              'Dropout Prevention Logs',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),

            if (currentStudent.previousMeetings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No previous recorded meetings for this student.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              )
            else
              ...currentStudent.previousMeetings.map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFCCFBF1),
                      radius: 18,
                      child: Icon(Icons.event_available_rounded, color: Color(0xFF0D9488), size: 16),
                    ),
                    title: Text(m.topic, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                    subtitle: Text('${m.outcome}\nDate: ${DateFormat('dd MMM yyyy').format(m.date)}', style: const TextStyle(fontSize: 11)),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotTile(String title, String val, String status, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(status, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<String> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
