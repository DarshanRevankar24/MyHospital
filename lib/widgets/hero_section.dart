import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';

class HeroSection extends StatefulWidget {
  final VoidCallback onBookAppointment;
  final VoidCallback onExploreServices;

  const HeroSection({
    super.key,
    required this.onBookAppointment,
    required this.onExploreServices,
  });

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  int _activeCategory = 0;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  // 3D Parallax Mouse Tracking
  Offset _mousePos = Offset.zero;
  final double _maxTilt = 0.03; // Max rotation in radians

  static const _categories = [
    _Cat(emoji: '🩺', label: 'Consult Doctor'),
    _Cat(emoji: '🔬', label: 'Lab Tests'),
    _Cat(emoji: '💊', label: 'Medicines'),
    _Cat(emoji: '🏥', label: 'Hospitals'),
    _Cat(emoji: '🚑', label: 'Ambulance'),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isWide = width > 900;

    // Calculate cinematic 3D tilts
    final double tiltX = (_mousePos.dy - (height / 2)) / (height / 2) * _maxTilt;
    final double tiltY = (_mousePos.dx - (width / 2)) / (width / 2) * -_maxTilt;

    return MouseRegion(
      onHover: (e) {
        if (mounted) {
          setState(() {
            _mousePos = e.position;
          });
        }
      },
      onExit: (e) {
        if (mounted) {
          setState(() {
            _mousePos = Offset(width / 2, height / 2);
          });
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navyDark, AppColors.navy, Color(0xFF1A2C4A)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(children: [
          // Ambient cinematic orbs with parallax
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuad,
            top: -60 + (_mousePos.dy * 0.03), 
            right: -60 + (_mousePos.dx * 0.03),
            child: _Orb(size: 450, color: AppColors.blue.withValues(alpha: 0.15)),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuad,
            bottom: -80 - (_mousePos.dy * 0.02), 
            left: 80 - (_mousePos.dx * 0.02),
            child: _Orb(size: 320, color: AppColors.blueMid.withValues(alpha: 0.1)),
          ),
          // Main content with 3D Tilt
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: isWide ? 64 : 24, vertical: isWide ? 72 : 48),
            child: FadeIn(
              duration: const Duration(milliseconds: 1400),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateX(tiltX)
                  ..rotateY(tiltY),
                transformAlignment: FractionalOffset.center,
                child: isWide
                    ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 6, child: SlideInLeft(
                          duration: const Duration(milliseconds: 1000),
                          child: _HeroContent(
                            searchCtrl: _searchCtrl,
                            activeCategory: _activeCategory,
                            categories: _categories,
                            onCategoryTap: (i) => setState(() => _activeCategory = i),
                            onConsultNow: widget.onBookAppointment,
                            onExplore: widget.onExploreServices,
                          ),
                        )),
                        const SizedBox(width: 48),
                        Expanded(flex: 4, child: SlideInRight(
                          duration: const Duration(milliseconds: 1200),
                          child: _QuickBookCard(),
                        )),
                      ])
                    : Column(children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: _HeroContent(
                            searchCtrl: _searchCtrl,
                            activeCategory: _activeCategory,
                            categories: _categories,
                            onCategoryTap: (i) => setState(() => _activeCategory = i),
                            onConsultNow: widget.onBookAppointment,
                            onExplore: widget.onExploreServices,
                          ),
                        ),
                        const SizedBox(height: 36),
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 1000),
                          child: _QuickBookCard(),
                        ),
                      ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Cat {
  final String emoji;
  final String label;
  const _Cat({required this.emoji, required this.label});
}

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle, color: color,
      boxShadow: [BoxShadow(color: color, blurRadius: size * 0.6, spreadRadius: size * 0.1)],
    ),
  );
}

class _HeroContent extends StatelessWidget {
  final TextEditingController searchCtrl;
  final int activeCategory;
  final List<_Cat> categories;
  final ValueChanged<int> onCategoryTap;
  final VoidCallback onConsultNow;
  final VoidCallback onExplore;

  const _HeroContent({
    required this.searchCtrl,
    required this.activeCategory,
    required this.categories,
    required this.onCategoryTap,
    required this.onConsultNow,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Eyebrow badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.18),
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _PulsingDot(),
          const SizedBox(width: 8),
          Text('India\'s Medical Marketplace · 2,000+ Partners',
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: Colors.white70, letterSpacing: 0.5)),
        ]),
      ),
      const SizedBox(height: 22),

      // Main headline
      FadeInUp(
        duration: const Duration(milliseconds: 1000),
        child: RichText(text: TextSpan(
          style: GoogleFonts.playfairDisplay(
              fontSize: 46, fontWeight: FontWeight.w700, color: Colors.white, height: 1.15),
          children: const [
            TextSpan(text: 'Healthcare\n'),
            TextSpan(text: 'at Your '),
            TextSpan(text: 'Fingertips', style: TextStyle(color: AppColors.blueMid)),
          ],
        )),
      ),
      const SizedBox(height: 16),

      FadeInUp(
        delay: const Duration(milliseconds: 200),
        duration: const Duration(milliseconds: 1000),
        child: Text(
          'Book lab tests, consult doctors & order medicines.\nDelivered to your door — anywhere, anytime.',
          style: GoogleFonts.inter(fontSize: 16, color: Colors.white60, height: 1.7),
        ),
      ),
      const SizedBox(height: 32),

      // Search bar
      _SearchBar(controller: searchCtrl),
      const SizedBox(height: 18),

      // Category pills
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: List.generate(categories.length, (i) {
          final cat = categories[i];
          final active = i == activeCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onCategoryTap(i),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: active ? AppColors.blue : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: active ? AppColors.blue : Colors.white.withValues(alpha: 0.15)),
                    boxShadow: active ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.35),
                        blurRadius: 12, offset: const Offset(0, 4))] : [],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(cat.label,
                        style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: active ? Colors.white : Colors.white70)),
                  ]),
                ),
              ),
            ),
          );
        })),
      ),
      const SizedBox(height: 36),

      // CTA Buttons
      Row(children: [
        _PrimaryBtn(label: 'Consult Now', icon: Icons.video_call_outlined, onTap: onConsultNow),
        const SizedBox(width: 14),
        _OutlineBtn(label: 'Explore All', icon: Icons.arrow_forward, onTap: onExplore),
      ]),
      const SizedBox(height: 36),

      // Stats row
      _StatsRow(),
    ]);
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.2).animate(_ctrl);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _opacity,
    child: Container(width: 7, height: 7,
        decoration: const BoxDecoration(color: AppColors.blueMid, shape: BoxShape.circle)),
  );
}

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: _focused
                ? AppColors.blue.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.15),
            blurRadius: _focused ? 24 : 12,
            offset: const Offset(0, 6),
          )],
        ),
        child: TextField(
          controller: widget.controller,
          style: GoogleFonts.inter(fontSize: 14.5, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: 'Search doctors, labs, medicines, hospitals…',
            hintStyle: GoogleFonts.inter(fontSize: 14.5, color: AppColors.textSoft),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.blue, size: 22),
            suffixIcon: Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            filled: true, fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: IntrinsicHeight(
        child: Row(children: [
          Expanded(child: _StatChip(number: '2,000+', label: 'Doctors')),
          VerticalDivider(width: 1, color: Colors.white.withValues(alpha: 0.15)),
          Expanded(child: _StatChip(number: '300+', label: 'NABL Labs')),
          VerticalDivider(width: 1, color: Colors.white.withValues(alpha: 0.15)),
          Expanded(child: _StatChip(number: '200+', label: 'Pharmacies')),
          VerticalDivider(width: 1, color: Colors.white.withValues(alpha: 0.15)),
          Expanded(child: _StatChip(number: '10 min', label: 'Avg Response')),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String number;
  final String label;
  const _StatChip({required this.number, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(number, style: GoogleFonts.inter(
            fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
        const SizedBox(height: 3),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _PrimaryBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.icon, required this.onTap});
  @override
  State<_PrimaryBtn> createState() => _PrimaryBtnState();
}

class _PrimaryBtnState extends State<_PrimaryBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [AppColors.blueDark, AppColors.navy]
                  : [AppColors.blue, AppColors.blueMid],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(
              color: AppColors.blue.withValues(alpha: _hovered ? 0.45 : 0.25),
              blurRadius: _hovered ? 20 : 12, offset: const Offset(0, 6),
            )],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, size: 17, color: Colors.white),
            const SizedBox(width: 9),
            Text(widget.label, style: GoogleFonts.inter(
                fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white)),
          ]),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.icon, required this.onTap});
  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
            border: Border.all(color: Colors.white.withValues(alpha: _hovered ? 0.5 : 0.3), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.label, style: GoogleFonts.inter(
                fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(width: 8),
            Icon(widget.icon, size: 16, color: Colors.white),
          ]),
        ),
      ),
    );
  }
}

// ── Quick Book Card (right panel)
class _QuickBookCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const items = [
      _QuickItem(emoji: '🩺', label: 'Consult\nDoctor', color: Color(0xFFE8F4FD)),
      _QuickItem(emoji: '🔬', label: 'Book\nLab Test', color: Color(0xFFEDF7ED)),
      _QuickItem(emoji: '💊', label: 'Order\nMedicine', color: Color(0xFFFFF3E0)),
      _QuickItem(emoji: '🏥', label: 'Find\nHospital', color: Color(0xFFF3E8FF)),
      _QuickItem(emoji: '🚑', label: 'Emergency\nAmb.', color: Color(0xFFFFEBEE)),
      _QuickItem(emoji: '🩻', label: 'Health\nPackages', color: Color(0xFFE8F4FD)),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: const Color(0xFF4ADE80), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF4ADE80).withValues(alpha: 0.5), blurRadius: 8)]),
          ),
          const SizedBox(width: 8),
          Text('Available Now', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white60, fontWeight: FontWeight.w500)),
          const Spacer(),
          // High quality lottie graphic for medical pulse
          SizedBox(
            width: 40,
            height: 40,
            child: Lottie.network(
              'https://lottie.host/80cf3f1e-f3a7-47b7-bd6b-5dd31bb438e1/1xI2xPZ6jM.json', 
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
            ),
          ),
        ]),
        const SizedBox(height: 4),
        Text('Quick Access', style: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text('What do you need today?', style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white38)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.88,
          children: items.map((item) => _QuickCard(item: item)).toList(),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.blue.withValues(alpha: 0.4)),
          ),
          child: Center(child: Text('📍  Detect My Location',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70))),
        ),
      ]),
    );
  }
}

class _QuickItem {
  final String emoji;
  final String label;
  final Color color;
  const _QuickItem({required this.emoji, required this.label, required this.color});
}

class _QuickCard extends StatefulWidget {
  final _QuickItem item;
  const _QuickCard({required this.item});
  @override
  State<_QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<_QuickCard> {
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
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hovered ? Colors.transparent : Colors.white.withValues(alpha: 0.1)),
            boxShadow: _hovered
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))]
                : [],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: widget.item.color, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(widget.item.emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(height: 8),
            Text(widget.item.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: _hovered ? AppColors.textDark : Colors.white70, height: 1.3)),
          ]),
        ),
      ),
    );
  }
}
