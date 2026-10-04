import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';

class AppointmentSection extends StatefulWidget {
  const AppointmentSection({super.key});

  @override
  State<AppointmentSection> createState() => _AppointmentSectionState();
}

class _AppointmentSectionState extends State<AppointmentSection> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedSpecialty;
  String _btnText = 'Find Doctors Now →';
  bool _success = false;
  bool _error = false;

  static const _specialties = [
    'General Physician', 'Cardiologist', 'Dermatologist', 'Gynaecologist',
    'Orthopaedic', 'Neurologist', 'Paediatrician', 'Psychiatrist',
    'Ophthalmologist', 'ENT Specialist', 'Diabetologist', 'Urologist',
  ];

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _selectedSpecialty == null) {
      setState(() { _error = true; _btnText = '⚠️  Please fill all fields'; });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() { _error = false; _btnText = 'Find Doctors Now →'; });
      });
      return;
    }
    setState(() { _success = true; _btnText = '✅  Request Sent!'; });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() {
        _success = false;
        _btnText = 'Find Doctors Now →';
        _nameCtrl.clear();
        _phoneCtrl.clear();
        _selectedSpecialty = null;
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navy, Color(0xFF1A2C4A)],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 80),
      child: Column(children: [
        // Section header
        _SectionHeader(),
        const SizedBox(height: 56),

        // How it works steps
        isWide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _StepsColumn()),
                const SizedBox(width: 56),
                SizedBox(width: 360, child: _QuickConsultCard(
                  nameCtrl: _nameCtrl,
                  phoneCtrl: _phoneCtrl,
                  selectedSpecialty: _selectedSpecialty,
                  onSpecialtyChanged: (v) => setState(() => _selectedSpecialty = v),
                  onSubmit: _submit,
                  btnText: _btnText,
                  success: _success,
                  error: _error,
                  specialties: _specialties,
                )),
              ])
            : Column(children: [
                _StepsColumn(),
                const SizedBox(height: 40),
                _QuickConsultCard(
                  nameCtrl: _nameCtrl,
                  phoneCtrl: _phoneCtrl,
                  selectedSpecialty: _selectedSpecialty,
                  onSpecialtyChanged: (v) => setState(() => _selectedSpecialty = v),
                  onSubmit: _submit,
                  btnText: _btnText,
                  success: _success,
                  error: _error,
                  specialties: _specialties,
                ),
              ]),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      FadeInDown(
        duration: const Duration(milliseconds: 800),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
          ),
          child: Text('HOW IT WORKS',
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 1.1)),
        ),
      ),
      const SizedBox(height: 14),
      FadeInUp(
        delay: const Duration(milliseconds: 100),
        duration: const Duration(milliseconds: 800),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.playfairDisplay(fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
            children: const [
              TextSpan(text: 'Healthcare in\n'),
              TextSpan(text: '3 Simple Steps', style: TextStyle(color: AppColors.blueMid)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      FadeInUp(
        delay: const Duration(milliseconds: 200),
        duration: const Duration(milliseconds: 800),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'Whether you need a doctor, a lab test or medicines — we connect you instantly with the best partners near you.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 15, color: Colors.white60, height: 1.7),
          ),
        ),
      ),
    ]);
  }
}

class _StepsColumn extends StatelessWidget {
  static const _steps = [
    _Step(
      number: '01',
      emoji: '🔍',
      title: 'Search & Discover',
      desc: 'Search for doctors by specialty, labs by test name, or medicines by brand. Filter by location, ratings, price and availability.',
      color: AppColors.blueMid,
    ),
    _Step(
      number: '02',
      emoji: '📅',
      title: 'Book or Order',
      desc: 'Pick a consultation slot, schedule a home lab collection, or place your medicine order — all in under 60 seconds.',
      color: Color(0xFF4ADE80),
    ),
    _Step(
      number: '03',
      emoji: '✅',
      title: 'Track & Manage',
      desc: 'Track your doctor in real time, get digital lab reports, reorder medicines with one tap, and manage all your health records.',
      color: Color(0xFFFBBF24),
    ),
  ];

  const _StepsColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length, (i) {
        final s = _steps[i];
        return FadeInLeft(
          delay: Duration(milliseconds: 100 + (i * 150)),
          duration: const Duration(milliseconds: 800),
          child: _StepItem(step: s, isLast: i == _steps.length - 1),
        );
      }),
    );
  }
}

class _Step {
  final String number;
  final String emoji;
  final String title;
  final String desc;
  final Color color;
  const _Step({required this.number, required this.emoji, required this.title, required this.desc, required this.color});
}

class _StepItem extends StatefulWidget {
  final _Step step;
  final bool isLast;
  const _StepItem({required this.step, required this.isLast});
  @override
  State<_StepItem> createState() => _StepItemState();
}

class _StepItemState extends State<_StepItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.step;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Left: number + connector line
      Column(children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _hovered ? s.color : s.color.withValues(alpha: 0.15),
              border: Border.all(color: s.color.withValues(alpha: 0.5), width: 1.5),
              boxShadow: _hovered ? [BoxShadow(color: s.color.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 4))] : [],
            ),
            child: Center(
              child: Text(s.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
        ),
        if (!widget.isLast)
          Container(
            width: 1, height: 60,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [s.color.withValues(alpha: 0.5), Colors.transparent],
              ),
            ),
          ),
      ]),
      const SizedBox(width: 22),

      // Right: content
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 48),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Step ${s.number}',
                    style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: s.color, letterSpacing: 0.5)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(s.title,
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 6),
            Text(s.desc,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.white60, height: 1.65)),
          ]),
        ),
      ),
    ]);
  }
}

class _QuickConsultCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final String? selectedSpecialty;
  final ValueChanged<String?> onSpecialtyChanged;
  final VoidCallback onSubmit;
  final String btnText;
  final bool success;
  final bool error;
  final List<String> specialties;

  const _QuickConsultCard({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.selectedSpecialty,
    required this.onSpecialtyChanged,
    required this.onSubmit,
    required this.btnText,
    required this.success,
    required this.error,
    required this.specialties,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 32, offset: const Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.blue.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.medical_services_outlined, color: Colors.white70, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Quick Consult Request',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
            Text('We\'ll match you in < 2 minutes',
                style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white38)),
          ])),
          // Heartbeat/Pulse Lottie next to Quick Consult form
          SizedBox(
            width: 44, height: 44,
            child: Lottie.network(
              'https://lottie.host/80cf3f1e-f3a7-47b7-bd6b-5dd31bb438e1/1xI2xPZ6jM.json', 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          )
        ]),
        const SizedBox(height: 22),

        _ApptInput(controller: nameCtrl, hint: 'Your Full Name', icon: Icons.person_outline),
        const SizedBox(height: 12),
        _ApptInput(controller: phoneCtrl, hint: 'Mobile Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _SpecialtyDropdown(selected: selectedSpecialty, specialties: specialties, onChanged: onSpecialtyChanged),
        const SizedBox(height: 20),

        _ConsultSubmitButton(text: btnText, success: success, error: error, onTap: onSubmit),
        const SizedBox(height: 16),

        // Trust line
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.shield_outlined, size: 13, color: Colors.white38),
          const SizedBox(width: 6),
          Text('100% confidential · No spam calls',
              style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white38)),
        ]),
      ]),
    );
  }
}

class _ApptInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _ApptInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textSoft),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSoft),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.92),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

class _SpecialtyDropdown extends StatelessWidget {
  final String? selected;
  final List<String> specialties;
  final ValueChanged<String?> onChanged;

  const _SpecialtyDropdown({required this.selected, required this.specialties, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Text('Select Specialty', style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textSoft)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSoft, size: 20),
          items: specialties.map((d) => DropdownMenuItem(
            value: d,
            child: Text(d, style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textDark)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ConsultSubmitButton extends StatefulWidget {
  final String text;
  final bool success;
  final bool error;
  final VoidCallback onTap;
  const _ConsultSubmitButton({required this.text, required this.success, required this.error, required this.onTap});
  @override
  State<_ConsultSubmitButton> createState() => _ConsultSubmitButtonState();
}

class _ConsultSubmitButtonState extends State<_ConsultSubmitButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (widget.success) bg = const Color(0xFF4ADE80);
    else if (widget.error) bg = AppColors.accent;
    else bg = AppColors.blue;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          transform: Matrix4.translationValues(0, _hovered ? -1 : 0, 0),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered ? [BoxShadow(color: bg.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 6))] : [],
          ),
          child: Center(child: Text(widget.text,
              style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white))),
        ),
      ),
    );
  }
}
