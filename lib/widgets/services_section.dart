import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';

class _ServiceData {
  final IconData icon;
  final String name;
  final String desc;
  final String partnerCount;
  final String badge;
  final String cta;
  final Color iconBg;
  final Color badgeColor;
  final Color badgeFg;
  final bool isHot;

  const _ServiceData({
    required this.icon,
    required this.name,
    required this.desc,
    required this.partnerCount,
    required this.badge,
    required this.cta,
    required this.iconBg,
    required this.badgeColor,
    required this.badgeFg,
    this.isHot = false,
  });
}

const _services = [
  _ServiceData(
    icon: Icons.medical_services_outlined,
    name: 'Consult a Doctor',
    desc:
        'Video or in-clinic consultations with 2,000+ verified specialists across 35+ specialties. Same-day slots available.',
    partnerCount: '2,000+ Doctors',
    badge: 'Avg. 8 min wait',
    cta: 'Consult Now',
    iconBg: Color(0xFFE8F4FD),
    badgeColor: Color(0xFFE8F4FD),
    badgeFg: Color(0xFF1565C0),
    isHot: true,
  ),
  _ServiceData(
    icon: Icons.science_outlined,
    name: 'Book Lab Tests',
    desc:
        '500+ tests from 300+ NABL-accredited partner labs. Home collection available. Reports in your pocket within hours.',
    partnerCount: '300+ NABL Labs',
    badge: 'Home collection',
    cta: 'Book a Test',
    iconBg: Color(0xFFEDF7ED),
    badgeColor: Color(0xFFEDF7ED),
    badgeFg: Color(0xFF1B5E20),
  ),
  _ServiceData(
    icon: Icons.medication_outlined,
    name: 'Order Medicines',
    desc:
        'Upload prescription & order from 200+ partner pharmacies. Genuine medicines, fast delivery, great prices.',
    partnerCount: '200+ Pharmacies',
    badge: '2-hr delivery',
    cta: 'Order Now',
    iconBg: Color(0xFFFFF3E0),
    badgeColor: Color(0xFFFFF3E0),
    badgeFg: Color(0xFFE65100),
    isHot: true,
  ),
  _ServiceData(
    icon: Icons.local_hospital_outlined,
    name: 'Find Hospitals',
    desc:
        'Discover 150+ partner hospitals near you — compare ratings, bed availability, specialties and insurance coverage.',
    partnerCount: '150+ Hospitals',
    badge: 'View reviews',
    cta: 'Find Nearby',
    iconBg: Color(0xFFF3E8FF),
    badgeColor: Color(0xFFF3E8FF),
    badgeFg: Color(0xFF4A148C),
  ),
  _ServiceData(
    icon: Icons.emergency_outlined,
    name: 'Emergency Ambulance',
    desc:
        'Dispatch a verified ALS/BLS ambulance in under 10 minutes. Our partner fleet operates 24/7 across all cities.',
    partnerCount: 'Fleet Partners',
    badge: '10-min response',
    cta: 'Call Ambulance',
    iconBg: Color(0xFFFFEBEE),
    badgeColor: Color(0xFFFFEBEE),
    badgeFg: Color(0xFFB71C1C),
  ),
  _ServiceData(
    icon: Icons.assignment_outlined,
    name: 'Health Packages',
    desc:
        'Preventive full-body checkups, diabetes panels, thyroid profiles and more — starting from just ₹499.',
    partnerCount: 'Partner Labs',
    badge: 'From ₹499',
    cta: 'View Packages',
    iconBg: Color(0xFFE8F4FD),
    badgeColor: Color(0xFFE8F4FD),
    badgeFg: Color(0xFF1565C0),
  ),
];

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 1100
        ? 3
        : width > 700
        ? 2
        : 1;

    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.symmetric(
        horizontal: width > 900 ? 64 : 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          _SectionHeader(
            eyebrow: 'What We Connect You With',
            title: 'Everything Healthcare, One App',
            subtitle:
                'We partner with the best labs, pharmacies, hospitals and doctors — so you never have to search again.',
          ),
          const SizedBox(height: 52),
          LayoutBuilder(
            builder: (_, constraints) {
              return Wrap(
                spacing: 22,
                runSpacing: 22,
                children: _services
                    .asMap()
                    .entries
                    .map(
                      (entry) => SizedBox(
                        width: (constraints.maxWidth - (cols - 1) * 22) / cols,
                        child: FadeInUp(
                          delay: Duration(
                            milliseconds: 100 + (entry.key * 100),
                          ),
                          duration: const Duration(milliseconds: 800),
                          child: _ServiceCard(service: entry.value),
                        ),
                      ),
                    )
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
  Offset _mousePos = Offset(150, 150); // Default center

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    // Calculate cinematic 3D tilts (assumes typical card size ~ 300x300)
    final double tiltX = (_mousePos.dy - 150) / 150 * 0.05;
    final double tiltY = (_mousePos.dx - 150) / 150 * -0.05;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _mousePos = const Offset(150, 150);
      }),
      onHover: (e) {
        if (mounted && _hovered) {
          setState(() {
            _mousePos = e.localPosition;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateX(_hovered ? tiltX : 0)
          ..rotateY(_hovered ? tiltY : 0)
          ..translate(0.0, _hovered ? -8.0 : 0.0, 0.0),
        transformAlignment: FractionalOffset.center,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered ? Colors.transparent : AppColors.border,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + HOT badge
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: s.iconBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  transform: _hovered
                      ? (Matrix4.identity()..scale(1.12))
                      : Matrix4.identity(),
                  child: Center(
                    child: Icon(s.icon, size: 28, color: AppColors.textDark),
                  ),
                ),
                const Spacer(),
                if (s.isHot)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Popular',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // Name
            Text(
              s.name,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),

            // Partner count
            Row(
              children: [
                const Icon(
                  Icons.business_center_outlined,
                  size: 13,
                  color: AppColors.textSoft,
                ),
                const SizedBox(width: 4),
                Text(
                  s.partnerCount,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSoft,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              s.desc,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.textMid,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 18),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: s.badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingDot(color: s.badgeFg),
                  const SizedBox(width: 6),
                  Text(
                    s.badge,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: s.badgeFg,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // CTA link
            _ServiceLink(label: s.cta),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1, end: 0.3).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    ),
  );
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
            Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.blue,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: _hovered ? 10 : 5),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.blue,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blueLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
            ),
            child: Text(
              eyebrow.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeInUp(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 800),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 800),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15.5,
                color: AppColors.textMid,
                height: 1.7,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeIn(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 800),
          child: Container(
            width: 50,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.blue, AppColors.blueMid],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}
