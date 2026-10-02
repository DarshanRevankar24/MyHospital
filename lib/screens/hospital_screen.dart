import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Hospital listing and booking flow with animated cards,
/// doctor profiles, and slot picker.
class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  String _searchQuery = '';
  String? _selectedSpecialty;

  static const _specialties = [
    'All', 'Cardiology', 'Orthopaedics', 'Neurology', 'Gynaecology',
    'Paediatrics', 'Dermatology', 'Ophthalmology', 'ENT', 'Oncology',
    'Dentistry', 'Emergency',
  ];

  static const _hospitals = [
    _HospitalData(name: 'Apollo Hospital', location: 'Bannerghatta Road, Bengaluru', rating: 4.8, beds: 450, specialties: ['Cardiology', 'Neurology', 'Oncology'], img: '🏥', isOpen: true),
    _HospitalData(name: 'Manipal Hospital', location: 'HAL Airport Road, Bengaluru', rating: 4.7, beds: 600, specialties: ['Orthopaedics', 'Paediatrics', 'Emergency'], img: '🏥', isOpen: true),
    _HospitalData(name: 'Fortis Hospital', location: 'Rajajinagar, Bengaluru', rating: 4.6, beds: 320, specialties: ['Cardiology', 'Gynaecology', 'Dermatology'], img: '🏥', isOpen: true),
    _HospitalData(name: 'Narayana Health', location: 'Bommasandra, Bengaluru', rating: 4.9, beds: 800, specialties: ['Cardiology', 'Oncology', 'Emergency'], img: '🏥', isOpen: false),
    _HospitalData(name: 'Columbia Asia', location: 'Hebbal, Bengaluru', rating: 4.5, beds: 200, specialties: ['Orthopaedics', 'ENT', 'Ophthalmology'], img: '🏥', isOpen: true),
    _HospitalData(name: 'Sakra World', location: 'Devarabeesanahalli, Bengaluru', rating: 4.7, beds: 350, specialties: ['Neurology', 'Paediatrics', 'Dentistry'], img: '🏥', isOpen: true),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;
    final filtered = _hospitals.where((h) {
      if (_searchQuery.isNotEmpty &&
          !h.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedSpecialty != null &&
          _selectedSpecialty != 'All' &&
          !h.specialties.contains(_selectedSpecialty)) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(context),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _GradientBanner(
                emoji: '🏥',
                title: 'Find Hospitals',
                subtitle: 'Browse 150+ verified partner hospitals near you',
              ),
              const SizedBox(height: 24),

              // Search & Filter
              _SearchFilterBar(
                onSearchChanged: (v) => setState(() => _searchQuery = v),
                specialties: _specialties,
                selectedSpecialty: _selectedSpecialty,
                onSpecialtyChanged: (v) =>
                    setState(() => _selectedSpecialty = v),
              ),
              const SizedBox(height: 24),

              // Results count
              Text('${filtered.length} hospitals found',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppColors.textSoft)),
              const SizedBox(height: 16),

              // Hospital Cards
              LayoutBuilder(
                builder: (_, constraints) {
                  final cols = constraints.maxWidth > 800 ? 2 : 1;
                  return Wrap(
                    spacing: 18,
                    runSpacing: 18,
                    children: filtered
                        .map((h) => SizedBox(
                              width: (constraints.maxWidth -
                                      (cols - 1) * 18) /
                                  cols,
                              child: _HospitalCard(hospital: h),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        color: AppColors.textMid,
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('Hospitals',
          style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }
}

class _HospitalData {
  final String name, location, img;
  final double rating;
  final int beds;
  final List<String> specialties;
  final bool isOpen;
  const _HospitalData({
    required this.name,
    required this.location,
    required this.rating,
    required this.beds,
    required this.specialties,
    required this.img,
    required this.isOpen,
  });
}

// ── Gradient Banner for section headers
class _GradientBanner extends StatelessWidget {
  final String emoji, title, subtitle;
  const _GradientBanner(
      {required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navy, Color(0xFF1A2C4A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.white54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search & Filter Bar
class _SearchFilterBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final List<String> specialties;
  final String? selectedSpecialty;
  final ValueChanged<String?> onSpecialtyChanged;

  const _SearchFilterBar({
    required this.onSearchChanged,
    required this.specialties,
    required this.selectedSpecialty,
    required this.onSpecialtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: TextField(
            onChanged: onSearchChanged,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Search hospitals by name…',
              hintStyle:
                  GoogleFonts.inter(fontSize: 14, color: AppColors.textSoft),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 20, color: AppColors.textSoft),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: specialties.map((s) {
              final active = s == selectedSpecialty ||
                  (s == 'All' && selectedSpecialty == null);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: s,
                  isActive: active,
                  onTap: () =>
                      onSpecialtyChanged(s == 'All' ? null : s),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.isActive, required this.onTap});
  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: widget.isActive ? AppColors.blue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: widget.isActive
                    ? AppColors.blue
                    : _hovered
                        ? AppColors.blue.withValues(alpha: 0.3)
                        : AppColors.border),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                        color: AppColors.blue.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Text(widget.label,
              style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: widget.isActive ? Colors.white : AppColors.textMid)),
        ),
      ),
    );
  }
}

// ── Hospital Card
class _HospitalCard extends StatefulWidget {
  final _HospitalData hospital;
  const _HospitalCard({required this.hospital});
  @override
  State<_HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<_HospitalCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final h = widget.hospital;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Show booking dialog
          showDialog(
              context: context,
              builder: (_) => _BookingDialog(hospital: h));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: _hovered ? Colors.transparent : AppColors.border),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: AppColors.blue.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 10))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    transform: _hovered
                        ? (Matrix4.identity()..scale(1.08))
                        : Matrix4.identity(),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                        child:
                            Text('🏥', style: TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h.name,
                            style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                                size: 13, color: AppColors.textSoft),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(h.location,
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSoft),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: h.isOpen
                              ? const Color(0xFFEDF7ED)
                              : const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(h.isOpen ? '● Open' : '● Closed',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: h.isOpen
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFE65100))),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Color(0xFFFBBF24)),
                          Text(' ${h.rating}',
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Specialties
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: h.specialties
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.blueLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(s,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blue)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 14),
              // Bottom stats
              Row(
                children: [
                  _MiniInfo(icon: Icons.bed_outlined, text: '${h.beds} beds'),
                  const SizedBox(width: 16),
                  _MiniInfo(
                      icon: Icons.local_parking_outlined,
                      text: 'Parking'),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppColors.blue, AppColors.blueMid]),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.blue.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Text('Book Now',
                        style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MiniInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSoft),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.textSoft)),
      ],
    );
  }
}

// ── Booking Dialog
class _BookingDialog extends StatefulWidget {
  final _HospitalData hospital;
  const _BookingDialog({required this.hospital});
  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _step = 0; // 0=select doctor, 1=select slot, 2=confirm
  String? _selectedDoctor;
  String? _selectedSlot;
  bool _isBooking = false;

  static const _doctors = [
    'Dr. Priya Sharma · Cardiologist',
    'Dr. Raj Patel · General Physician',
    'Dr. Anjali Rao · Neurologist',
    'Dr. Vikram Singh · Orthopaedic',
  ];

  static const _slots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM',
    '11:00 AM', '02:00 PM', '02:30 PM', '03:00 PM',
    '04:00 PM', '04:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 16)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                        child: Text('🏥',
                            style: TextStyle(fontSize: 22))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.hospital.name,
                            style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark)),
                        Text('Book an Appointment',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSoft)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        size: 20, color: AppColors.textSoft),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Progress indicator
              _StepIndicator(step: _step),
              const SizedBox(height: 24),

              // Step content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 0
                    ? _DoctorPicker(
                        key: const ValueKey(0),
                        doctors: _doctors,
                        selected: _selectedDoctor,
                        onSelect: (d) {
                          setState(() {
                            _selectedDoctor = d;
                            _step = 1;
                          });
                        },
                      )
                    : _step == 1
                        ? _SlotPicker(
                            key: const ValueKey(1),
                            slots: _slots,
                            selected: _selectedSlot,
                            onSelect: (s) {
                              setState(() {
                                _selectedSlot = s;
                                _step = 2;
                              });
                            },
                          )
                        : _ConfirmBooking(
                            key: const ValueKey(2),
                            hospital: widget.hospital.name,
                            doctor: _selectedDoctor!,
                            slot: _selectedSlot!,
                            isBooking: _isBooking,
                            onConfirm: () async {
                              setState(() => _isBooking = true);
                              await Future.delayed(
                                  const Duration(seconds: 2));
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      '✅ Appointment booked successfully!',
                                      style: GoogleFonts.inter(
                                          color: Colors.white)),
                                  backgroundColor:
                                      const Color(0xFF4ADE80),
                                  behavior:
                                      SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ));
                              }
                            },
                            onBack: () =>
                                setState(() => _step = 1),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final labels = ['Doctor', 'Time Slot', 'Confirm'];
        final active = i <= step;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.blue : AppColors.bg,
                  border: Border.all(
                      color:
                          active ? AppColors.blue : AppColors.border),
                ),
                child: Center(
                  child: active && i < step
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : Text('${i + 1}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : AppColors.textSoft)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(labels[i],
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight:
                            active ? FontWeight.w600 : FontWeight.w500,
                        color: active
                            ? AppColors.textDark
                            : AppColors.textSoft)),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _DoctorPicker extends StatelessWidget {
  final List<String> doctors;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _DoctorPicker(
      {super.key,
      required this.doctors,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select a Doctor',
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 14),
        ...doctors.map((d) => _DoctorTile(
            doctor: d,
            isSelected: d == selected,
            onTap: () => onSelect(d))),
      ],
    );
  }
}

class _DoctorTile extends StatefulWidget {
  final String doctor;
  final bool isSelected;
  final VoidCallback onTap;
  const _DoctorTile(
      {required this.doctor, required this.isSelected, required this.onTap});
  @override
  State<_DoctorTile> createState() => _DoctorTileState();
}

class _DoctorTileState extends State<_DoctorTile> {
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
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered || widget.isSelected
                ? AppColors.blueLight
                : AppColors.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: widget.isSelected
                    ? AppColors.blue
                    : _hovered
                        ? AppColors.blue.withValues(alpha: 0.3)
                        : AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [AppColors.blue, AppColors.blueMid]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child: Text(
                        widget.doctor
                            .split(' ')
                            .where((w) =>
                                w.length > 1 && w[0] == w[0].toUpperCase())
                            .map((w) => w[0])
                            .take(2)
                            .join(),
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(widget.doctor,
                    style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
              ),
              Icon(
                  widget.isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 20,
                  color: widget.isSelected
                      ? AppColors.blue
                      : AppColors.textSoft),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotPicker extends StatelessWidget {
  final List<String> slots;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _SlotPicker(
      {super.key,
      required this.slots,
      required this.selected,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pick a Time Slot',
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: slots.map((s) => _SlotChip(
              slot: s,
              isSelected: s == selected,
              onTap: () => onSelect(s))).toList(),
        ),
      ],
    );
  }
}

class _SlotChip extends StatefulWidget {
  final String slot;
  final bool isSelected;
  final VoidCallback onTap;
  const _SlotChip(
      {required this.slot, required this.isSelected, required this.onTap});
  @override
  State<_SlotChip> createState() => _SlotChipState();
}

class _SlotChipState extends State<_SlotChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.blue
                : _hovered
                    ? AppColors.blueLight
                    : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: widget.isSelected
                    ? AppColors.blue
                    : AppColors.border),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                        color: AppColors.blue.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ]
                : [],
          ),
          child: Text(widget.slot,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.textMid)),
        ),
      ),
    );
  }
}

class _ConfirmBooking extends StatelessWidget {
  final String hospital, doctor, slot;
  final bool isBooking;
  final VoidCallback onConfirm, onBack;
  const _ConfirmBooking({
    super.key,
    required this.hospital,
    required this.doctor,
    required this.slot,
    required this.isBooking,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm Booking',
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 16),
        _ConfirmRow(label: 'Hospital', value: hospital),
        _ConfirmRow(label: 'Doctor', value: doctor),
        _ConfirmRow(label: 'Time', value: slot),
        _ConfirmRow(label: 'Date', value: 'Today'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                      child: Text('← Back',
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMid))),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: isBooking ? null : onConfirm,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppColors.blue, AppColors.blueMid]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color:
                              AppColors.blue.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: isBooking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white))
                        : Text('✓ Confirm Booking',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final String label, value;
  const _ConfirmRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12.5, color: AppColors.textSoft)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }
}
