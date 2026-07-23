import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/top_bar.dart';
import '../widgets/nav_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/services_section.dart';
import '../widgets/announcement_ticker.dart';
import '../widgets/why_section.dart';
import '../widgets/appointment_section.dart';
import '../widgets/info_section.dart';
import '../widgets/contact_strip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Keys for scroll-to navigation
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _appointmentKey = GlobalKey();
  final GlobalKey _noticesKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final scrolled = _scrollController.offset > 10;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Top Info Bar
          const TopBar(),

          // ── Sticky Navbar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              boxShadow: _isScrolled
                  ? [
                      BoxShadow(
                        color: AppColors.teal.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: NavBar(
              onServicesPressed: () => _scrollToKey(_servicesKey),
              onAboutPressed: () => _scrollToKey(_aboutKey),
              onAppointmentPressed: () => _scrollToKey(_appointmentKey),
              onNoticesPressed: () => _scrollToKey(_noticesKey),
              onContactPressed: () => _scrollToKey(_contactKey),
            ),
          ),

          // ── Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  HeroSection(
                    onBookAppointment: () => _scrollToKey(_appointmentKey),
                    onExploreServices: () => _scrollToKey(_servicesKey),
                  ),
                  const AnnouncementTicker(),
                  ServicesSection(key: _servicesKey),
                  WhySection(key: _aboutKey),
                  AppointmentSection(key: _appointmentKey),
                  InfoSection(key: _noticesKey),
                  ContactStrip(key: _contactKey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
