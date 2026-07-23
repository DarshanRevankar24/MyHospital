import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AppointmentSection extends StatefulWidget {
  const AppointmentSection({super.key});

  @override
  State<AppointmentSection> createState() => _AppointmentSectionState();
}

class _AppointmentSectionState extends State<AppointmentSection> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedDept;
  DateTime? _selectedDate;
  String _btnText = 'Confirm Appointment →';
  bool _success = false;
  bool _error = false;

  static const _depts = [
    'Ambulance', 'Blood Bank', 'Laboratory', 'Consultancy',
    'Pharmacy', 'Scanning', 'Emergency', 'General OPD',
  ];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.teal),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _selectedDept == null ||
        _selectedDate == null) {
      setState(() { _error = true; _btnText = '⚠️  Please fill all fields'; });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() { _error = false; _btnText = 'Confirm Appointment →'; });
      });
      return;
    }
    setState(() { _success = true; _btnText = '✅  Appointment Confirmed!'; });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _success = false;
          _btnText = 'Confirm Appointment →';
          _nameCtrl.clear();
          _phoneCtrl.clear();
          _selectedDept = null;
          _selectedDate = null;
        });
      }
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
          colors: [AppColors.tealDark, AppColors.tealMid],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: isWide ? 60 : 24, vertical: 64),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _LeftContent()),
                const SizedBox(width: 48),
                SizedBox(width: 340, child: _FormCard(
                  nameCtrl: _nameCtrl,
                  phoneCtrl: _phoneCtrl,
                  selectedDept: _selectedDept,
                  selectedDate: _selectedDate,
                  onDeptChanged: (v) => setState(() => _selectedDept = v),
                  onPickDate: _pickDate,
                  onSubmit: _submit,
                  btnText: _btnText,
                  success: _success,
                  error: _error,
                )),
              ],
            )
          : Column(
              children: [
                _LeftContent(),
                const SizedBox(height: 36),
                _FormCard(
                  nameCtrl: _nameCtrl,
                  phoneCtrl: _phoneCtrl,
                  selectedDept: _selectedDept,
                  selectedDate: _selectedDate,
                  onDeptChanged: (v) => setState(() => _selectedDept = v),
                  onPickDate: _pickDate,
                  onSubmit: _submit,
                  btnText: _btnText,
                  success: _success,
                  error: _error,
                ),
              ],
            ),
    );
  }
}

class _LeftContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Book Your Appointment Today',
            style: GoogleFonts.playfairDisplay(
                fontSize: 34, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2)),
        const SizedBox(height: 14),
        Text(
          'Connect with our specialists in just 60 seconds.\nSame-day appointments available for urgent consultations.',
          style: GoogleFonts.inter(fontSize: 15, color: Colors.white70, height: 1.7),
        ),
        const SizedBox(height: 28),
        _InfoChip(icon: Icons.check_circle_outline, text: 'NABH Accredited Facility'),
        const SizedBox(height: 10),
        _InfoChip(icon: Icons.check_circle_outline, text: '120+ Specialist Doctors'),
        const SizedBox(height: 10),
        _InfoChip(icon: Icons.check_circle_outline, text: 'Cashless Treatment Available'),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white60),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.inter(fontSize: 13.5, color: Colors.white70, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final String? selectedDept;
  final DateTime? selectedDate;
  final ValueChanged<String?> onDeptChanged;
  final VoidCallback onPickDate;
  final VoidCallback onSubmit;
  final String btnText;
  final bool success;
  final bool error;

  static const _depts = [
    'Ambulance', 'Blood Bank', 'Laboratory', 'Consultancy',
    'Pharmacy', 'Scanning', 'Emergency', 'General OPD',
  ];

  const _FormCard({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.selectedDept,
    required this.selectedDate,
    required this.onDeptChanged,
    required this.onPickDate,
    required this.onSubmit,
    required this.btnText,
    required this.success,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📅  Schedule a Visit',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
          const SizedBox(height: 16),
          _ApptInput(controller: nameCtrl, hint: 'Your Full Name', icon: Icons.person_outline),
          const SizedBox(height: 12),
          _ApptInput(controller: phoneCtrl, hint: 'Mobile Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _DeptDropdown(selected: selectedDept, depts: _depts, onChanged: onDeptChanged),
          const SizedBox(height: 12),
          _DatePicker(date: selectedDate, onTap: onPickDate),
          const SizedBox(height: 18),
          _SubmitButton(text: btnText, success: success, error: error, onTap: onSubmit),
        ],
      ),
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
        fillColor: Colors.white.withOpacity(0.92),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}

class _DeptDropdown extends StatelessWidget {
  final String? selected;
  final List<String> depts;
  final ValueChanged<String?> onChanged;

  const _DeptDropdown({required this.selected, required this.depts, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Text('Select Department',
              style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textSoft)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSoft, size: 20),
          items: depts
              .map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(d, style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textDark)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;
  const _DatePicker({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSoft),
            const SizedBox(width: 10),
            Text(
              date == null
                  ? 'Select Date'
                  : '${date!.day}/${date!.month}/${date!.year}',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: date == null ? AppColors.textSoft : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final String text;
  final bool success;
  final bool error;
  final VoidCallback onTap;
  const _SubmitButton({required this.text, required this.success, required this.error, required this.onTap});

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color fg = AppColors.tealDark;

    if (widget.success) { bg = const Color(0xFFE6FAF0); fg = const Color(0xFF1A7A4C); }
    if (widget.error) { bg = AppColors.accentSoft; fg = AppColors.accent; }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          transform: Matrix4.translationValues(0, _hovered ? -1 : 0, 0),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _hovered ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          child: Center(
            child: Text(widget.text,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
          ),
        ),
      ),
    );
  }
}
