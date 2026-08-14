import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/teacher_repository.dart';
import 'student_profile_screen.dart';
import 'meeting_brief_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

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
    final students = repo.students;

    final filteredStudents = students.where((s) {
      final matchesSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.rollNumber.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedFilter == 'High Risk') return s.calculatedDropoutRiskLevel == 'High';
      if (_selectedFilter == 'Medium Risk') return s.calculatedDropoutRiskLevel == 'Medium';
      if (_selectedFilter == 'Low Risk') return s.calculatedDropoutRiskLevel == 'Low';
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Class ${repo.teacher.activeClass} Dropout Risk List',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search student by name or ID...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'High Risk', 'Medium Risk', 'Low Risk'].map((filter) {
                      final isSel = filter == _selectedFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(filter, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          selected: isSel,
                          onSelected: (s) {
                            if (s) setState(() => _selectedFilter = filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Student Cards List
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text('No students match filter criteria.', style: TextStyle(fontSize: 13, color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      final riskLevel = student.calculatedDropoutRiskLevel;
                      final riskScore = student.calculatedDropoutRiskScore.toInt();

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentProfileScreen(student: student),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: _getRiskBgColor(riskLevel),
                                      child: Text(
                                        student.name.isNotEmpty ? student.name[0] : 'S',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: _getRiskColor(riskLevel),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                          ),
                                          Text(
                                            'ID: ${student.rollNumber} • Class ${student.className}',
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
                                        color: _getRiskBgColor(riskLevel),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$riskLevel Risk ($riskScore%)',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getRiskColor(riskLevel)),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),

                                // Metrics Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMetricChip(
                                        'Attendance',
                                        '${student.attendancePercentage}%',
                                        student.attendanceTrend == 'declining' ? '↓' : '↑',
                                        student.attendanceTrend == 'declining' ? Colors.red : Colors.green,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMetricChip(
                                        'Academic Avg',
                                        '${student.academicAverage}%',
                                        student.academicTrend == 'declining' ? '↓' : '↑',
                                        student.academicTrend == 'declining' ? Colors.red : Colors.green,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildMetricChip(
                                        'Interventions',
                                        '${student.interventions.length}',
                                        '🛡',
                                        const Color(0xFF4F46E5),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.warning, color: Colors.blueAccent, size: 14),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          student.dropoutRiskProfile.primaryRiskFactors.isEmpty
                                              ? 'No current warning flags detected'
                                              : 'Risk drivers: ${student.dropoutRiskProfile.primaryRiskFactors.join(", ")}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        icon: const Icon(Icons.analytics_outlined, size: 14),
                                        label: const Text('Risk Analysis', style: TextStyle(fontSize: 11)),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => StudentProfileScreen(student: student),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF4F46E5),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        icon: const Icon(Icons.bolt, size: 14),
                                        label: const Text('Preventive Brief', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MeetingBriefScreen(student: student),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String val, String trend, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
            const SizedBox(width: 2),
            Text(trend, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
