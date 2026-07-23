import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class _ServiceData {
  final String emoji;
  final String name;
  final String desc;
  final String status;
  final bool isAvailable;
  final String link;
  final Color iconBg;

  const _ServiceData({
    required this.emoji,
    required this.name,
    required this.desc,
    required this.status,
    required this.isAvailable,
    required this.link,
    required this.iconBg,
  });
}

const _services = [
  _ServiceData(
    emoji: '🚑',
    name: 'Ambulance Services',
    desc: 'Round-the-clock emergency ambulance fleet with trained paramedics, ALS and BLS vehicles for rapid city-wide response.',
    status: 'Available 24/7',
    isAvailable: true,
    link: 'Request Ambulance',
    iconBg: AppColors.icRed,
  ),
  _ServiceData(
    emoji: '🩸',
    name: 'Blood Bank',
    desc: 'Fully equipped blood bank with all blood groups including rare types. Weekly donation drives and instant availability for emergencies.',
    status: 'All Groups Available',
    isAvailable: true,
    link: 'Check Availability',
    iconBg: AppColors.icRed,
  ),
  _ServiceData(
    emoji: '🔬',
    name: 'Laboratory & Diagnostics',
    desc: 'NABL-accredited pathology lab offering 500+ tests. CBC, LFT, KFT, thyroid, hormonal assays and rapid point-of-care tests.',
    status: 'Reports in 4–6 hrs',
    isAvailable: true,
    link: 'Book a Test',
    iconBg: AppColors.icBlue,
  ),
  _ServiceData(
    emoji: '👨‍⚕️',
    name: 'Medical Consultancy',
    desc: '120+ specialist doctors across 30+ departments. In-person and tele-consultation available. Same-day slots for urgent cases.',
    status: 'Slots Available Today',
    isAvailable: true,
    link: 'Meet Our Doctors',
    iconBg: AppColors.tealLight,
  ),
  _ServiceData(
    emoji: '💊',
    name: 'In-House Pharmacy',
    desc: 'Stocked with 10,000+ generic and branded medicines, surgical supplies, and supplements. Prescription upload & home delivery.',
    status: 'Open 24 Hours',
    isAvailable: true,
    link: 'Order Medicines',
    iconBg: AppColors.icGreen,
  ),
  _ServiceData(
    emoji: '🩻',
    name: 'Imaging & Scanning',
    desc: '3T MRI, 128-slice CT, digital X-ray, 4D Ultrasound, PET scan, mammography, DEXA. Radiologist reports within 2 hours for urgent cases.',
    status: 'Moderate Wait – Book Ahead',
    isAvailable: false,
    link: 'Schedule Scan',
    iconBg: AppColors.icPurple,
  ),
];

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1100 ? 3 : width > 700 ? 2 : 1;

    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.symmetric(horizontal: width > 900 ? 60 : 24, vertical: 72),
      child: Column(
        children: [
          _SectionHeader(
            eyebrow: 'What We Offer',
            title: 'Comprehensive Medical Services',
            subtitle: 'Everything you need under one roof — from emergency response to preventive care.',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (_, constraints) {
              return Wrap(
                spacing: 22,
                runSpacing: 22,
                children: _services
                    .map((s) => SizedBox(
                          width: (constraints.maxWidth - (crossAxisCount - 1) * 22) / crossAxisCount,
                          child: _ServiceCard(service: s),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final _ServiceData service;
  const _ServiceCard({required this.service});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _hovered ? Colors.transparent : AppColors.border),
          boxShadow: _hovered
              ? [BoxShadow(color: AppColors.teal.withOpacity(0.14), blurRadius: 36, offset: const Offset(0, 12))]
              : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top accent bar
            if (_hovered)
              Container(
                height: 3,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealMid]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: s.iconBg,
                borderRadius: BorderRadius.circular(15),
              ),
              transform: _hovered
                  ? (Matrix4.identity()..scale(1.1)..rotateZ(-0.05))
                  : Matrix4.identity(),
              child: Center(child: Text(s.emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: 18),

            // Name
            Text(s.name,
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 10),

            // Description
            Text(s.desc,
                style: GoogleFonts.inter(
                    fontSize: 13.5, color: AppColors.textMid, height: 1.65)),
            const SizedBox(height: 18),

            // Status badge
            _StatusBadge(text: s.status, isAvailable: s.isAvailable),
            const SizedBox(height: 16),

            // Link
            _ServiceLink(label: s.link),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatefulWidget {
  final String text;
  final bool isAvailable;
  const _StatusBadge({required this.text, required this.isAvailable});

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1, end: 0.3).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isAvailable ? const Color(0xFFE6FAF0) : const Color(0xFFFFF8E6);
    final fg = widget.isAvailable ? const Color(0xFF1A7A4C) : const Color(0xFFB36F00);
    final dotColor = widget.isAvailable ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isAvailable)
            FadeTransition(
              opacity: _opacity,
              child: Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            )
          else
            Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(widget.text,
              style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

class _ServiceLink extends StatefulWidget {
  final String label;
  const _ServiceLink({required this.label});

  @override
  State<_ServiceLink> createState() => _ServiceLinkState();
}

class _ServiceLinkState extends State<_ServiceLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: _hovered ? 10 : 6),
              child: const Icon(Icons.chevron_right, color: AppColors.teal, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const _SectionHeader({required this.eyebrow, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(eyebrow.toUpperCase(),
            style: GoogleFonts.inter(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.teal, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        Text(title,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
                fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 15, color: AppColors.textMid, height: 1.7),
            maxLines: 3),
        const SizedBox(height: 14),
        Container(width: 50, height: 3, decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }
}
