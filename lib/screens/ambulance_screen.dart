import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AmbulanceScreen extends StatefulWidget {
  const AmbulanceScreen({super.key});
  @override
  State<AmbulanceScreen> createState() => _AmbulanceScreenState();
}

class _AmbulanceScreenState extends State<AmbulanceScreen> with TickerProviderStateMixin {
  late AnimationController _animCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _radarCtrl;
  String _selectedType = 'ALS';
  bool _isRequesting = false;
  bool _requested = false;
  bool _bookingForOther = false;
  final _patientNameController = TextEditingController();
  final _patientPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _radarCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pulseCtrl.dispose();
    _radarCtrl.dispose();
    _patientNameController.dispose();
    _patientPhoneController.dispose();
    super.dispose();
  }

  Future<void> _requestAmbulance() async {
    if (_bookingForOther &&
        (_patientNameController.text.trim().isEmpty ||
            _patientPhoneController.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter the patient name and contact number.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isRequesting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _isRequesting = false; _requested = true; });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), color: AppColors.textMid, onPressed: () => Navigator.pop(context)),
        title: Text('Emergency Ambulance', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Emergency header
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFB71C1C), Color(0xFFD32F2F), Color(0xFFE53935)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Stack(children: [
                // Radar animation
                Positioned(right: -20, top: -20, child: AnimatedBuilder(
                  animation: _radarCtrl,
                  builder: (_, __) => Opacity(
                    opacity: 0.15,
                    child: Transform.rotate(
                      angle: _radarCtrl.value * 2 * math.pi,
                      child: Container(width: 120, height: 120, decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(colors: [Colors.white.withValues(alpha: 0.0), Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.0)]),
                      )),
                    ),
                  ),
                )),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (_, child) => Transform.scale(scale: 0.95 + _pulseCtrl.value * 0.08, child: child),
                      child: Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16)),
                        child: const Center(child: Text('🚑', style: TextStyle(fontSize: 30)))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Emergency Ambulance', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('ALS/BLS fleet available 24/7', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                    ])),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      _PulsingDot(color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Average response time: 8 minutes', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ]),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 28),

            if (_requested) ...[
              _TrackingCard(radarCtrl: _radarCtrl, onCancel: () => setState(() => _requested = false)),
            ] else ...[
              // Ambulance type selector
              Text('Select Ambulance Type', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _TypeCard(type: 'ALS', label: 'Advanced Life Support', desc: 'ICU on wheels — ventilator, monitor, defibrillator', icon: '🏥', isSelected: _selectedType == 'ALS', onTap: () => setState(() => _selectedType = 'ALS'))),
                const SizedBox(width: 14),
                Expanded(child: _TypeCard(type: 'BLS', label: 'Basic Life Support', desc: 'First aid kit, oxygen, stretcher, basic equipment', icon: '🚑', isSelected: _selectedType == 'BLS', onTap: () => setState(() => _selectedType = 'BLS'))),
              ]),
              const SizedBox(height: 28),

              // Quick Request
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Request Ambulance', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 6),
                  Text('We\'ll dispatch the nearest ${_selectedType} ambulance to your location', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSoft)),
                  const SizedBox(height: 20),

                  Text('Who needs the ambulance?', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _BookingTargetOption(
                      label: 'For me',
                      icon: Icons.person_outline_rounded,
                      selected: !_bookingForOther,
                      onTap: () => setState(() => _bookingForOther = false),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _BookingTargetOption(
                      label: 'For someone else',
                      icon: Icons.people_outline_rounded,
                      selected: _bookingForOther,
                      onTap: () => setState(() => _bookingForOther = true),
                    )),
                  ]),
                  if (_bookingForOther) ...[
                    const SizedBox(height: 14),
                    TextField(
                      controller: _patientNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Patient name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _patientPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Patient contact number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(children: [
                      const Icon(Icons.my_location_rounded, size: 20, color: AppColors.blue),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Current Location', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                        Text('Detecting your location…', style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSoft)),
                      ])),
                      const Icon(Icons.edit_location_outlined, size: 18, color: AppColors.textSoft),
                    ]),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: _isRequesting ? null : _requestAmbulance,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Center(child: _isRequesting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.emergency_rounded, size: 20, color: Colors.white),
                              const SizedBox(width: 10),
                              Text('Request ${_selectedType} Ambulance Now', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                            ])),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(child: Text('📞 Or call 108 for immediate help', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft))),
                ]),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _BookingTargetOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _BookingTargetOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.blueLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? AppColors.blue : AppColors.textSoft),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.blue : AppColors.textMid,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeCard extends StatefulWidget {
  final String type, label, desc, icon;
  final bool isSelected;
  final VoidCallback onTap;
  const _TypeCard({required this.type, required this.label, required this.desc, required this.icon, required this.isSelected, required this.onTap});
  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard> {
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.accent.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.isSelected ? AppColors.accent : _hovered ? AppColors.accent.withValues(alpha: 0.3) : AppColors.border, width: widget.isSelected ? 2 : 1),
            boxShadow: _hovered ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 6))] : [],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(widget.icon, style: const TextStyle(fontSize: 28)),
              const Spacer(),
              if (widget.isSelected) Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ]),
            const SizedBox(height: 12),
            Text(widget.type, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 4),
            Text(widget.label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMid)),
            const SizedBox(height: 6),
            Text(widget.desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft, height: 1.5)),
          ]),
        ),
      ),
    );
  }
}

class _TrackingCard extends StatelessWidget {
  final AnimationController radarCtrl;
  final VoidCallback onCancel;
  const _TrackingCard({required this.radarCtrl, required this.onCancel});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        // Radar
        SizedBox(
          width: 140, height: 140,
          child: Stack(alignment: Alignment.center, children: [
            ...List.generate(3, (i) => AnimatedBuilder(
              animation: radarCtrl,
              builder: (_, __) {
                final v = (radarCtrl.value + i / 3) % 1;
                return Container(
                  width: 60 + v * 80, height: 60 + v * 80,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3 * (1 - v)), width: 2)),
                );
              },
            )),
            Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withValues(alpha: 0.1)),
              child: const Center(child: Text('🚑', style: TextStyle(fontSize: 28)))),
          ]),
        ),
        const SizedBox(height: 20),
        Text('Ambulance on the Way!', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 6),
        Text('ETA: 8 minutes', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.accent)),
        const SizedBox(height: 6),
        Text('Driver: Rajesh Kumar · KA-01-AB-1234', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSoft)),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.blue, AppColors.blueMid]), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.phone, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text('Call Driver', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              ])),
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(
            onTap: onCancel,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMid))),
            ),
          )),
        ]),
      ]),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 1, end: 0.3).animate(_ctrl),
    child: Container(width: 8, height: 8, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
  );
}
