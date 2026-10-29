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
    'Full Body Checkup packages starting ₹499 — Book now!',
    'Order medicines before 6 PM for same-day delivery',
    '500+ new verified doctors joined this month',
    'Free home sample collection on lab tests above ₹999',
    'Get 15% off on your first medicine order with code FIRST15',
    '150+ partner hospitals now accepting cashless insurance',
    'MyHospital rated 4.8/5 by 50,000+ patients',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    _timer = Timer.periodic(const Duration(milliseconds: 28), (_) {
      if (!_paused && _ctrl.hasClients) {
        final max = _ctrl.position.maxScrollExtent;
        final next = _ctrl.offset + 1.0;
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
        color: AppColors.navyDark,
        border: Border(
          bottom: BorderSide(color: AppColors.blue.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.blue, AppColors.blueMid],
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  'UPDATES',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _notices.length * 6,
                separatorBuilder: (_, __) => Container(
                  width: 1,
                  height: 16,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 15,
                  ),
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                itemBuilder: (_, i) {
                  final notice = _notices[i % _notices.length];
                  return Center(
                    child: Text(
                      notice,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
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
