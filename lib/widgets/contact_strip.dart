import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ContactStrip extends StatelessWidget {
  const ContactStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900 ? 4 : width > 600 ? 2 : 1;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(height: 1, color: AppColors.border),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width > 900 ? 60 : 24, vertical: 48),
            child: LayoutBuilder(
              builder: (_, constraints) {
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    _ContactItem(
                      emoji: '📍',
                      title: 'Address',
                      lines: ['12, MG Road, Bengaluru – 560001', 'Karnataka, India'],
                      width: (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount,
                    ),
                    _ContactItem(
                      emoji: '📞',
                      title: 'Phone',
                      lines: ['+91 80 4567 8900', 'Emergency: 108'],
                      width: (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount,
                    ),
                    _ContactItem(
                      emoji: '✉️',
                      title: 'Email',
                      lines: ['care@myhospital.in', 'support@myhospital.in'],
                      width: (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount,
                    ),
                    _ContactItem(
                      emoji: '🕐',
                      title: 'Hours',
                      lines: ['OPD: Mon–Sat 8AM–8PM', 'Emergency: 24 × 7 × 365'],
                      width: (constraints.maxWidth - (crossAxisCount - 1) * 24) / crossAxisCount,
                    ),
                  ],
                );
              },
            ),
          ),
          // Bottom bar
          Container(
            height: 1,
            color: AppColors.border,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width > 900 ? 60 : 24, vertical: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    '© 2026 MyHospital. All rights reserved. | NABH Accredited | ISO 9001:2015 Certified',
                    style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSoft),
                  ),
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    _FooterLink(label: 'Privacy Policy'),
                    const SizedBox(width: 16),
                    _FooterLink(label: 'Terms of Use'),
                    const SizedBox(width: 16),
                    _FooterLink(label: 'Sitemap'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final String emoji;
  final String title;
  final List<String> lines;
  final double width;

  const _ContactItem({
    required this.emoji,
    required this.title,
    required this.lines,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(title,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          ...lines.map((l) => Text(l,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMid, height: 1.5))),
        ],
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  const _FooterLink({required this.label});

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
      child: GestureDetector(
        onTap: () {},
        child: Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: _hovered ? AppColors.teal : AppColors.textSoft,
            fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
