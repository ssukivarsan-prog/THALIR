import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/ocr_model.dart';
import '../../services/teacher_repository.dart';
import '../../services/ocr_service.dart';
import 'ocr_verification_screen.dart';
import 'ocr_history_screen.dart';

class OcrScannerScreen extends StatefulWidget {
  final int initialTab;

  const OcrScannerScreen({super.key, this.initialTab = 0});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  
  String? _capturedImagePath;
  bool _isProcessing = false;
  double _rotationAngle = 0.0;
  bool _isCropped = false;

  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _laserAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(_laserController);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _laserController.dispose();
    super.dispose();
  }

  OcrDocumentType get _currentDocType {
    switch (_tabController.index) {
      case 0: return OcrDocumentType.attendance;
      case 1: return OcrDocumentType.classTestMarks;
      default: return OcrDocumentType.examMarks;
    }
  }

  String get _docTypeName {
    switch (_currentDocType) {
      case OcrDocumentType.attendance: return 'Attendance Register';
      case OcrDocumentType.classTestMarks: return 'Internal Test Sheet';
      case OcrDocumentType.examMarks: return 'Exam Marks Register';
    }
  }

  Future<void> _captureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 92,
      );
      if (photo != null) {
        setState(() {
          _capturedImagePath = photo.path;
          _rotationAngle = 0.0;
          _isCropped = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera access note: $e. You can also pick from gallery.')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 92,
      );
      if (image != null) {
        setState(() {
          _capturedImagePath = image.path;
          _rotationAngle = 0.0;
          _isCropped = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open gallery: $e')),
      );
    }
  }

  void _processScan() async {
    final repo = context.read<TeacherRepository>();

    // If no image captured yet, prompt to open camera
    if (_capturedImagePath == null) {
      await _captureFromCamera();
      if (_capturedImagePath == null) return; // User cancelled
    }

    setState(() => _isProcessing = true);
    _laserController.repeat(reverse: true);

    final rows = await OcrService.processImage(
      imagePath: _capturedImagePath!,
      documentType: _currentDocType,
      className: repo.teacher.activeClass,
      activeStudents: repo.students,
    );

    _laserController.stop();
    if (!mounted) return;
    setState(() => _isProcessing = false);

    final scanRecord = OcrScanRecord(
      id: 'scan-${DateTime.now().millisecondsSinceEpoch}',
      title: '${repo.teacher.activeClass} $_docTypeName',
      documentType: _currentDocType,
      className: repo.teacher.activeClass,
      scanDate: DateTime.now(),
      recordCount: rows.length,
      verificationStatus: 'Verification Required',
      isSynced: false,
      rows: rows,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OcrVerificationScreen(
          scanRecord: scanRecord,
          capturedImagePath: _capturedImagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📸 OCR Smart Scanner'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner, size: 18), text: 'Attendance'),
            Tab(icon: Icon(Icons.assignment_outlined, size: 18), text: 'Internal Test'),
            Tab(icon: Icon(Icons.grade_outlined, size: 18), text: 'Exam Marks'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Recent Scan History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OcrHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Auto Document Detection Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: const Color(0xFFEEF2FF),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF4F46E5), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$_docTypeName detected • Class ${repo.teacher.activeClass}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5), fontSize: 12),
                  ),
                ),
                if (_capturedImagePath != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Photo Captured ✓', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          // Viewfinder / Photo Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF4F46E5), width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Display Captured Photo or Simulation placeholder
                    if (_capturedImagePath != null && File(_capturedImagePath!).existsSync())
                      Transform.rotate(
                        angle: _rotationAngle,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: _isCropped ? const EdgeInsets.all(24) : EdgeInsets.zero,
                          child: Image.file(
                            File(_capturedImagePath!),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      )
                    else
                      Transform.rotate(
                        angle: _rotationAngle,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _currentDocType == OcrDocumentType.attendance
                                      ? Icons.fact_check_outlined
                                      : Icons.receipt_long_outlined,
                                  color: Colors.white38,
                                  size: 70,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap camera button to capture photo of physical $_docTypeName',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Text('Target: Class ${repo.teacher.activeClass}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 2),
                                      const Text('Supports camera capture & gallery image upload', style: TextStyle(color: Colors.white60, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Viewfinder guide frame overlay
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.7), width: 2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    // Animated Scanning Laser Beam
                    if (_isProcessing)
                      AnimatedBuilder(
                        animation: _laserAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: MediaQuery.of(context).size.height * 0.4 * _laserAnimation.value,
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.tealAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.tealAccent.withValues(alpha: 0.8),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    if (_isProcessing)
                      Container(
                        color: Colors.black.withValues(alpha: 0.75),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.tealAccent),
                              SizedBox(height: 16),
                              Text(
                                'Scanning Image & Extracting Marks...',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Analyzing Roll Numbers, Names & Marks',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Overflow-safe Responsive Control Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Theme.of(context).cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera Capture Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Camera', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: _isProcessing ? null : _captureFromCamera,
                  ),
                  const SizedBox(width: 8),

                  // Gallery Pick Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Gallery', style: TextStyle(fontSize: 12)),
                    onPressed: _isProcessing ? null : _pickFromGallery,
                  ),
                  const SizedBox(width: 8),

                  // Process/Scan OCR Action Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.bolt, size: 18),
                    label: Text(
                      _capturedImagePath != null ? 'Run OCR' : 'Capture & Scan',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isProcessing ? null : _processScan,
                  ),
                  const SizedBox(width: 8),

                  // Rotate Button
                  IconButton(
                    icon: Icon(Icons.rotate_right, color: _rotationAngle != 0 ? const Color(0xFF4F46E5) : null),
                    tooltip: 'Rotate Image',
                    onPressed: () => setState(() => _rotationAngle += 1.5708),
                  ),

                  // Crop Toggle Button
                  IconButton(
                    icon: Icon(Icons.crop, color: _isCropped ? const Color(0xFF4F46E5) : null),
                    tooltip: 'Crop Preview',
                    onPressed: () {
                      setState(() => _isCropped = !_isCropped);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_isCropped ? 'Crop preview enabled.' : 'Full view restored.')),
                      );
                    },
                  ),

                  // Retake/Reset Button
                  if (_capturedImagePath != null)
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.red),
                      tooltip: 'Clear & Retake',
                      onPressed: () {
                        setState(() {
                          _capturedImagePath = null;
                          _rotationAngle = 0.0;
                          _isCropped = false;
                        });
                      },
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
