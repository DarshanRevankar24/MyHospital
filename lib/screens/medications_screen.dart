import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});
  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool _showAddForm = false;
  bool _authorized = kIsWeb;
  bool _authorizing = false;

  final _meds = <_MedData>[
    _MedData(
      name: 'Metformin 500mg',
      type: 'Tablet',
      dosage: '1 tablet',
      frequency: 'Twice daily',
      instructions: 'Before breakfast & dinner',
      startDate: '2026-09-01',
      endDate: '2026-12-01',
      times: ['08:00 AM', '08:00 PM'],
      taken: [true, false],
    ),
    _MedData(
      name: 'Atorvastatin 20mg',
      type: 'Tablet',
      dosage: '1 tablet',
      frequency: 'Once daily',
      instructions: 'After dinner',
      startDate: '2026-08-15',
      endDate: '2026-11-15',
      times: ['09:00 PM'],
      taken: [false],
    ),
    _MedData(
      name: 'Amlodipine 5mg',
      type: 'Tablet',
      dosage: '1 tablet',
      frequency: 'Once daily',
      instructions: 'Morning with water',
      startDate: '2026-09-10',
      endDate: '2027-03-10',
      times: ['08:00 AM'],
      taken: [true],
    ),
    _MedData(
      name: 'Vitamin D3 60K IU',
      type: 'Capsule',
      dosage: '1 capsule',
      frequency: 'Once weekly',
      instructions: 'After any meal',
      startDate: '2026-09-01',
      endDate: '2026-12-01',
      times: ['12:00 PM'],
      taken: [true],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _authorize());
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _authorize() async {
    if (_authorizing || _authorized) return;
    setState(() => _authorizing = true);
    final result = await AuthService().confirmIdentity(
      reason: 'Authenticate to view your medications',
    );
    if (!mounted) return;
    setState(() {
      _authorized = result == AuthResult.success;
      _authorizing = false;
    });
    if (result != AuthResult.success) {
      final message = switch (result) {
        AuthResult.unavailable =>
          'Set up device biometrics or a screen lock to continue.',
        AuthResult.lockedOut =>
          'Device authentication is locked. Try again later.',
        AuthResult.cancelled => 'Authentication was cancelled.',
        AuthResult.error => 'Could not authenticate. Please try again.',
        AuthResult.success => '',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final todayDue = _meds
        .expand(
          (m) => m.times
              .asMap()
              .entries
              .where((e) => !m.taken[e.key])
              .map((e) => '${m.name} · ${e.value}'),
        )
        .toList();
    final todayTaken = _meds
        .expand(
          (m) => m.times
              .asMap()
              .entries
              .where((e) => m.taken[e.key])
              .map((e) => '${m.name} · ${e.value}'),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textMid,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Medication Tracker',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(
                _showAddForm ? Icons.close : Icons.add_rounded,
                color: AppColors.blue,
              ),
              onPressed: () => setState(() => _showAddForm = !_showAddForm),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: !_authorized
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: AppColors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Authenticate to view your medications',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _authorizing ? null : _authorize,
                    icon: _authorizing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint_rounded),
                    label: Text(
                      _authorizing ? 'Authenticating…' : 'Authenticate',
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: CurvedAnimation(
                parent: _animCtrl,
                curve: Curves.easeOut,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWide ? 32 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1A237E),
                            Color(0xFF283593),
                            Color(0xFF3949AB),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF1A237E,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text('💊', style: TextStyle(fontSize: 28)),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Medications',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_meds.length} active · ${todayDue.length} due today',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Add form
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: _AddMedicationForm(
                        onAdd: (med) => setState(() {
                          _meds.add(med);
                          _showAddForm = false;
                        }),
                      ),
                      crossFadeState: _showAddForm
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    if (_showAddForm) const SizedBox(height: 20),

                    // Today's Schedule
                    if (todayDue.isNotEmpty) ...[
                      _SectionLabel(
                        label: 'Due Now',
                        icon: Icons.alarm_outlined,
                        color: const Color(0xFFFBBF24),
                      ),
                      const SizedBox(height: 12),
                      ...todayDue.map(
                        (t) => _ScheduleTile(
                          text: t,
                          icon: Icons.alarm,
                          color: const Color(0xFFFBBF24),
                          status: 'Due',
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (todayTaken.isNotEmpty) ...[
                      _SectionLabel(
                        label: 'Completed',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF4ADE80),
                      ),
                      const SizedBox(height: 12),
                      ...todayTaken.map(
                        (t) => _ScheduleTile(
                          text: t,
                          icon: Icons.check_circle,
                          color: const Color(0xFF4ADE80),
                          status: 'Taken',
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // All medications
                    Text(
                      'All Medications',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ..._meds.asMap().entries.map(
                      (e) => _MedicationCard(
                        med: e.value,
                        onDelete: () => setState(() => _meds.removeAt(e.key)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _MedData {
  final String name, type, dosage, frequency, instructions, startDate, endDate;
  final List<String> times;
  final List<bool> taken;
  bool reminderEnabled = true;
  bool notifyFamily = false;
  _MedData({
    required this.name,
    required this.type,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    required this.startDate,
    required this.endDate,
    required this.times,
    required this.taken,
  });
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SectionLabel({
    required this.label,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _ScheduleTile extends StatefulWidget {
  final String text, status;
  final IconData icon;
  final Color color;
  const _ScheduleTile({
    required this.text,
    required this.icon,
    required this.color,
    required this.status,
  });
  @override
  State<_ScheduleTile> createState() => _ScheduleTileState();
}

class _ScheduleTileState extends State<_ScheduleTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hovered ? widget.color.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered
                ? widget.color.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, size: 18, color: widget.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.text,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.status,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationCard extends StatefulWidget {
  final _MedData med;
  final VoidCallback onDelete;
  const _MedicationCard({required this.med, required this.onDelete});
  @override
  State<_MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<_MedicationCard> {
  bool _expanded = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.med;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? AppColors.blue.withValues(alpha: 0.3)
                : AppColors.border,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('💊', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${m.type} · ${m.dosage} · ${m.frequency}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSoft,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 14),
                    _DetailRow(label: 'Instructions', value: m.instructions),
                    _DetailRow(label: 'Start Date', value: m.startDate),
                    _DetailRow(label: 'End Date', value: m.endDate),
                    _DetailRow(
                      label: 'Reminder Times',
                      value: m.times.join(', '),
                    ),
                    const SizedBox(height: 6),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: m.reminderEnabled,
                      onChanged: (value) =>
                          setState(() => m.reminderEnabled = value),
                      title: Text(
                        'Medication alarm',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: Text(
                        'Remind me at the times above',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: m.notifyFamily,
                      onChanged: (value) =>
                          setState(() => m.notifyFamily = value),
                      title: Text(
                        'Notify family member',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      subtitle: Text(
                        'Aarav Sharma · Family contact',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ),
                    Text(
                      'Preview only — system alarms and notifications are not connected.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSoft,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _SmallButton(
                          label: 'Edit',
                          icon: Icons.edit_outlined,
                          color: AppColors.blue,
                          onTap: () {},
                        ),
                        const SizedBox(width: 10),
                        _SmallButton(
                          label: 'Delete',
                          icon: Icons.delete_outline,
                          color: AppColors.accent,
                          onTap: widget.onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  State<_SmallButton> createState() => _SmallButtonState();
}

class _SmallButtonState extends State<_SmallButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: widget.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: widget.color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMedicationForm extends StatefulWidget {
  final ValueChanged<_MedData> onAdd;
  const _AddMedicationForm({required this.onAdd});
  @override
  State<_AddMedicationForm> createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<_AddMedicationForm> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _instrCtrl = TextEditingController();
  String _type = 'Tablet';
  String _frequency = 'Once daily';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _instrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Medication',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _FormInput(
            controller: _nameCtrl,
            label: 'Medicine Name',
            icon: Icons.medication_outlined,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _FormInput(
                  controller: _dosageCtrl,
                  label: 'Dosage (e.g. 500mg)',
                  icon: Icons.science_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeDropdown(
                  value: _type,
                  onChanged: (v) => setState(() => _type = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FrequencyDropdown(
            value: _frequency,
            onChanged: (v) => setState(() => _frequency = v!),
          ),
          const SizedBox(height: 12),
          _FormInput(
            controller: _instrCtrl,
            label: 'Instructions',
            icon: Icons.note_outlined,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              if (_nameCtrl.text.isNotEmpty) {
                widget.onAdd(
                  _MedData(
                    name: _nameCtrl.text,
                    type: _type,
                    dosage: _dosageCtrl.text.isEmpty
                        ? '1 ${_type.toLowerCase()}'
                        : _dosageCtrl.text,
                    frequency: _frequency,
                    instructions: _instrCtrl.text.isEmpty
                        ? 'As directed'
                        : _instrCtrl.text,
                    startDate: '2026-10-02',
                    endDate: '2027-01-02',
                    times: ['08:00 AM'],
                    taken: [false],
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.blue, AppColors.blueMid],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '+ Add Medication',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  const _FormInput({
    required this.controller,
    required this.label,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSoft),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSoft),
        filled: true,
        fillColor: AppColors.bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _TypeDropdown({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
          items: [
            'Tablet',
            'Capsule',
            'Syrup',
            'Injection',
            'Drops',
            'Inhaler',
          ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FrequencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  const _FrequencyDropdown({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
          items: [
            'Once daily',
            'Twice daily',
            'Three times daily',
            'Once weekly',
            'As needed',
          ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
