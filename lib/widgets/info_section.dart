import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class _InfoCard {
  final String emoji;
  final String title;
  final List<String> lines;
  final Color iconBg;
  final String linkText;

  const _InfoCard({
    required this.emoji,
    required this.title,
    required this.lines,
    required this.iconBg,
    required this.linkText,
  });
}

const _cards = [
  _InfoCard(
    emoji: '📋',
    title: 'OPD Timings',
    lines: [
      'Morning: 8:00 AM – 1:00 PM',
      'Evening: 4:00 PM – 8:00 PM',
      'Saturday: 8:00 AM – 2:00 PM',
      'Sunday: Closed (Emergency Only)',
    ],
    iconBg: AppColors.tealLight,
    linkText: 'Full Schedule',
  ),
  _InfoCard(
    emoji: '📞',
    title: 'Important Contacts',
    lines: [
      'Emergency: 108',
      'Reception: +91 80 4567 8900',
      'Billing: +91 80 4567 8910',
      'Lab Reports: +91 80 4567 8920',
    ],
    iconBg: AppColors.icBlue,
    linkText: 'All Contacts',
  ),
  _InfoCard(
    emoji: '🚨',
    title: 'Emergency Protocols',
    lines: [
      'Emergency dept. operates 24/7.',
      'Triage team at entry.',
      'Carry govt. ID & past records.',
      'Call 108 for ambulance.',
    ],
    iconBg: AppColors.icRed,
    linkText: 'Learn More',
  ),
  _InfoCard(
    emoji: '🏛️',
    title: 'Insurance & Billing',
    lines: [
      'Cashless for 50+ insurers.',
      'Ayushman Bharat, CGHS, ESI accepted.',
      'Billing: Daily 7 AM – 9 PM.',
      'All major TPAs accepted.',
    ],
    iconBg: AppColors.icPurple,
    linkText: 'Check Coverage',
  ),
];

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1100 ? 4 : width > 700 ? 2 : 1;

    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.symmetric(horizontal: width > 900 ? 60 : 24, vertical: 72),
      child: Column(
        children: [
          _InfoHeader(),
          const SizedBox(height: 44),
          LayoutBuilder(
            builder: (_, constraints) {
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: _cards
                    .map((c) => SizedBox(
                          width: (constraints.maxWidth - (crossAxisCount - 1) * 20) / crossAxisCount,
                          child: _InfoCardWidget(card: c),
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

class _InfoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('INFORMATION',
            style: GoogleFonts.inter(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.teal, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        Text('Patient Resources & Notices',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
                fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 14),
        Container(width: 50, height: 3, decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }
}

class _InfoCardWidget extends StatefulWidget {
  final _InfoCard card;
  const _InfoCardWidget({required this.card});

  @override
  State<_InfoCardWidget> createState() => _InfoCardWidgetState();
}

class _InfoCardWidgetState extends State<_InfoCardWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.card;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? AppColors.teal.withOpacity(0.3) : AppColors.border),
          boxShadow: _hovered
              ? [BoxShadow(color: AppColors.teal.withOpacity(0.1), blurRadius: 24, offset: const Offset(0, 8))]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text(c.emoji, style: const TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(c.title,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...c.lines.map((line) => Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text(line,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMid, height: 1.5)),
                      )),
                  const SizedBox(height: 12),
                  _InfoLink(label: c.linkText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLink extends StatefulWidget {
  final String label;
  const _InfoLink({required this.label});

  @override
  State<_InfoLink> createState() => _InfoLinkState();
}

class _InfoLinkState extends State<_InfoLink> {
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
                style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.teal)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: _hovered ? 8 : 4),
              child: const Icon(Icons.chevron_right, color: AppColors.teal, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
