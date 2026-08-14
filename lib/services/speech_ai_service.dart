import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/activity_model.dart';

class ParsedSpeechIntervention {
  final String title;
  final InterventionCategory category;
  final String description;
  final String actionTaken;

  ParsedSpeechIntervention({
    required this.title,
    required this.category,
    required this.description,
    required this.actionTaken,
  });
}

class ParsedSpeechOutcome {
  final String academicStatus;
  final String skillGap;
  final String requestedSupport;
  final String? followUpDays;
  final Map<String, String> keyValues;

  ParsedSpeechOutcome({
    required this.academicStatus,
    required this.skillGap,
    required this.requestedSupport,
    this.followUpDays,
    required this.keyValues,
  });
}

class SpeechAiService {
  late final FlutterTts? _tts;
  late final stt.SpeechToText? _speech;
  
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _sttInitialized = false;

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;

  SpeechAiService() {
    if (kDebugMode && Platform.environment.containsKey('FLUTTER_TEST')) {
      _tts = null;
      _speech = null;
      return;
    }

    try {
      _tts = FlutterTts();
      _speech = stt.SpeechToText();
      _initTts();
    } catch (e) {
      debugPrint("Speech plugins initialization error: $e");
      _tts = null;
      _speech = null;
    }
  }

  void _initTts() async {
    final tts = _tts;
    if (tts == null) return;
    try {
      final isAvailable = await tts.isLanguageAvailable("en-IN");
      if (isAvailable == true) {
        await tts.setLanguage("en-IN");
      } else {
        await tts.setLanguage("en-US");
      }
      await tts.setSpeechRate(0.38); // Slower speech rate (default was 0.45)
      await tts.setVolume(1.0);
      await tts.setPitch(1.0);
    } catch (e) {
      debugPrint("TTS configuration error: $e");
    }
  }

  // Initialize Speech-to-Text on demand
  Future<bool> initSpeech() async {
    final speech = _speech;
    if (speech == null) return false;
    if (_sttInitialized) return true;
    try {
      _sttInitialized = await speech.initialize(
        onStatus: (status) => debugPrint('STT Status: $status'),
        onError: (err) => debugPrint('STT Error: $err'),
      );
      return _sttInitialized;
    } catch (e) {
      debugPrint("STT initialization exception: $e");
      return false;
    }
  }

  // Real Text-to-Speech Synthesis
  void speakBrief(String text, {required Function(bool) onStateChange, Function()? onComplete}) async {
    final tts = _tts;
    if (tts == null) {
      // Offline/Test Simulation fallback
      _isSpeaking = true;
      onStateChange(true);
      final durationSeconds = (text.length / 15).clamp(3.0, 10.0).toInt();
      Timer(Duration(seconds: durationSeconds), () {
        _isSpeaking = false;
        onStateChange(false);
        if (onComplete != null) onComplete();
      });
      return;
    }

    try {
      _isSpeaking = true;
      onStateChange(true);

      tts.setStartHandler(() {
        _isSpeaking = true;
        onStateChange(true);
      });

      tts.setCompletionHandler(() {
        _isSpeaking = false;
        onStateChange(false);
        if (onComplete != null) onComplete();
      });

      tts.setErrorHandler((msg) {
        _isSpeaking = false;
        onStateChange(false);
        debugPrint("TTS audio synthesis error: $msg");
      });

      await tts.speak(text);
    } catch (e) {
      debugPrint("TTS speak failed: $e");
      _isSpeaking = false;
      onStateChange(false);
    }
  }

  void stopSpeaking({required Function(bool) onStateChange}) async {
    final tts = _tts;
    if (tts != null) {
      await tts.stop();
    }
    _isSpeaking = false;
    onStateChange(false);
  }

  // Real Speech-to-Text Voice Dictation with auto emulator simulation
  void startListening({
    required Function(String) onResult,
    required Function(bool) onStateChange,
  }) async {
    final speech = _speech;
    final available = await initSpeech();
    if (!available || speech == null) {
      debugPrint("Microphone Speech Recognition unavailable (simulation mode active)...");
      _isListening = true;
      onStateChange(true);
      
      // Simulate voice typing after 3 seconds
      Timer(const Duration(seconds: 3), () {
        _isListening = false;
        onStateChange(false);
        onResult("Student is experiencing mathematics failure anxiety. Recommended parent contact.");
      });
      return;
    }

    try {
      _isListening = true;
      onStateChange(true);
      await speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
          if (result.finalResult) {
            _isListening = false;
            onStateChange(false);
          }
        },
      );
    } catch (e) {
      debugPrint("Microphone listen failed: $e");
      _isListening = false;
      onStateChange(false);
    }
  }

  void stopListening({required Function(bool) onStateChange}) async {
    final speech = _speech;
    if (speech != null && speech.isListening) {
      await speech.stop();
    }
    _isListening = false;
    onStateChange(false);
  }

  // AI Speech-to-Structured Intervention Extractor
  ParsedSpeechIntervention parseSpeechToIntervention(String transcript) {
    final lower = transcript.toLowerCase();
    
    // 1. Detect Subject
    String? subject;
    if (lower.contains('math')) {
      subject = 'Mathematics';
    } else if (lower.contains('python') || lower.contains('coding') || lower.contains('programming')) {
      subject = 'Python Programming';
    } else if (lower.contains('science')) {
      subject = 'Science';
    } else if (lower.contains('english') || lower.contains('reading') || lower.contains('language')) {
      subject = 'English';
    } else if (lower.contains('computer') || lower.contains('digital')) {
      subject = 'Computer Skills';
    }

    // 2. Detect Concern / Reason
    String? concern;
    if (lower.contains('anxi') || lower.contains('stress') || lower.contains('fear') || lower.contains('scared') || lower.contains('nervous')) {
      concern = 'Anxiety Support';
    } else if (lower.contains('absent') || lower.contains('missed') || lower.contains('skip') || lower.contains('skipping') || lower.contains('leave')) {
      concern = 'Attendance Deficit';
    } else if (lower.contains('fail') || lower.contains('grades') || lower.contains('marks') || lower.contains('struggle') || lower.contains('poor')) {
      concern = 'Academic Support';
    }

    // 3. Category & Action Extraction
    InterventionCategory category = InterventionCategory.warningFlagged;
    String actionTaken = "Logged warning flag";
    String title = "Warning Alert Logged";

    if (lower.contains('counseling') || lower.contains('counsel') || lower.contains('anxious') || lower.contains('anxiety')) {
      category = InterventionCategory.counseling;
      final topic = subject ?? concern ?? 'Student Needs';
      title = "$topic Counseling Support";
      actionTaken = "Conducted one-on-one counseling session regarding $topic.";
    } else if (lower.contains('remedial') || lower.contains('tutorial') || lower.contains('coaching') || lower.contains('class') || lower.contains('session')) {
      category = InterventionCategory.remedialSupport;
      final topic = subject ?? 'Subject';
      title = "$topic Remedial Support Session";
      actionTaken = "Scheduled morning remedial tutoring for $topic.";
    } else if (lower.contains('parent') || lower.contains('mother') || lower.contains('father') || lower.contains('guardian') || lower.contains('home')) {
      category = InterventionCategory.parentContact;
      final reason = concern ?? subject ?? 'Progress Update';
      title = "Parent Alert: $reason";
      actionTaken = "Contacted parent/guardian to raise awareness of student's $reason.";
    } else if (lower.contains('mentor') || lower.contains('peer') || lower.contains('buddy') || lower.contains('student')) {
      category = InterventionCategory.peerMentorship;
      final topic = subject ?? 'Studies';
      title = "Peer Mentorship: $topic";
      actionTaken = "Assigned a peer learning buddy to support student with $topic.";
    } else if (lower.contains('contract') || lower.contains('pledge') || lower.contains('agreement') || lower.contains('attendance')) {
      category = InterventionCategory.attendanceContract;
      title = "Attendance Commitment Pact";
      actionTaken = "Signed a formal attendance improvement agreement with the student.";
    }

    return ParsedSpeechIntervention(
      title: title,
      category: category,
      description: transcript,
      actionTaken: actionTaken,
    );
  }

  // AI Speech-to-Structured Outcome Extractor (for Meetings)
  ParsedSpeechOutcome parseSpeechToOutcome(String transcript) {
    final lower = transcript.toLowerCase();
    
    // 1. Determine Academic Status / Focus
    String academicStatus = "General progress review";
    if (lower.contains('math')) {
      academicStatus = "Mathematics needs practice & review";
    } else if (lower.contains('python') || lower.contains('programming') || lower.contains('coding')) {
      academicStatus = "Programming logic needs practice";
    } else if (lower.contains('science')) {
      academicStatus = "Science formulas and concepts review";
    } else if (lower.contains('english') || lower.contains('reading')) {
      academicStatus = "Language comprehension practice";
    } else {
      if (lower.contains('fail') || lower.contains('declining') || lower.contains('poor') || lower.contains('struggle')) {
        academicStatus = "Academic struggles noted";
      } else if (lower.contains('good') || lower.contains('improving') || lower.contains('excellent') || lower.contains('pass')) {
        academicStatus = "Performance is stable/improving";
      }
    }

    // 2. Determine Skill Gap
    String skillGap = "None flagged";
    if (lower.contains('python') || lower.contains('programming') || lower.contains('code') || lower.contains('coding')) {
      skillGap = "Python & Coding";
    } else if (lower.contains('math') || lower.contains('algebra') || lower.contains('calculation')) {
      skillGap = "Mathematical calculation speed";
    } else if (lower.contains('science') || lower.contains('physics') || lower.contains('chemistry')) {
      skillGap = "Science concept mapping";
    } else if (lower.contains('reading') || lower.contains('english') || lower.contains('grammar')) {
      skillGap = "Reading & Language Comprehension";
    } else {
      final words = transcript.split(' ');
      for (int i = 0; i < words.length; i++) {
        if ((words[i].toLowerCase() == 'struggling' || words[i].toLowerCase() == 'gap' || words[i].toLowerCase() == 'in') && i < words.length - 1) {
          final candidate = words[i + 1].replaceAll(RegExp(r'[.,!?]'), '');
          if (candidate.length > 3 && !['with', 'about', 'and', 'the', 'his', 'her', 'for'].contains(candidate.toLowerCase())) {
            skillGap = candidate;
            break;
          }
        }
      }
    }

    // 3. Determine Requested Support
    String requestedSupport = "Further classroom observation";
    if (lower.contains('mentor') || lower.contains('senior') || lower.contains('buddy')) {
      requestedSupport = "Peer Mentor / Senior Student Support";
    } else if (lower.contains('teacher') || lower.contains('remedial') || lower.contains('tutorial') || lower.contains('coaching')) {
      requestedSupport = "After-school Remedial Support";
    } else if (lower.contains('parent') || lower.contains('counseling') || lower.contains('counselor')) {
      requestedSupport = "Counseling / Parental Intervention";
    } else if (lower.contains('scholarship') || lower.contains('financial') || lower.contains('fees')) {
      requestedSupport = "Financial / Scholarship Assistance";
    }

    // 4. Determine Follow-up
    String? followUpDays;
    if (lower.contains('friday')) {
      followUpDays = "Next Friday";
    } else if (lower.contains('monday')) {
      followUpDays = "Next Monday";
    } else if (lower.contains('week')) {
      followUpDays = "In 1 Week";
    } else if (lower.contains('tomorrow')) {
      followUpDays = "Tomorrow";
    } else if (lower.contains('days')) {
      final match = RegExp(r'(\d+)\s+days').firstMatch(lower);
      if (match != null) {
        followUpDays = "In ${match.group(1)} Days";
      }
    }

    return ParsedSpeechOutcome(
      academicStatus: academicStatus,
      skillGap: skillGap,
      requestedSupport: requestedSupport,
      followUpDays: followUpDays,
      keyValues: {
        'Academic Status': academicStatus,
        'Skill Gap': skillGap,
        'Requested Support': requestedSupport,
        'Follow-up': followUpDays ?? 'Not specified',
      },
    );
  }
}
