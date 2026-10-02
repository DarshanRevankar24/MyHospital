import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class BloodBankScreen extends StatefulWidget {
  const BloodBankScreen({super.key});
  @override
  State<BloodBankScreen> createState() => _BloodBankScreenState();
}

class _BloodBankScreenState extends State<BloodBankScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  String? _selectedGroup;

  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  static const _stocks = [
    _BloodStock(group: 'A+', units: 45, status: 'Available', urgency: 'normal'),
    _BloodStock(group: 'A-', units: 12, status: 'Low', urgency: 'moderate'),
    _BloodStock(group: 'B+', units: 38, status: 'Available', urgency: 'normal'),
    _BloodStock(group: 'B-', units: 5, status: 'Critical', urgency: 'urgent'),
    _BloodStock(group: 'AB+', units: 22, status: 'Available', urgency: 'normal'),
    _BloodStock(group: 'AB-', units: 8, status: 'Low', urgency: 'moderate'),
    _BloodStock(group: 'O+', units: 55, status: 'Available', urgency: 'normal'),
    _BloodStock(group: 'O-', units: 3, status: 'Critical', urgency: 'urgent'),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), color: AppColors.textMid, onPressed: () => Navigator.pop(context)),
        title: Text('Blood Bank', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF8B0000), Color(0xFFB71C1C), Color(0xFFC62828)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFFB71C1C).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(children: [
                Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                  child: const Center(child: Text('🩸', style: TextStyle(fontSize: 28)))),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Blood Bank', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Search available blood units, request emergency blood', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                ])),
              ]),
            ),
            const SizedBox(height: 28),

            // Stock overview grid
            Text('Current Stock Overview', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 14),
            LayoutBuilder(builder: (_, constraints) {
              final cols = constraints.maxWidth > 700 ? 4 : 2;
              return Wrap(spacing: 12, runSpacing: 12, children: _stocks.map((s) => SizedBox(
                width: (constraints.maxWidth - (cols - 1) * 12) / cols,
                child: _BloodGroupCard(stock: s, isSelected: s.group == _selectedGroup, onTap: () => setState(() => _selectedGroup = s.group)),
              )).toList());
            }),
            const SizedBox(height: 28),

            // Request blood
            Text('Request Blood', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 14),
            _BloodRequestForm(
              bloodGroups: _bloodGroups,
              selectedGroup: _selectedGroup,
              onGroupChanged: (v) => setState(() => _selectedGroup = v),
              onSubmit: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('✅ Blood request submitted! You\'ll receive a call shortly.', style: GoogleFonts.inter(color: Colors.white)),
                  backgroundColor: const Color(0xFF4ADE80), behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ));
              },
            ),
          ]),
        ),
      ),
    );
  }
}

class _BloodStock {
  final String group, status, urgency;
  final int units;
  const _BloodStock({required this.group, required this.units, required this.status, required this.urgency});
}

class _BloodGroupCard extends StatefulWidget {
  final _BloodStock stock;
  final bool isSelected;
  final VoidCallback onTap;
  const _BloodGroupCard({required this.stock, required this.isSelected, required this.onTap});
  @override
  State<_BloodGroupCard> createState() => _BloodGroupCardState();
}

class _BloodGroupCardState extends State<_BloodGroupCard> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'urgent': return AppColors.accent;
      case 'moderate': return const Color(0xFFFBBF24);
      default: return const Color(0xFF4ADE80);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.stock;
    final urgencyColor = _urgencyColor(s.urgency);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: widget.isSelected ? urgencyColor.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.isSelected ? urgencyColor : _hovered ? urgencyColor.withValues(alpha: 0.3) : AppColors.border, width: widget.isSelected ? 2 : 1),
            boxShadow: _hovered ? [BoxShadow(color: urgencyColor.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))] : [],
          ),
          child: Column(children: [
            // Blood drop with pulse for critical
            Stack(alignment: Alignment.center, children: [
              if (s.urgency == 'urgent') AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Container(
                  width: 48 + _pulseCtrl.value * 8, height: 48 + _pulseCtrl.value * 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: urgencyColor.withValues(alpha: 0.1 * (1 - _pulseCtrl.value))),
                ),
              ),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(shape: BoxShape.circle, color: urgencyColor.withValues(alpha: 0.12)),
                child: Center(child: Text('🩸', style: TextStyle(fontSize: s.urgency == 'urgent' ? 24 : 20))),
              ),
            ]),
            const SizedBox(height: 10),
            Text(s.group, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text('${s.units} units', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMid)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: urgencyColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(s.status, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: urgencyColor)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _BloodRequestForm extends StatefulWidget {
  final List<String> bloodGroups;
  final String? selectedGroup;
  final ValueChanged<String?> onGroupChanged;
  final VoidCallback onSubmit;
  const _BloodRequestForm({required this.bloodGroups, required this.selectedGroup, required this.onGroupChanged, required this.onSubmit});
  @override
  State<_BloodRequestForm> createState() => _BloodRequestFormState();
}

class _BloodRequestFormState extends State<_BloodRequestForm> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _urgency = 'normal';

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _FormField(controller: _nameCtrl, label: 'Patient Name', icon: Icons.person_outline),
        const SizedBox(height: 12),
        _FormField(controller: _phoneCtrl, label: 'Phone Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),

        // Blood group selector
        Text('Blood Group', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: widget.bloodGroups.map((g) {
          final active = g == widget.selectedGroup;
          return GestureDetector(
            onTap: () => widget.onGroupChanged(g),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: active ? AppColors.accent : AppColors.border),
              ),
              child: Text(g, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textMid)),
            ),
          );
        }).toList()),
        const SizedBox(height: 16),

        // Urgency
        Text('Urgency', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
        const SizedBox(height: 8),
        Row(children: ['normal', 'moderate', 'urgent'].map((u) {
          final active = u == _urgency;
          final color = u == 'urgent' ? AppColors.accent : u == 'moderate' ? const Color(0xFFFBBF24) : const Color(0xFF4ADE80);
          return Expanded(child: GestureDetector(
            onTap: () => setState(() => _urgency = u),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active ? color : AppColors.bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: active ? color : AppColors.border),
              ),
              child: Center(child: Text(u[0].toUpperCase() + u.substring(1), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textMid))),
            ),
          ));
        }).toList()),
        const SizedBox(height: 20),

        GestureDetector(
          onTap: widget.onSubmit,
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFB71C1C), Color(0xFFC62828)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Center(child: Text('🩸 Submit Blood Request', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
        ),
      ]),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  const _FormField({required this.controller, required this.label, required this.icon, this.keyboardType = TextInputType.text});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label, labelStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSoft),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSoft),
        filled: true, fillColor: AppColors.bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
