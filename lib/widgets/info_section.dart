import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width > 1100
        ? 4
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
          _SectionHeader(),
          const SizedBox(height: 52),
          // Popular categories
          LayoutBuilder(
            builder: (_, constraints) {
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: _popularCards
                    .map(
                      (c) => SizedBox(
                        width: (constraints.maxWidth - (cols - 1) * 20) / cols,
                        child: _PopularCard(card: c),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 56),

          // App download banner
          _AppBanner(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.blueLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
          ),
          child: Text(
            'TRENDING NOW',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.blue,
              letterSpacing: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Most Booked This Week',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(
            'See what thousands of patients are booking on MyHospital right now.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textMid,
              height: 1.7,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blue, AppColors.blueMid],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _PopularCardData {
  final IconData icon;
  final String category;
  final String title;
  final List<String> items;
  final Color iconBg;
  final Color accentColor;
  final String tag;
  const _PopularCardData({
    required this.icon,
    required this.category,
    required this.title,
    required this.items,
    required this.iconBg,
    required this.accentColor,
    required this.tag,
  });
}

const _popularCards = [
  _PopularCardData(
    icon: Icons.emoji_events_outlined,
    category: 'Top Doctors',
    title: 'Most Consulted',
    items: [
      'Dr. A. Sharma — Cardiologist',
      'Dr. P. Nair — Gynaecologist',
      'Dr. R. Mehta — General Physician',
      'Dr. S. Kumar — Neurologist',
    ],
    iconBg: Color(0xFFE8F4FD),
    accentColor: Color(0xFF1565C0),
    tag: '2,000+ Doctors',
  ),
  _PopularCardData(
    icon: Icons.science_outlined,
    category: 'Lab Tests',
    title: 'Most Booked Tests',
    items: [
      'Complete Blood Count (CBC)',
      'HbA1c — Diabetes Panel',
      'Thyroid Profile (T3/T4/TSH)',
      'Liver Function Test (LFT)',
    ],
    iconBg: Color(0xFFEDF7ED),
    accentColor: Color(0xFF2E7D32),
    tag: '500+ Tests',
  ),
  _PopularCardData(
    icon: Icons.medication_outlined,
    category: 'Medicines',
    title: 'Fast-Moving Items',
    items: [
      'Metformin 500mg (Diabetes)',
      'Paracetamol 650mg (Fever)',
      'Amlodipine 5mg (BP)',
      'Vitamin D3 + K2 Sachets',
    ],
    iconBg: Color(0xFFFFF3E0),
    accentColor: Color(0xFFE65100),
    tag: '10,000+ Products',
  ),
  _PopularCardData(
    icon: Icons.health_and_safety_outlined,
    category: 'Health Packages',
    title: 'Best Value Packs',
    items: [
      'Full Body Basic — ₹499',
      'Diabetes Care Pack — ₹799',
      'Heart Health Screen — ₹1,299',
      'Annual Wellness Plan — ₹1,999',
    ],
    iconBg: Color(0xFFF3E8FF),
    accentColor: Color(0xFF6A1B9A),
    tag: 'Starting ₹499',
  ),
];

class _PopularCard extends StatefulWidget {
  final _PopularCardData card;
  const _PopularCard({required this.card});
  @override
  State<_PopularCard> createState() => _PopularCardState();
}

class _PopularCardState extends State<_PopularCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? c.accentColor.withValues(alpha: 0.3)
                : AppColors.border,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: c.accentColor.withValues(alpha: 0.1),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: c.iconBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Icon(c.icon, size: 21, color: c.accentColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.category,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: c.accentColor,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          c.title,
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: c.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      c.tag,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: c.accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Items
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...c.items.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: c.iconBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: c.accentColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.value,
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                color: AppColors.textMid,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _SeeAllLink(color: c.accentColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeeAllLink extends StatefulWidget {
  final Color color;
  const _SeeAllLink({required this.color});
  @override
  State<_SeeAllLink> createState() => _SeeAllLinkState();
}

class _SeeAllLinkState extends State<_SeeAllLink> {
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
              'See all',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(left: _hovered ? 8 : 4),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: widget.color,
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App Download Banner
class _AppBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navy],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.4),
            blurRadius: 32,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: _BannerText()),
                const SizedBox(width: 32),
                _BannerButtons(),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BannerText(),
                const SizedBox(height: 24),
                _BannerButtons(),
              ],
            ),
    );
  }
}

class _BannerText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get the MyHospital App',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white54,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your Complete Health Companion',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Book, track and manage all your healthcare needs on the go.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.white54,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _BannerButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StoreButton(
          icon: Icons.apple,
          label: 'App Store',
          sub: 'Download on the',
        ),
        const SizedBox(width: 12),
        _StoreButton(
          icon: Icons.android,
          label: 'Google Play',
          sub: 'Get it on',
        ),
      ],
    );
  }
}

class _StoreButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _StoreButton({
    required this.icon,
    required this.label,
    required this.sub,
  });
  @override
  State<_StoreButton> createState() => _StoreButtonState();
}

class _StoreButtonState extends State<_StoreButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: _hovered ? 0 : 0.2),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: _hovered ? AppColors.navy : Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sub,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: _hovered ? AppColors.textSoft : Colors.white54,
                    ),
                  ),
                  Text(
                    widget.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _hovered ? AppColors.navy : Colors.white,
                    ),
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
