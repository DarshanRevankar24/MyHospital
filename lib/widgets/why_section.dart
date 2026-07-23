import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class WhySection extends StatelessWidget {
  const WhySection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 60 : 24, vertical: 72),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _WhyImage()),
                const SizedBox(width: 60),
                Expanded(child: _WhyContent()),
              ],
            )
          : Column(
              children: [
                _WhyImage(),
                const SizedBox(height: 40),
                _WhyContent(),
              ],
            ),
    );
  }
}

class _WhyImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(
            'web/hero_medical.png',
            height: 460,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 460,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.tealLight, AppColors.tealMid.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(Icons.local_hospital, size: 80, color: AppColors.teal),
              ),
            ),
          ),
        ),
        // Floating badge bottom-right
        Positioned(
          bottom: 30,
          right: -20,
          child: _FloatingBadge(emoji: '🏆', number: 'NABH', subtitle: 'Accredited since 2010'),
        ),
        // Floating badge top-left
        Positioned(
          top: 30,
          left: -20,
          child: _FloatingBadge(emoji: '⭐', number: '4.9/5', subtitle: 'Patient Satisfaction'),
        ),
      ],
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final String emoji;
  final String number;
  final String subtitle;

  const _FloatingBadge({required this.emoji, required this.number, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.14), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(number,
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.teal, height: 1)),
              Text(subtitle,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSoft, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WhyContent extends StatelessWidget {
  static const _features = [
    _Feature(
      emoji: '🏥',
      title: 'Advanced Infrastructure',
      desc: '6 operation theatres, 40-bed ICU, HDU, and 300-bed capacity with cutting-edge medical equipment.',
    ),
    _Feature(
      emoji: '🩺',
      title: 'Expert Medical Team',
      desc: 'Super-specialists with international training and decades of combined clinical experience.',
    ),
    _Feature(
      emoji: '📱',
      title: 'Digital Patient Experience',
      desc: 'Online appointments, digital prescriptions, tele-consult, and e-reports – healthcare at your fingertips.',
    ),
    _Feature(
      emoji: '💳',
      title: 'Cashless & Insurance',
      desc: 'Empanelled with 50+ insurance companies and all major TPAs. CGHS & ECHS approved facility.',
    ),
  ];

  const _WhyContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('WHY MYHOSPITAL',
            style: GoogleFonts.inter(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.teal, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textDark),
            children: const [
              TextSpan(text: 'Care You Can '),
              TextSpan(text: 'Trust', style: TextStyle(color: AppColors.teal)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(width: 50, height: 3, decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 28),
        ..._features.map((f) => _FeatureItem(feature: f)),
      ],
    );
  }
}

class _Feature {
  final String emoji;
  final String title;
  final String desc;
  const _Feature({required this.emoji, required this.title, required this.desc});
}

class _FeatureItem extends StatefulWidget {
  final _Feature feature;
  const _FeatureItem({required this.feature});

  @override
  State<_FeatureItem> createState() => _FeatureItemState();
}

class _FeatureItemState extends State<_FeatureItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.tealLight : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(widget.feature.emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.feature.title,
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(widget.feature.desc,
                      style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textMid, height: 1.6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
