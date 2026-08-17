import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ContactStrip extends StatelessWidget {
  const ContactStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return Container(
      color: Colors.white,
      child: Column(children: [
        Container(height: 1, color: AppColors.border),

        // Footer columns
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 56),
          child: isWide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Brand column
                  SizedBox(width: 260, child: _BrandColumn()),
                  const SizedBox(width: 48),
                  // Link columns
                  Expanded(child: _LinkColumns()),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _BrandColumn(),
                  const SizedBox(height: 40),
                  _LinkColumns(),
                ]),
        ),

        // Bottom bar
        Container(height: 1, color: AppColors.border),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 64 : 24, vertical: 18),
          child: Row(children: [
            Expanded(child: Text(
              '© 2026 MyHospital Technologies Pvt Ltd · CIN: U72200KA2024PTC180XXX',
              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSoft),
            )),
            const SizedBox(width: 24),
            Row(children: [
              _FooterLink(label: 'Privacy Policy'),
              const SizedBox(width: 16),
              _FooterLink(label: 'Terms of Use'),
              const SizedBox(width: 16),
              _FooterLink(label: 'Cookie Policy'),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _BrandColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [AppColors.navy, AppColors.blueMid],
            ),
          ),
          child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MyHospital', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navy)),
          Text('Healthcare Marketplace', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSoft)),
        ]),
      ]),
      const SizedBox(height: 16),
      Text('India\'s most trusted platform connecting patients with verified doctors, labs and pharmacies.',
          style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textMid, height: 1.65)),
      const SizedBox(height: 20),
      // Trust badges
      Wrap(spacing: 8, runSpacing: 8, children: [
        _TrustBadge(label: 'DPDPA Compliant'),
        _TrustBadge(label: 'ISO 27001'),
        _TrustBadge(label: 'NABH Listed'),
      ]),
      const SizedBox(height: 20),
      // Social icons
      Row(children: [
        _SocialIcon(icon: Icons.facebook, label: 'FB'),
        const SizedBox(width: 10),
        _SocialIcon(icon: Icons.camera_alt_outlined, label: 'IG'),
        const SizedBox(width: 10),
        _SocialIcon(icon: Icons.link, label: 'LI'),
        const SizedBox(width: 10),
        _SocialIcon(icon: Icons.play_circle_outline, label: 'YT'),
      ]),
    ]);
  }
}

class _TrustBadge extends StatelessWidget {
  final String label;
  const _TrustBadge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blueLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.blue, fontWeight: FontWeight.w600)),
    );
  }
}

class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final String label;
  const _SocialIcon({required this.icon, required this.label});
  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: _hovered ? AppColors.navy : AppColors.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _hovered ? AppColors.navy : AppColors.border),
        ),
        child: Icon(widget.icon, size: 16, color: _hovered ? Colors.white : AppColors.textSoft),
      ),
    );
  }
}

class _LinkColumns extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return isWide
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _LinkGroup(title: 'For Patients', links: ['Find a Doctor', 'Book Lab Test', 'Order Medicines', 'Find Hospitals', 'Ambulance', 'Health Packages'])),
            Expanded(child: _LinkGroup(title: 'For Partners', links: ['List Your Lab', 'Partner Pharmacy', 'Join as Doctor', 'Hospital Listing', 'Ambulance Network', 'Partner API'])),
            Expanded(child: _LinkGroup(title: 'Company', links: ['About Us', 'Careers', 'Press & Media', 'Blog', 'Contact Us', 'Investor Relations'])),
            Expanded(child: _LinkGroup(title: 'Support', links: ['Help Centre', 'Track Order', 'Refund Policy', 'Report Fraud', 'Accessibility', 'Emergency: 108'])),
          ])
        : Wrap(spacing: 20, runSpacing: 32, children: [
            SizedBox(width: 160, child: _LinkGroup(title: 'For Patients', links: ['Find a Doctor', 'Book Lab Test', 'Order Medicines', 'Find Hospitals'])),
            SizedBox(width: 160, child: _LinkGroup(title: 'For Partners', links: ['List Your Lab', 'Partner Pharmacy', 'Join as Doctor', 'Hospital Listing'])),
            SizedBox(width: 160, child: _LinkGroup(title: 'Company', links: ['About Us', 'Careers', 'Blog', 'Contact Us'])),
            SizedBox(width: 160, child: _LinkGroup(title: 'Support', links: ['Help Centre', 'Track Order', 'Refund Policy', 'Emergency: 108'])),
          ]);
  }
}

class _LinkGroup extends StatelessWidget {
  final String title;
  final List<String> links;
  const _LinkGroup({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark)),
      const SizedBox(height: 14),
      ...links.map((l) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: _FooterLink(label: l, isSmall: false),
      )),
    ]);
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final bool isSmall;
  const _FooterLink({required this.label, this.isSmall = true});
  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Text(widget.label,
            style: GoogleFonts.inter(
              fontSize: widget.isSmall ? 11.5 : 13.5,
              color: _hovered ? AppColors.blue : AppColors.textSoft,
              fontWeight: _hovered ? FontWeight.w500 : FontWeight.w400,
            )),
      ),
    );
  }
}
