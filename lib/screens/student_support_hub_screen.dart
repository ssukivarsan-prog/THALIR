import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../models/intervention_recommendation.dart';

class StudentSupportHubScreen extends StatefulWidget {
  const StudentSupportHubScreen({super.key});

  @override
  State<StudentSupportHubScreen> createState() => _StudentSupportHubScreenState();
}

class _StudentSupportHubScreenState extends State<StudentSupportHubScreen> {
  String _selectedPillar = 'all'; // 'all', 'scholarship', 'hostel', 'subject_coaching', 'extracurricular_talent'

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final isMunicipality = provider.activeRole == 'municipality_head';
    final recs = provider.filteredRecommendations(_selectedPillar);

    final pendingPrincipalCount = provider.recommendations
        .where((r) => r.status == 'Pending Principal Review')
        .length;

    final pendingMunicipalityCount = provider.recommendations
        .where((r) => r.status == 'Approved by Principal (Sent to Municipality)')
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner & Header Action Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMunicipality
                        ? "Municipality Endorsements & Organization Dispatch Hub"
                        : "4-Pillar Student Support & Foundation Mapping Hub",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMunicipality
                        ? "Review principal-approved recommendations and dispatch official reports with attachments."
                        : "Teacher & Headmaster pipeline for scholarships (Agaram), hostels, remedial studies & talent showcase.",
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),

              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const SubmitRecommendationModal(),
                  );
                },
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: Colors.white),
                label: const Text(
                  "+ Submit Support Request",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryTeal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 4 Support Pillars Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PillarTabButton(
                  label: "All Pillars",
                  icon: Icons.all_inclusive_rounded,
                  pillarKey: "all",
                  selectedKey: _selectedPillar,
                  onSelect: (k) => setState(() => _selectedPillar = k),
                ),
                const SizedBox(width: 10),
                _PillarTabButton(
                  label: "🎓 Financial & Agaram Scholarships",
                  icon: Icons.school_rounded,
                  pillarKey: "scholarship",
                  selectedKey: _selectedPillar,
                  onSelect: (k) => setState(() => _selectedPillar = k),
                ),
                const SizedBox(width: 10),
                _PillarTabButton(
                  label: "🏢 Hostel Boarding Placement",
                  icon: Icons.other_houses_rounded,
                  pillarKey: "hostel",
                  selectedKey: _selectedPillar,
                  onSelect: (k) => setState(() => _selectedPillar = k),
                ),
                const SizedBox(width: 10),
                _PillarTabButton(
                  label: "📚 Subject Remedial Recovery",
                  icon: Icons.menu_book_rounded,
                  pillarKey: "subject_coaching",
                  selectedKey: _selectedPillar,
                  onSelect: (k) => setState(() => _selectedPillar = k),
                ),
                const SizedBox(width: 10),
                _PillarTabButton(
                  label: "🏆 Extracurricular & Talent Showcase",
                  icon: Icons.emoji_events_rounded,
                  pillarKey: "extracurricular_talent",
                  selectedKey: _selectedPillar,
                  onSelect: (k) => setState(() => _selectedPillar = k),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Scoped Status Alert Banner
          if (isMunicipality && pendingMunicipalityCount > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "$pendingMunicipalityCount student support recommendations forwarded by Principals are awaiting your Municipality Endorsement & Official Report Generation.",
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E3A8A), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )
          else if (!isMunicipality && pendingPrincipalCount > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.riskHighBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pending_actions_rounded, color: AppTheme.riskHighText, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "$pendingPrincipalCount teacher recommendation submissions require your Principal Verification before forwarding to the Municipality.",
                      style: const TextStyle(fontSize: 13, color: AppTheme.riskHighText, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Recommendations List
          if (recs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Center(
                child: Text(
                  "No support requests found for the selected pillar filter.",
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final rec = recs[index];
                return _RecommendationCard(rec: rec, isMunicipality: isMunicipality);
              },
            ),
        ],
      ),
    );
  }
}

class _PillarTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String pillarKey;
  final String selectedKey;
  final ValueChanged<String> onSelect;

  const _PillarTabButton({
    required this.label,
    required this.icon,
    required this.pillarKey,
    required this.selectedKey,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = pillarKey == selectedKey;
    return ElevatedButton.icon(
      onPressed: () => onSelect(pillarKey),
      icon: Icon(icon, size: 16, color: isSelected ? Colors.white : AppTheme.textSecondary),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primaryNavy : AppTheme.surface,
        elevation: isSelected ? 2 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isSelected ? AppTheme.primaryNavy : AppTheme.border),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final InterventionRecommendation rec;
  final bool isMunicipality;

  const _RecommendationCard({required this.rec, required this.isMunicipality});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context, listen: false);

    Color statusBg = AppTheme.surfaceSubtle;
    Color statusText = AppTheme.textSecondary;
    if (rec.status == 'Pending Principal Review') {
      statusBg = AppTheme.riskHighBg;
      statusText = AppTheme.riskHighText;
    } else if (rec.status.contains('Approved by Principal')) {
      statusBg = const Color(0xFFEFF6FF);
      statusText = const Color(0xFF2563EB);
    } else if (rec.status.contains('Municipality Endorsed')) {
      statusBg = AppTheme.riskLowBg;
      statusText = AppTheme.riskLowText;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryNavy,
                child: Text(
                  rec.studentName.isNotEmpty ? rec.studentName[0] : 'S',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          rec.studentName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppTheme.surfaceSubtle, borderRadius: BorderRadius.circular(6)),
                          child: Text(rec.classId, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${rec.schoolName}  |  Teacher Entry: ${rec.teacherName}",
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  rec.status,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: statusText),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),

          // Target Organization / Entity
          Row(
            children: [
              const Icon(Icons.outbound_rounded, size: 18, color: AppTheme.secondaryTeal),
              const SizedBox(width: 8),
              Text(
                "Target Entity: ${rec.targetEntity}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Reason Notes
          Text(
            "Teacher Situation Analysis: ${rec.reasonNotes}",
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
          ),

          if (rec.principalNotes != null) ...[
            const SizedBox(height: 8),
            Text(
              "Principal Verification Notes: ${rec.principalNotes}",
              style: const TextStyle(fontSize: 12.5, color: AppTheme.secondaryTeal, fontWeight: FontWeight.w600),
            ),
          ],

          if (rec.municipalityNotes != null) ...[
            const SizedBox(height: 6),
            Text(
              "Municipality Dispatch Notes: ${rec.municipalityNotes}",
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Submitted: ${DateFormat('dd MMM yyyy, HH:mm').format(rec.createdAt)}",
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),

              Wrap(
                spacing: 10,
                children: [
                  // Principal Action: Approve & Forward to Municipality
                  if (!isMunicipality && rec.status == 'Pending Principal Review')
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.approveRecommendationByPrincipal(
                          rec.recommendationId,
                          "Verified student credentials. Approved for Agaram / Govt Hostel Boarding.",
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Approved '${rec.studentName}' and forwarded to Municipality CEO!"),
                            backgroundColor: AppTheme.secondaryTeal,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                      label: const Text("Approve & Board to Municipality", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryTeal,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),

                  // Municipality Action: Endorse & Dispatch Official Report
                  if (isMunicipality && rec.status.contains('Approved by Principal'))
                    ElevatedButton.icon(
                      onPressed: () {
                        provider.endorseAndDispatchByMunicipality(
                          rec.recommendationId,
                          "Officially endorsed by Corporation CEO. Dispatched to Organization Management with attachments.",
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Municipality Endorsement & Official Report generated for ${rec.targetEntity}!"),
                            backgroundColor: const Color(0xFF2563EB),
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                      label: const Text("Endorse & Dispatch Official Report", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SubmitRecommendationModal extends StatefulWidget {
  const SubmitRecommendationModal({super.key});

  @override
  State<SubmitRecommendationModal> createState() => _SubmitRecommendationModalState();
}

class _SubmitRecommendationModalState extends State<SubmitRecommendationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _classController = TextEditingController(text: "Grade 10-A");
  final _teacherController = TextEditingController(text: "Class Teacher");
  final _entityController = TextEditingController(text: "Agaram Foundation Educational Scholarship");
  final _reasonController = TextEditingController();

  String _selectedPillar = "scholarship";

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _teacherController.dispose();
    _entityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<DashboardProvider>(context, listen: false);

    final newRec = InterventionRecommendation(
      recommendationId: "rec-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      studentId: "std-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
      studentName: _nameController.text.trim(),
      schoolId: provider.school?.schoolId ?? "school-greenwood-01",
      schoolName: provider.school?.name ?? "Greenwood Higher Secondary School",
      classId: _classController.text.trim(),
      teacherName: _teacherController.text.trim(),
      pillarType: _selectedPillar,
      targetEntity: _entityController.text.trim(),
      reasonNotes: _reasonController.text.trim(),
      status: "Pending Principal Review",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    provider.submitTeacherRecommendation(newRec);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Support Request for '${newRec.studentName}' submitted for Principal Verification!"),
        backgroundColor: AppTheme.secondaryTeal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: 580,
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceSubtle,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    border: Border(bottom: BorderSide(color: AppTheme.border)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.volunteer_activism_rounded, color: AppTheme.secondaryTeal, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        "Submit Student Support Request",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Support Pillar Category *", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedPillar,
                                items: const [
                                  DropdownMenuItem(value: 'scholarship', child: Text('🎓 Financial & Agaram Scholarships')),
                                  DropdownMenuItem(value: 'hostel', child: Text('🏢 Hostel Boarding Placement')),
                                  DropdownMenuItem(value: 'subject_coaching', child: Text('📚 Subject Remedial Recovery')),
                                  DropdownMenuItem(value: 'extracurricular_talent', child: Text('🏆 Extracurricular & Talent Showcase')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedPillar = val;
                                      if (val == 'scholarship') _entityController.text = "Agaram Foundation Educational Scholarship";
                                      else if (val == 'hostel') _entityController.text = "Govt BC Welfare Student Hostel";
                                      else if (val == 'subject_coaching') _entityController.text = "Municipal Remedial Math & Science Coaching";
                                      else _entityController.text = "SDAT Tamil Nadu Sports Quota";
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Student Name *", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _nameController,
                                      validator: (v) => v == null || v.trim().isEmpty ? "Required" : null,
                                      decoration: InputDecoration(hintText: "e.g. Anand Kumar", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Class *", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _classController,
                                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text("Target Organization / Foundation Entity *", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _entityController,
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          ),
                          const SizedBox(height: 16),
                          const Text("Teacher Analysis & Student Situation Notes *", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _reasonController,
                            maxLines: 3,
                            validator: (v) => v == null || v.trim().isEmpty ? "Notes required" : null,
                            decoration: InputDecoration(
                              hintText: "Describe student family background, poverty condition, hosteling need, weak subject or sports achievement...",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              child: const Text("Submit Support Request to Principal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
