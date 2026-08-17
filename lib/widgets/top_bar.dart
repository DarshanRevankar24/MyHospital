import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyDark,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(children: [
        // Left: marketplace info
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _TopBarItem(icon: Icons.location_on_outlined, text: 'Bengaluru · Mumbai · Delhi · Chennai · Hyderabad'),
              const SizedBox(width: 24),
              _TopBarItem(icon: Icons.verified_outlined, text: '2,000+ Verified Doctors'),
              const SizedBox(width: 24),
              _TopBarItem(icon: Icons.local_shipping_outlined, text: 'Medicines in 2 hours'),
            ]),
          ),
        ),
        const SizedBox(width: 16),
        // Right: partner links + emergency
        _TopBarLink(text: 'For Partners'),
        const SizedBox(width: 16),
        _TopBarLink(text: 'Become a Provider'),
        const SizedBox(width: 12),
        _EmergencyBadge(),
      ]),
    );
  }
}

class _TopBarItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TopBarItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: Colors.white54),
      const SizedBox(width: 5),
      Text(text, style: GoogleFonts.inter(color: Colors.white54, fontSize: 11.5, letterSpacing: 0.2)),
    ]);
  }
}

class _TopBarLink extends StatefulWidget {
  final String text;
  const _TopBarLink({required this.text});
  @override
  State<_TopBarLink> createState() => _TopBarLinkState();
}

class _TopBarLinkState extends State<_TopBarLink> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Text(widget.text,
            style: GoogleFonts.inter(
                color: _hovered ? Colors.white : Colors.white54,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                decoration: _hovered ? TextDecoration.underline : TextDecoration.none)),
      ),
    );
  }
}

class _EmergencyBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('🚨  Emergency: 108',
          style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
    );
  }
}
