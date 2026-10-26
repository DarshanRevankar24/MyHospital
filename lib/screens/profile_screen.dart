import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  late AnimationController _breatheCtrl;
  bool _editing = false;
  bool _loadingEmergencyCard = false;
  final _nameCtrl = TextEditingController(text: 'John Doe');
  final _emailCtrl = TextEditingController(text: 'john.doe@email.com');
  final _phoneCtrl = TextEditingController(text: '+91 98765 43210');
  String _gender = 'male';
  String _bloodGroup = 'O+';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _breatheCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() { _animCtrl.dispose(); _breatheCtrl.dispose(); _nameCtrl.dispose(); _emailCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  Future<void> _openEmergencyCard() async {
    setState(() => _loadingEmergencyCard = true);
    try {
      final profile = await ApiService.getCurrentUser();
      final username = profile['username'];
      if (username is! String || username.trim().isEmpty) {
        throw const FormatException(
          'Your account profile does not include a username.',
        );
      }
      final pdf = await ApiService.getEmergencyCard(username);
      final result = await SharePlus.instance.share(
        ShareParams(
          title: 'MyHospital emergency QR card',
          files: [
            XFile.fromData(
              pdf,
              mimeType: 'application/pdf',
              name: 'myhospital-emergency-card.pdf',
            ),
          ],
          fileNameOverrides: const ['myhospital-emergency-card.pdf'],
        ),
      );
      if (result.status == ShareResultStatus.unavailable && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sharing is unavailable on this device.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open emergency card: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingEmergencyCard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), color: AppColors.textMid, onPressed: () => Navigator.pop(context)),
        title: Text('Profile', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 16), child: GestureDetector(
            onTap: () {
              if (_editing) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('✅ Profile updated!', style: GoogleFonts.inter(color: Colors.white)),
                  backgroundColor: const Color(0xFF4ADE80), behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              }
              setState(() => _editing = !_editing);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _editing ? AppColors.blue : AppColors.blueLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_editing ? 'Save' : 'Edit', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: _editing ? Colors.white : AppColors.blue)),
            ),
          )),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(children: [
            // Profile card
            _ProfileHeader(breatheCtrl: _breatheCtrl, name: _nameCtrl.text, email: _emailCtrl.text),
            const SizedBox(height: 28),

            if (isWide)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 3, child: _PersonalInfo(
                  editing: _editing, nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl,
                  gender: _gender, bloodGroup: _bloodGroup,
                  onGenderChanged: (v) => setState(() => _gender = v!),
                  onBloodGroupChanged: (v) => setState(() => _bloodGroup = v!),
                )),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: Column(children: [
                  _StatsCard(),
                  const SizedBox(height: 20),
                  _QuickSettingsCard(),
                ])),
              ])
            else Column(children: [
              _PersonalInfo(
                editing: _editing, nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl,
                gender: _gender, bloodGroup: _bloodGroup,
                onGenderChanged: (v) => setState(() => _gender = v!),
                onBloodGroupChanged: (v) => setState(() => _bloodGroup = v!),
              ),
              const SizedBox(height: 20),
              _StatsCard(),
              const SizedBox(height: 20),
              _QuickSettingsCard(),
            ]),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadingEmergencyCard ? null : _openEmergencyCard,
                icon: _loadingEmergencyCard
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.qr_code_2),
                label: Text(
                  _loadingEmergencyCard
                      ? 'Loading emergency card…'
                      : 'Download / share emergency QR card',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _DangerZone(),
          ]),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AnimationController breatheCtrl;
  final String name, email;
  const _ProfileHeader({required this.breatheCtrl, required this.name, required this.email});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.navyDark, AppColors.navy, Color(0xFF1A2C4A)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        AnimatedBuilder(
          animation: breatheCtrl,
          builder: (_, child) => Transform.scale(scale: 0.96 + breatheCtrl.value * 0.04, child: child),
          child: Stack(alignment: Alignment.bottomRight, children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.blue, AppColors.blueMid]),
                boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2)],
              ),
              child: Center(child: Text(name.split(' ').map((w) => w[0]).join(), style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: const Color(0xFF4ADE80), shape: BoxShape.circle, border: Border.all(color: AppColors.navyDark, width: 3)),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Text(name, style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text(email, style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text('✨ Premium Member', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70)),
        ),
      ]),
    );
  }
}

class _PersonalInfo extends StatelessWidget {
  final bool editing;
  final TextEditingController nameCtrl, emailCtrl, phoneCtrl;
  final String gender, bloodGroup;
  final ValueChanged<String?> onGenderChanged, onBloodGroupChanged;
  const _PersonalInfo({
    required this.editing, required this.nameCtrl, required this.emailCtrl, required this.phoneCtrl,
    required this.gender, required this.bloodGroup, required this.onGenderChanged, required this.onBloodGroupChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.person_outline, size: 18, color: AppColors.blue),
          const SizedBox(width: 8),
          Text('Personal Information', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ]),
        const SizedBox(height: 20),
        _InfoField(controller: nameCtrl, label: 'Full Name', icon: Icons.badge_outlined, editing: editing),
        _InfoField(controller: emailCtrl, label: 'Email', icon: Icons.email_outlined, editing: editing),
        _InfoField(controller: phoneCtrl, label: 'Phone', icon: Icons.phone_outlined, editing: editing),
        const SizedBox(height: 12),
        Text('Gender', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
        const SizedBox(height: 8),
        Row(children: ['male', 'female', 'other'].map((g) {
          final active = g == gender;
          return Expanded(child: GestureDetector(
            onTap: editing ? () => onGenderChanged(g) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppColors.blue : AppColors.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: active ? AppColors.blue : AppColors.border),
              ),
              child: Center(child: Text(g[0].toUpperCase() + g.substring(1), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textMid))),
            ),
          ));
        }).toList()),
        const SizedBox(height: 16),
        Text('Blood Group', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((bg) {
          final active = bg == bloodGroup;
          return GestureDetector(
            onTap: editing ? () => onBloodGroupChanged(bg) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48, height: 40,
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: active ? AppColors.accent : AppColors.border),
              ),
              child: Center(child: Text(bg, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textMid))),
            ),
          );
        }).toList()),
      ]),
    );
  }
}

class _InfoField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool editing;
  const _InfoField({required this.controller, required this.label, required this.icon, required this.editing});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller, readOnly: !editing,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          labelText: label, labelStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSoft),
          prefixIcon: Icon(icon, size: 18, color: AppColors.textSoft),
          filled: true, fillColor: editing ? Colors.white : AppColors.bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: editing ? AppColors.blue : AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: editing ? AppColors.blue.withValues(alpha: 0.5) : AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.analytics_outlined, size: 18, color: AppColors.blue),
          const SizedBox(width: 8),
          Text('Your Stats', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ]),
        const SizedBox(height: 18),
        _StatRow(label: 'Total Visits', value: '12', icon: Icons.medical_services_outlined, color: AppColors.blue),
        _StatRow(label: 'Lab Tests', value: '8', icon: Icons.science_outlined, color: const Color(0xFF2E7D32)),
        _StatRow(label: 'Medicine Orders', value: '15', icon: Icons.medication_outlined, color: const Color(0xFFE65100)),
        _StatRow(label: 'Family Members', value: '3', icon: Icons.people_outlined, color: const Color(0xFF9333EA)),
        _StatRow(label: 'Active Medications', value: '5', icon: Icons.alarm_outlined, color: const Color(0xFFFBBF24)),
      ]),
    );
  }
}

class _StatRow extends StatefulWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatRow({required this.label, required this.value, required this.icon, required this.color});
  @override
  State<_StatRow> createState() => _StatRowState();
}

class _StatRowState extends State<_StatRow> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: _hovered ? widget.color.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(widget.icon, size: 16, color: widget.color)),
          const SizedBox(width: 12),
          Expanded(child: Text(widget.label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMid))),
          Text(widget.value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
        ]),
      ),
    );
  }
}

class _QuickSettingsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.settings_outlined, size: 18, color: AppColors.blue),
          const SizedBox(width: 8),
          Text('Settings', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        ]),
        const SizedBox(height: 16),
        _SettingToggle(label: 'Push Notifications', icon: Icons.notifications_outlined, value: true),
        _SettingToggle(label: 'SMS Reminders', icon: Icons.message_outlined, value: true),
        _SettingToggle(label: 'Email Updates', icon: Icons.email_outlined, value: false),
        _SettingToggle(label: 'Dark Mode', icon: Icons.dark_mode_outlined, value: false),
      ]),
    );
  }
}

class _SettingToggle extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool value;
  const _SettingToggle({required this.label, required this.icon, required this.value});
  @override
  State<_SettingToggle> createState() => _SettingToggleState();
}

class _SettingToggleState extends State<_SettingToggle> {
  late bool _value;
  @override
  void initState() { super.initState(); _value = widget.value; }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(widget.icon, size: 16, color: AppColors.textSoft),
        const SizedBox(width: 10),
        Expanded(child: Text(widget.label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMid))),
        Switch(value: _value, onChanged: (v) => setState(() => _value = v), activeColor: AppColors.blue),
      ]),
    );
  }
}

class _DangerZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Danger Zone', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accent)),
          Text('Permanently delete your account and all data', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)), borderRadius: BorderRadius.circular(10)),
          child: Text('Delete', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
        ),
      ]),
    );
  }
}
