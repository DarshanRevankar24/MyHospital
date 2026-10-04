import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _showIntro = true; // Cinematic intro state

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
      body: Stack(
        children: [
          // Main App Content
          Column(
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
                  _ScrollReveal(scrollCtrl: _scrollController, child: ServicesSection(key: _servicesKey)),
                  _ScrollReveal(scrollCtrl: _scrollController, child: WhySection(key: _aboutKey)),
                  _ScrollReveal(scrollCtrl: _scrollController, child: AppointmentSection(key: _appointmentKey)),
                  _ScrollReveal(scrollCtrl: _scrollController, child: InfoSection(key: _noticesKey)),
                  ContactStrip(key: _contactKey),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Cinematic Intro Overlay
      if (_showIntro)
        Positioned.fill(
          child: _CinematicIntro(
            onComplete: () {
              if (mounted) setState(() => _showIntro = false);
            },
          ),
        ),
      ],
    ),
  );
}
}

class _ScrollReveal extends StatefulWidget {
  final Widget child;
  final ScrollController scrollCtrl;

  const _ScrollReveal({required this.child, required this.scrollCtrl});

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    widget.scrollCtrl.addListener(_checkVisibility);
  }

  void _checkVisibility() {
    if (_revealed || !mounted) return;
    
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero).dy;
      final screenHeight = MediaQuery.of(context).size.height;
      
      // Reveal when the widget is within the bottom 15% of the screen
      if (position < screenHeight * 0.85) {
        _revealed = true;
        _animCtrl.forward();
      }
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check initial visibility after layout
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    widget.scrollCtrl.removeListener(_checkVisibility);
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

// ── Cinematic Intro Sequence ──
class _CinematicIntro extends StatefulWidget {
  final VoidCallback onComplete;
  const _CinematicIntro({required this.onComplete});

  @override
  State<_CinematicIntro> createState() => _CinematicIntroState();
}

class _CinematicIntroState extends State<_CinematicIntro> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleIn;
  late Animation<double> _rotate;
  late Animation<double> _textFade;
  late Animation<double> _exitScale;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));

    // Phase 1: Swirl In (0.0 to 0.4)
    _scaleIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack)),
    );
    _rotate = Tween<double>(begin: -2.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)),
    );

    // Phase 2: Text Reveal (0.3 to 0.5)
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.5, curve: Curves.easeIn)),
    );

    // Phase 3: Swirl Out & Reveal App (0.75 to 1.0)
    _exitScale = Tween<double>(begin: 1.0, end: 20.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.75, 1.0, curve: Curves.easeInExpo)),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.8, 1.0, curve: Curves.easeOut)),
    );

    _ctrl.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _exitFade,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.navyDark, Color(0xFF0F172A)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              return Transform.scale(
                scale: _exitScale.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Swirling Logo
                    Transform.scale(
                      scale: _scaleIn.value,
                      child: Transform.rotate(
                        angle: _rotate.value * 3.14159,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.blue, AppColors.teal],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blue.withValues(alpha: 0.5),
                                blurRadius: 40,
                                spreadRadius: 10,
                              )
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.favorite_rounded, color: Colors.white, size: 50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Cinematic Text
                    Opacity(
                      opacity: _textFade.value,
                      child: Column(
                        children: [
                          Text(
                            'MyHospital',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'The Future of Healthcare',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.blueMid,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
