import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/speech_ai_service.dart';
import '../../services/teacher_repository.dart';

class SpeechNoteDialog extends StatefulWidget {
  final String? initialStudentId;

  const SpeechNoteDialog({super.key, this.initialStudentId});

  @override
  State<SpeechNoteDialog> createState() => _SpeechNoteDialogState();
}

class _SpeechNoteDialogState extends State<SpeechNoteDialog> {
  bool _isListening = false;
  bool _isParsed = false;
  String _selectedStudentId = 'std-23VIII001';
  final TextEditingController _transcriptController = TextEditingController();

  ParsedSpeechOutcome? _parsedOutcome;

  @override
  void initState() {
    super.initState();
    if (widget.initialStudentId != null) {
      _selectedStudentId = widget.initialStudentId!;
    }
  }

  void _startSpeechToText() async {
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
        onResult: (text) {
          setState(() => _transcriptController.text = text);
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
                'Microphone is unavailable in this environment (e.g. emulator/simulator).\n\nType what you would like to speak to test the AI parser:',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: simController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g., "Student struggles in Science concepts. Scheduled remedial coaching after school. Follow up in 3 days."',
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
                  setState(() {
                    _transcriptController.text = text;
                  });
                }
              },
              child: const Text('Simulate Speak'),
            ),
          ],
        );
      },
    );
  }

  void _extractStructuredInfo() {
    final speechService = context.read<SpeechAiService>();
    final outcome = speechService.parseSpeechToOutcome(_transcriptController.text);
    setState(() {
      _parsedOutcome = outcome;
      _isParsed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();
    final students = repo.students;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.mic, color: Colors.purple),
          ),
          const SizedBox(width: 10),
          const Text('🎤 Voice Note & AI Parser', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Selector
            DropdownButtonFormField<String>(
              value: _selectedStudentId,
              decoration: const InputDecoration(
                labelText: 'Select Student',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

            // Microphone record button & Status waveform animation
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isListening ? null : _startSpeechToText,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening ? Colors.red : Colors.purple,
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.red : Colors.purple).withValues(alpha: 0.4),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.graphic_eq : Icons.mic,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isListening ? 'Listening & Transcribing...' : 'Tap to Record Voice Note',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _isListening ? Colors.red : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Transcribed Note Field
            const Text('Transcribed Note:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _transcriptController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Speak or type note...',
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 42),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Extract Structured Information'),
              onPressed: _extractStructuredInfo,
            ),

            if (_isParsed && _parsedOutcome != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.teal, size: 18),
                        SizedBox(width: 6),
                        Text('AI Extracted Outcome', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13)),
                      ],
                    ),
                    const Divider(),
                    ..._parsedOutcome!.keyValues.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.key}: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Expanded(child: Text(e.value, style: const TextStyle(fontSize: 12))),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          onPressed: () {
            repo.addObservation(
              studentId: _selectedStudentId,
              category: 'Voice Outcome',
              text: _transcriptController.text,
              isVoiceDerived: true,
              localAudioPath: 'mock_voice_recording.m4a',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✓ Voice note observation saved to student profile!')),
            );
            Navigator.pop(context);
          },
          child: const Text('Confirm & Save'),
        ),
      ],
    );
  }
}
