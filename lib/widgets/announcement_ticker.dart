import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AnnouncementTicker extends StatefulWidget {
  const AnnouncementTicker({super.key});

  @override
  State<AnnouncementTicker> createState() => _AnnouncementTickerState();
}

class _AnnouncementTickerState extends State<AnnouncementTicker> {
  final ScrollController _ctrl = ScrollController();
  Timer? _timer;
  bool _paused = false;

  static const _notices = [
    '🩺  Free Health Camp – 28 July 2026, Hall A',
    '💉  COVID Vaccination – Available all days, Immunisation Ward',
    '🏥  New ICU Wing inaugurated with 40 beds',
    '📞  24/7 Tele-Consultation – Now available on the Patient App',
    '🩸  Blood Donation Drive – Every Saturday, 10 AM – 4 PM',
    '📋  Online Lab Reports – Download instantly via Patient Portal',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!_paused && _ctrl.hasClients) {
        final max = _ctrl.position.maxScrollExtent;
        final next = _ctrl.offset + 1.2;
        if (next >= max) {
          _ctrl.jumpTo(0);
        } else {
          _ctrl.jumpTo(next);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(horizontal: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              '📢  NOTICES',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6),
            ),
          ),
          // Scrolling ticker
          Expanded(
            child: MouseRegion(
              onEnter: (_) => _paused = true,
              onExit: (_) => _paused = false,
              child: ListView.separated(
                controller: _ctrl,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _notices.length * 6,
                separatorBuilder: (_, __) => const SizedBox(width: 60),
                itemBuilder: (_, i) {
                  final notice = _notices[i % _notices.length];
                  return Center(
                    child: Text(
                      notice,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textMid),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
