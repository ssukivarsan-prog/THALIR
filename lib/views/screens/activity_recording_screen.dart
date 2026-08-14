import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/activity_model.dart';
import '../../services/teacher_repository.dart';
import '../../services/speech_ai_service.dart';
import 'talent_map_screen.dart';

class ActivityRecordingScreen extends StatefulWidget {
  final String? preselectedStudentId;

  const ActivityRecordingScreen({super.key, this.preselectedStudentId});

  @override
  State<ActivityRecordingScreen> createState() => _ActivityRecordingScreenState();
}

class _ActivityRecordingScreenState extends State<ActivityRecordingScreen> {
  late String _selectedStudentId;
  int _activeFormIndex = 0; // 0 = Classroom Intervention, 1 = 4-Pillar Municipal Recommendation

  // Form 1: Classroom Intervention
  InterventionCategory _selectedCategory = InterventionCategory.warningFlagged;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();

  // Form 2: 4-Pillar Recommendation
  String _selectedPillar = 'scholarship'; // "scholarship", "hostel", "subject_coaching", or "extracurricular_talent"
  final TextEditingController _targetEntityController = TextEditingController();
  final TextEditingController _reasonNotesController = TextEditingController();

  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _selectedStudentId = widget.preselectedStudentId ?? 'std-23VIII001';
  }

  void _processTranscript(String transcript) {
    final speechService = context.read<SpeechAiService>();
    if (_activeFormIndex == 0) {
      final parsed = speechService.parseSpeechToIntervention(transcript);
      setState(() {
        _titleController.text = parsed.title;
        _selectedCategory = parsed.category;
        _descriptionController.text = parsed.description;
        _actionController.text = parsed.actionTaken;
      });
    } else {
      setState(() {
        _reasonNotesController.text = transcript;
      });
    }
  }

  void _speechToIntervention() async {
    final speechService = context.read<SpeechAiService>();
    final isAvailable = await speechService.initSpeech();

    if (!isAvailable) {
      // Microphone not available (e.g., emulator/simulator).
      // Show simulated speech dialog so the user can enter custom text to test parsing.
      _showSimulatedSpeechDialog();
      return;
    }

    if (_isListening) {
      speechService.stopListening(
        onStateChange: (listening) {
          setState(() => _isListening = listening);
        },
      );
    } else {
      speechService.startListening(
        onResult: (transcript) {
          _processTranscript(transcript);
        },
        onStateChange: (listening) {
          setState(() => _isListening = listening);
        },
      );
    }
  }

  void _showSimulatedSpeechDialog() {
    final TextEditingController simController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.mic, color: Colors.purple),
              SizedBox(width: 8),
              Text('Simulate Voice Input', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Microphone is unavailable in this environment (e.g. emulator/simulator).\n\nType what you would like to speak to test the AI parsing logic:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: simController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g., "Student missed math class due to test anxiety, scheduled counseling session."',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final text = simController.text.trim();
                Navigator.pop(context);
                if (text.isNotEmpty) {
                  _processTranscript(text);
                }
              },
              child: const Text('Simulate Speak'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();
    final students = repo.students;
    final activeStudent = repo.getStudentById(_selectedStudentId) ?? (students.isNotEmpty ? students.first : null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡 Early Warning & Intervention'),
        actions: [
          IconButton(
            icon: const Icon(Icons.hub_outlined),
            tooltip: 'View Early Warning Map',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TalentMapScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speech Dictation Banner
            Card(
              elevation: 0,
              color: Colors.purple.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(
                        _isListening ? Icons.hearing : Icons.mic_none,
                        color: Colors.purple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isListening ? 'Listening to voice dictation...' : 'Use Speech Recognition',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isListening ? 'Tap mic to stop and parse.' : 'Tap mic and speak to dictate notes.',
                            style: TextStyle(fontSize: 11, color: Colors.purple.shade900),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isListening ? Colors.red : Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: _speechToIntervention,
                      child: Text(_isListening ? 'Stop' : 'Talk'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Form Type Segmented Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeFormIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeFormIndex == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _activeFormIndex == 0
                              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Text(
                          'Classroom Intervention',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _activeFormIndex == 0 ? Colors.indigo : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _activeFormIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeFormIndex == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _activeFormIndex == 1
                              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Text(
                          '4-Pillar Municipal Rec',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _activeFormIndex == 1 ? Colors.indigo : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Student Selector
            const Text('Target Student', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedStudentId,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: students.map((s) {
                return DropdownMenuItem(
                  value: s.id,
                  child: Text('${s.name} (${s.rollNumber})'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStudentId = val);
              },
            ),
            const SizedBox(height: 16),

            // Active Form Rendering
            if (_activeFormIndex == 0) ...[
              // FORM 0: Classroom Intervention
              const Text('Intervention Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<InterventionCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: InterventionCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(_getCategoryLabel(cat)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Warning / Action Title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Warning Description / Root Cause',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _actionController,
                decoration: InputDecoration(
                  labelText: 'Corrective Action Taken',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else ...[
              // FORM 1: 4-Pillar Recommendation
              const Text('Municipal 4-Pillar Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPillar,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'scholarship', child: Text('🎓 Scholarship Assistance')),
                  DropdownMenuItem(value: 'hostel', child: Text('🏠 Welfare Hostel Accommodation')),
                  DropdownMenuItem(value: 'subject_coaching', child: Text('📚 Remedial Subject Coaching')),
                  DropdownMenuItem(value: 'extracurricular_talent', child: Text('🎨 Extracurricular Talent Support')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedPillar = val;
                      if (val == 'scholarship') {
                        _targetEntityController.text = 'Agaram Foundation Educational Scholarship';
                      } else if (val == 'hostel') {
                        _targetEntityController.text = 'Govt BC Welfare Hostel';
                      } else if (val == 'subject_coaching') {
                        _targetEntityController.text = 'Morning remedial math tutorial league';
                      } else {
                        _targetEntityController.text = 'SDAT Tamil Nadu Sports Quota';
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _targetEntityController,
                decoration: InputDecoration(
                  labelText: 'Target Support Entity / Organization',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _reasonNotesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Detailed Reason & Background Notes',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Early Warning Prediction Engine preview
            if (activeStudent != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                        SizedBox(width: 8),
                        Text('Early Warning Prediction Engine', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This event updates ${activeStudent.name}\'s profile. Current risk level is: ${activeStudent.calculatedDropoutRiskLevel}.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Save Action Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(_activeFormIndex == 0 ? Icons.save : Icons.send),
              label: Text(
                _activeFormIndex == 0 ? 'Log Classroom Intervention' : 'Submit 4-Pillar Recommendation',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () {
                if (_activeFormIndex == 0) {
                  repo.addStudentIntervention(
                    studentId: _selectedStudentId,
                    title: _titleController.text,
                    category: _selectedCategory,
                    description: _descriptionController.text,
                    actionTaken: _actionController.text,
                    localAttachmentPaths: const ['mock_intervention_video.mp4', 'mock_parent_signature.jpg'],
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ Early warning logged! Dropout risk model updated.')),
                  );
                } else {
                  repo.addInterventionRecommendation(
                    studentId: _selectedStudentId,
                    pillarType: _selectedPillar,
                    targetEntity: _targetEntityController.text,
                    reasonNotes: _reasonNotesController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ 4-Pillar support recommendation submitted to Principal!')),
                  );
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel(InterventionCategory cat) {
    switch (cat) {
      case InterventionCategory.counseling: return '💬 Counseling';
      case InterventionCategory.remedialSupport: return '📚 Remedial support';
      case InterventionCategory.parentContact: return '🤝 Parent contact';
      case InterventionCategory.peerMentorship: return '👥 Peer mentorship';
      case InterventionCategory.attendanceContract: return '📅 Attendance contract';
      case InterventionCategory.warningFlagged: return '⚠ Warning flagged';
    }
  }
}
