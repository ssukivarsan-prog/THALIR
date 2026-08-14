import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/teacher_repository.dart';
import 'ocr_verification_screen.dart';

class OcrHistoryScreen extends StatelessWidget {
  const OcrHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TeacherRepository>();
    final history = repo.ocrHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent OCR Scans'),
      ),
      body: history.isEmpty
          ? const Center(child: Text('No recent scans recorded.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final isVerified = item.verificationStatus == 'Verified';

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: isVerified ? Colors.green.shade100 : Colors.amber.shade100,
                      child: Icon(
                        isVerified ? Icons.check_circle : Icons.pending_actions,
                        color: isVerified ? Colors.green : Colors.amber.shade900,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Class ${item.className} • ${item.recordCount} records',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Scanned: ${DateFormat('dd MMM, hh:mm a').format(item.scanDate)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                item.verificationStatus,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: isVerified ? Colors.green.shade50 : Colors.amber.shade50,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              item.isSynced ? Icons.cloud_done : Icons.cloud_upload_outlined,
                              size: 16,
                              color: item.isSynced ? Colors.teal : Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.isSynced ? 'Synced' : 'Sync Pending',
                              style: TextStyle(
                                fontSize: 11,
                                color: item.isSynced ? Colors.teal : Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OcrVerificationScreen(scanRecord: item),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
