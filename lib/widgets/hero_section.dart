import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onBookAppointment;
  final VoidCallback onExploreServices;

  const HeroSection({
    super.key,
    required this.onBookAppointment,
    required this.onExploreServices,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.tealLight, Colors.white],
          stops: [0.0, 0.65],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 60 : 24,
        vertical: 60,
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _HeroLeft(onBookAppointment: onBookAppointment, onExploreServices: onExploreServices)),
                const SizedBox(width: 48),
                SizedBox(width: 380, child: _QuickAccessCard()),
              ],
            )
          : Column(
              children: [
                _HeroLeft(onBookAppointment: onBookAppointment, onExploreServices: onExploreServices),
                const SizedBox(height: 36),
                _QuickAccessCard(),
              ],
            ),
    );
  }
}

class _HeroLeft extends StatelessWidget {
  final VoidCallback onBookAppointment;
  final VoidCallback onExploreServices;

  const _HeroLeft({required this.onBookAppointment, required this.onExploreServices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.tealLight,
            border: Border.all(color: AppColors.teal.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingDot(),
              const SizedBox(width: 8),
              Text(
                'NABH ACCREDITED HOSPITAL',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Title
        RichText(
          text: TextSpan(
            style: GoogleFonts.playfairDisplay(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              height: 1.15,
            ),
            children: const [
              TextSpan(text: 'Your Health is\nOur '),
              TextSpan(
                text: 'Top Priority',
                style: TextStyle(color: AppColors.teal),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Description
        Text(
          'Delivering compassionate, patient-centred care with state-of-the-art medical technology. Trusted by 50,000+ patients across Karnataka.',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textMid,
            height: 1.75,
          ),
        ),
        const SizedBox(height: 30),

        // CTA Buttons
        Row(
          children: [
            _PrimaryButton(label: 'Book Appointment', icon: Icons.calendar_today, onTap: onBookAppointment),
            const SizedBox(width: 14),
            _OutlineButton(label: 'Explore Services', icon: Icons.arrow_forward, onTap: onExploreServices),
          ],
        ),
        const SizedBox(height: 36),

        // Stats
        _HeroStats(),
      ],
    );
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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(color: AppColors.tealMid, shape: BoxShape.circle),
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.icon, required this.onTap});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.tealDark : AppColors.teal,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.teal.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: GoogleFonts.inter(
                      fontSize: 14.5, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.icon, required this.onTap});

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.tealLight : Colors.transparent,
            border: Border.all(color: AppColors.teal, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label,
                  style: GoogleFonts.inter(
                      fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.teal)),
              const SizedBox(width: 8),
              Icon(widget.icon, size: 16, color: AppColors.teal),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _StatItem(number: '50K+', label: 'Happy Patients')),
            VerticalDivider(width: 1, color: AppColors.border),
            Expanded(child: _StatItem(number: '120+', label: 'Specialists')),
            VerticalDivider(width: 1, color: AppColors.border),
            Expanded(child: _StatItem(number: '24/7', label: 'Emergency Care')),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;
  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(number,
              style: GoogleFonts.inter(
                  fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.teal, height: 1)),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSoft, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Quick Access Card
class _QuickAccessCard extends StatelessWidget {
  final List<_QuickItem> _items = const [
    _QuickItem(emoji: '🚑', label: 'Ambulance', bgColor: AppColors.icRed),
    _QuickItem(emoji: '🩸', label: 'Blood Bank', bgColor: AppColors.icRed),
    _QuickItem(emoji: '🔬', label: 'Laboratory', bgColor: AppColors.icBlue),
    _QuickItem(emoji: '👨‍⚕️', label: 'Consultancy', bgColor: AppColors.tealLight),
    _QuickItem(emoji: '💊', label: 'Pharmacy', bgColor: AppColors.icGreen),
    _QuickItem(emoji: '🩻', label: 'Scanning', bgColor: AppColors.icPurple),
  ];

  const _QuickAccessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withOpacity(0.12),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Access',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text('Tap a service to get started',
              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSoft)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: _items.map((item) => _QuickCard(item: item)).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickItem {
  final String emoji;
  final String label;
  final Color bgColor;
  const _QuickItem({required this.emoji, required this.label, required this.bgColor});
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
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.tealLight : AppColors.bg,
            border: Border.all(
              color: _hovered ? AppColors.teal : AppColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _hovered
                ? [BoxShadow(color: AppColors.teal.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.item.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(widget.item.emoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
