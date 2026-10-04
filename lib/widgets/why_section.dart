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
      padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 80),
      child: Column(children: [
        _SectionHeader(),
        const SizedBox(height: 56),
        isWide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: _TrustCards()),
                const SizedBox(width: 60),
                Expanded(child: _MarketplaceStats()),
              ])
            : Column(children: [
                _TrustCards(),
                const SizedBox(height: 40),
                _MarketplaceStats(),
              ]),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.blueLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
        ),
        child: Text('WHY MYHOSPITAL',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 1.1)),
      ),
      const SizedBox(height: 14),
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.playfairDisplay(fontSize: 34, fontWeight: FontWeight.w700, color: AppColors.textDark),
          children: const [
            TextSpan(text: 'Why 50,000+ Patients\n'),
            TextSpan(text: 'Choose ', style: TextStyle(color: AppColors.textDark)),
            TextSpan(text: 'MyHospital', style: TextStyle(color: AppColors.blue)),
          ],
        ),
      ),
      const SizedBox(height: 14),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Text(
          'We don\'t own hospitals, labs or pharmacies. We partner with the best — verified, rated, and held accountable — so you always get the finest care.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 15.5, color: AppColors.textMid, height: 1.7),
        ),
      ),
      const SizedBox(height: 14),
      Container(width: 50, height: 3, decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.blue, AppColors.blueMid]),
          borderRadius: BorderRadius.circular(2))),
    ]);
  }
}

class _TrustCards extends StatelessWidget {
  static const _features = [
    _Feature(
      icon: Icons.verified_outlined,
      color: Color(0xFF1565C0),
      bgColor: Color(0xFFE8F4FD),
      title: 'All Partners Verified',
      desc: 'Every lab, pharmacy, doctor and hospital goes through our rigorous 3-step verification before listing.',
    ),
    _Feature(
      icon: Icons.speed_rounded,
      color: Color(0xFF2E7D32),
      bgColor: Color(0xFFEDF7ED),
      title: 'Same-Day Service',
      desc: 'Consult a doctor in minutes, get lab results in hours, and medicines delivered in under 2 hours.',
    ),
    _Feature(
      icon: Icons.lock_outline_rounded,
      color: Color(0xFF6A1B9A),
      bgColor: Color(0xFFF3E8FF),
      title: 'Your Data, Always Private',
      desc: 'DPDPA & HIPAA compliant. Your health records are encrypted end-to-end and never sold or shared.',
    ),
    _Feature(
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFFE65100),
      bgColor: Color(0xFFFFF3E0),
      title: 'Insurance & Cashless',
      desc: 'Accepted by 60+ insurers across all partner hospitals. Cashless claims processed in real time.',
    ),
  ];

  const _TrustCards();

  @override
  Widget build(BuildContext context) {
    return Column(children: _features.map((f) => _FeatureCard(feature: f)).toList());
  }
}

class _Feature {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String desc;
  const _Feature({required this.icon, required this.color, required this.bgColor, required this.title, required this.desc});
}

class _FeatureCard extends StatefulWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});
  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;
  Offset _mousePos = const Offset(200, 100);

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    
    // 3D Tilt calculation
    final double tiltX = (_mousePos.dy - 100) / 100 * 0.04;
    final double tiltY = (_mousePos.dx - 200) / 200 * -0.04;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _mousePos = const Offset(200, 100);
      }),
      onHover: (e) {
        if (mounted && _hovered) {
          setState(() => _mousePos = e.localPosition);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_hovered ? tiltX : 0)
          ..rotateY(_hovered ? tiltY : 0),
        transformAlignment: FractionalOffset.center,
        margin: const EdgeInsets.only(bottom: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovered ? f.bgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hovered ? f.color.withValues(alpha: 0.2) : Colors.transparent),
            // Cinematic dynamic spotlight glow
            gradient: _hovered ? RadialGradient(
              center: Alignment((_mousePos.dx - 200) / 200, (_mousePos.dy - 100) / 100),
              radius: 1.5,
              colors: [
                f.bgColor,
                f.bgColor.withValues(alpha: 0.2),
              ],
            ) : null,
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: 52, height: 52,
              decoration: BoxDecoration(color: f.bgColor, borderRadius: BorderRadius.circular(14)),
              transform: _hovered ? (Matrix4.identity()..scale(1.12)) : Matrix4.identity(),
              child: Icon(f.icon, color: f.color, size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.title, style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 5),
              Text(f.desc, style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textMid, height: 1.6)),
            ])),
          ]),
        ),
      ),
    );
  }
}

class _MarketplaceStats extends StatefulWidget {
  @override
  State<_MarketplaceStats> createState() => _MarketplaceStatsState();
}

class _MarketplaceStatsState extends State<_MarketplaceStats> {
  bool _hovered = false;
  Offset _mousePos = const Offset(200, 200);

  @override
  Widget build(BuildContext context) {
    final double tiltX = (_mousePos.dy - 200) / 200 * 0.03;
    final double tiltY = (_mousePos.dx - 200) / 200 * -0.03;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _mousePos = const Offset(200, 200);
      }),
      onHover: (e) {
        if (mounted && _hovered) {
          setState(() => _mousePos = e.localPosition);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_hovered ? tiltX : 0)
          ..rotateY(_hovered ? tiltY : 0),
        transformAlignment: FractionalOffset.center,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: _hovered 
                ? Alignment((_mousePos.dx - 200) / 200, (_mousePos.dy - 200) / 200)
                : Alignment.topLeft,
              radius: _hovered ? 1.5 : 2.0,
              colors: [
                _hovered ? const Color(0xFF1E3354) : AppColors.navyDark, 
                AppColors.navy
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: _hovered ? 0.45 : 0.35), 
                blurRadius: _hovered ? 48 : 32, 
                offset: Offset(0, _hovered ? 20 : 12)
              )
            ],
            border: Border.all(
              color: _hovered ? AppColors.blue.withValues(alpha: 0.3) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Network at a Glance', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white70)),
            const SizedBox(height: 24),
            _NetworkStat(emoji: '👨‍⚕️', label: 'Verified Doctors', value: '2,000+', sub: 'Across 35+ specialties'),
            const SizedBox(height: 16),
            _NetworkStat(emoji: '🔬', label: 'NABL-accredited Labs', value: '300+', sub: 'Home collection available'),
            const SizedBox(height: 16),
            _NetworkStat(emoji: '💊', label: 'Partner Pharmacies', value: '200+', sub: 'Genuine medicines, fast delivery'),
            const SizedBox(height: 16),
            _NetworkStat(emoji: '🏥', label: 'Partner Hospitals', value: '150+', sub: 'Beds, reviews, insurance info'),
            const SizedBox(height: 24),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withValues(alpha: 0.15), Colors.transparent]),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              _MiniStat(number: '4.8★', label: 'App Rating'),
              const SizedBox(width: 24),
              _MiniStat(number: '10 min', label: 'Avg Response'),
              const SizedBox(width: 24),
              _MiniStat(number: '50K+', label: 'Happy Patients'),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _NetworkStat extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final String sub;
  const _NetworkStat({required this.emoji, required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w500)),
        Row(children: [
          Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2)),
          const SizedBox(width: 8),
          Expanded(child: Text(sub, style: GoogleFonts.inter(fontSize: 11, color: Colors.white38))),
        ]),
      ])),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final String number;
  final String label;
  const _MiniStat({required this.number, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(number, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.blueMid)),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
    ]);
  }
}
