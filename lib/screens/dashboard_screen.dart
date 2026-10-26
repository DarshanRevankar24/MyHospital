import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// The main patient dashboard after login — a stunning animated hub
/// showing quick-action cards, health summary, upcoming appointments,
/// medication reminders, and family at a glance.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late AnimationController _breatheCtrl;
  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..forward();
    _breatheCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _breatheCtrl.dispose();
    super.dispose();
  }

  Animation<double> _staggerFade(double start, double end) =>
      CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.easeOut));

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          // Side nav for wide screens
          if (isWide) _SideNav(
            selected: _selectedNav,
            onTap: (i) => setState(() => _selectedNav = i),
            onLogout: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                _DashTopBar(isWide: isWide),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isWide ? 32 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting
                        FadeTransition(
                          opacity: _staggerFade(0.0, 0.3),
                          child: _GreetingBanner(breatheAnim: _breatheCtrl),
                        ),
                        const SizedBox(height: 28),

                        // Quick Actions
                        FadeTransition(
                          opacity: _staggerFade(0.1, 0.4),
                          child: _QuickActions(),
                        ),
                        const SizedBox(height: 28),

                        // Health Overview & Upcoming
                        FadeTransition(
                          opacity: _staggerFade(0.2, 0.5),
                          child: isWide
                              ? Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 3,
                                        child: _HealthOverviewCard()),
                                    const SizedBox(width: 20),
                                    Expanded(
                                        flex: 2,
                                        child:
                                            _UpcomingAppointments()),
                                  ],
                                )
                              : Column(children: [
                                  _HealthOverviewCard(),
                                  const SizedBox(height: 20),
                                  _UpcomingAppointments(),
                                ]),
                        ),
                        const SizedBox(height: 28),

                        // Medications & Family
                        FadeTransition(
                          opacity: _staggerFade(0.3, 0.6),
                          child: isWide
                              ? Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 3,
                                        child:
                                            _MedicationReminders()),
                                    const SizedBox(width: 20),
                                    Expanded(
                                        flex: 2,
                                        child: _FamilyGlance()),
                                  ],
                                )
                              : Column(children: [
                                  _MedicationReminders(),
                                  const SizedBox(height: 20),
                                  _FamilyGlance(),
                                ]),
                        ),
                        const SizedBox(height: 28),

                        // Recent Activity
                        FadeTransition(
                          opacity: _staggerFade(0.4, 0.7),
                          child: _RecentActivity(),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Side Navigation
class _SideNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  final VoidCallback onLogout;

  const _SideNav({
    required this.selected,
    required this.onTap,
    required this.onLogout,
  });

  static const _items = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _NavItem(icon: Icons.local_hospital_rounded, label: 'Hospitals'),
    _NavItem(icon: Icons.science_rounded, label: 'Lab Tests'),
    _NavItem(icon: Icons.medication_rounded, label: 'Medicines'),
    _NavItem(icon: Icons.bloodtype_rounded, label: 'Blood Bank'),
    _NavItem(icon: Icons.emergency_rounded, label: 'Ambulance'),
    _NavItem(icon: Icons.people_rounded, label: 'Family'),
    _NavItem(icon: Icons.medical_information_rounded, label: 'Medications'),
    _NavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(4, 0)),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                        colors: [Color(0xFFB8C8D8), Color(0xFF6A7F94)]),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.blue.withValues(alpha: 0.3),
                          blurRadius: 12)
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: Image.asset('web/hospital_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MyHospital',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text('Patient Portal',
                        style: GoogleFonts.inter(
                            fontSize: 10, color: Colors.white38)),
                  ],
                ),
              ],
            ),
          ),

          Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 8),

          // Nav items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _items.length,
              itemBuilder: (_, i) => _SideNavItem(
                item: _items[i],
                isSelected: i == selected,
                onTap: () {
                  onTap(i);
                  // Navigate based on index
                  final routes = [
                    '/dashboard',
                    '/hospitals',
                    '/lab-tests',
                    '/pharmacy',
                    '/blood-bank',
                    '/ambulance',
                    '/family',
                    '/medications',
                    '/profile',
                  ];
                  if (i > 0) {
                    Navigator.of(context).pushNamed(routes[i]);
                  }
                },
              ),
            ),
          ),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: _SideNavItem(
              item: const _NavItem(icon: Icons.logout, label: 'Sign Out'),
              isSelected: false,
              isDestructive: true,
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _SideNavItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.item,
    required this.isSelected,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  State<_SideNavItem> createState() => _SideNavItemState();
}

class _SideNavItemState extends State<_SideNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isSelected && !widget.isDestructive;
    final color = widget.isDestructive
        ? AppColors.accent
        : isActive
            ? Colors.white
            : Colors.white54;
    final bgColor = isActive
        ? AppColors.blue.withValues(alpha: 0.2)
        : _hovered
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: AppColors.blue.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 18, color: color),
              const SizedBox(width: 12),
              Text(widget.item.label,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                      color: color)),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: AppColors.blueMid, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dashboard Top Bar
class _DashTopBar extends StatelessWidget {
  final bool isWide;
  const _DashTopBar({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isWide ? 32 : 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          if (!isWide)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.menu_rounded,
                  color: AppColors.textMid, size: 24),
            ),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                style: GoogleFonts.inter(
                    fontSize: 13.5, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Search appointments, medicines, doctors…',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 13.5, color: AppColors.textSoft),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 20, color: AppColors.textSoft),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _TopBarIcon(icon: Icons.notifications_outlined, badge: '3'),
          const SizedBox(width: 8),
          _TopBarIcon(icon: Icons.chat_bubble_outline),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [AppColors.blue, AppColors.blueMid]),
            ),
            child: Center(
              child: Text('JD',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarIcon extends StatefulWidget {
  final IconData icon;
  final String? badge;
  const _TopBarIcon({required this.icon, this.badge});

  @override
  State<_TopBarIcon> createState() => _TopBarIconState();
}

class _TopBarIconState extends State<_TopBarIcon> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _hovered ? AppColors.blueLight : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon,
                size: 20,
                color:
                    _hovered ? AppColors.blue : AppColors.textSoft),
          ),
          if (widget.badge != null)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle),
                child: Center(
                  child: Text(widget.badge!,
                      style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Greeting Banner
class _GreetingBanner extends StatelessWidget {
  final AnimationController breatheAnim;
  const _GreetingBanner({required this.breatheAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navy, Color(0xFF1A2C4A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative orbs
          Positioned(
            top: -40,
            right: -20,
            child: AnimatedBuilder(
              animation: breatheAnim,
              builder: (_, __) => Opacity(
                opacity: 0.06 + breatheAnim.value * 0.04,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.blueMid),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color:
                                AppColors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PulsingDot(),
                          const SizedBox(width: 6),
                          Text('Good evening',
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                  letterSpacing: 0.3)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Welcome back, John!',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(
                        'You have 2 upcoming appointments and 3 medication reminders today.',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white54,
                            height: 1.6)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _BannerStat(number: '12', label: 'Visits'),
                        _BannerDivider(),
                        _BannerStat(number: '5', label: 'Active Meds'),
                        _BannerDivider(),
                        _BannerStat(number: '3', label: 'Family'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String number, label;
  const _BannerStat({required this.number, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(number,
            style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.blueMid)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11, color: Colors.white38)),
      ],
    );
  }
}

class _BannerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white.withValues(alpha: 0.1),
    );
  }
}

// ── Quick Actions Grid
class _QuickActions extends StatelessWidget {
  static const _actions = [
    _ActionData(
        emoji: '🚑',
        label: 'Emergency\nAmbulance',
        color: Color(0xFFFFEBEE),
        route: '/ambulance'),
    _ActionData(
        emoji: '🩺',
        label: 'Consult a\nDoctor',
        color: Color(0xFFE8F4FD),
        route: '/hospitals'),
    _ActionData(
        emoji: '🔬',
        label: 'Book\nLab Test',
        color: Color(0xFFEDF7ED),
        route: '/lab-tests'),
    _ActionData(
        emoji: '💊',
        label: 'Order\nMedicine',
        color: Color(0xFFFFF3E0),
        route: '/pharmacy'),
    _ActionData(
        emoji: '🏥',
        label: 'Find\nHospital',
        color: Color(0xFFF3E8FF),
        route: '/hospitals'),
    _ActionData(
        emoji: '🩸',
        label: 'Blood\nBank',
        color: Color(0xFFFFEBEE),
        route: '/blood-bank'),
  ];

  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (_, constraints) {
            final cols = constraints.maxWidth > 700 ? 6 : 3;
            return Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _actions
                  .map((a) => SizedBox(
                        width: (constraints.maxWidth -
                                (cols - 1) * 14) /
                            cols,
                        child: _QuickActionCard(action: a),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ActionData {
  final String emoji, label, route;
  final Color color;
  const _ActionData(
      {required this.emoji,
      required this.label,
      required this.color,
      required this.route});
}

class _QuickActionCard extends StatefulWidget {
  final _ActionData action;
  const _QuickActionCard({required this.action});
  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(widget.action.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: _hovered
                    ? AppColors.blue.withValues(alpha: 0.3)
                    : AppColors.border),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                transform: _hovered
                    ? (Matrix4.identity()..scale(1.1))
                    : Matrix4.identity(),
                decoration: BoxDecoration(
                  color: widget.action.color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                    child: Text(widget.action.emoji,
                        style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(height: 10),
              Text(widget.action.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Health Overview Card
class _HealthOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Health Overview',
      icon: Icons.health_and_safety_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _VitalChip(
                      label: 'Blood Pressure',
                      value: '120/80',
                      unit: 'mmHg',
                      icon: Icons.favorite,
                      color: const Color(0xFF4ADE80))),
              const SizedBox(width: 12),
              Expanded(
                  child: _VitalChip(
                      label: 'Heart Rate',
                      value: '72',
                      unit: 'bpm',
                      icon: Icons.monitor_heart,
                      color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _VitalChip(
                      label: 'Blood Sugar',
                      value: '95',
                      unit: 'mg/dL',
                      icon: Icons.bloodtype,
                      color: const Color(0xFFFBBF24))),
              const SizedBox(width: 12),
              Expanded(
                  child: _VitalChip(
                      label: 'SpO2',
                      value: '98',
                      unit: '%',
                      icon: Icons.air,
                      color: AppColors.blueMid)),
            ],
          ),
        ],
      ),
    );
  }
}

class _VitalChip extends StatefulWidget {
  final String label, value, unit;
  final IconData icon;
  final Color color;
  const _VitalChip(
      {required this.label,
      required this.value,
      required this.unit,
      required this.icon,
      required this.color});

  @override
  State<_VitalChip> createState() => _VitalChipState();
}

class _VitalChipState extends State<_VitalChip> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.color.withValues(alpha: 0.08)
              : AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.3)
                  : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, size: 18, color: widget.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSoft,
                          fontWeight: FontWeight.w500)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(widget.value,
                          style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              height: 1)),
                      const SizedBox(width: 3),
                      Text(widget.unit,
                          style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textSoft)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Upcoming Appointments
class _UpcomingAppointments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Upcoming',
      icon: Icons.calendar_today_outlined,
      child: Column(
        children: [
          _AppointmentTile(
            doctor: 'Dr. Priya Sharma',
            specialty: 'Cardiologist',
            time: 'Today, 4:30 PM',
            type: 'Video',
            color: AppColors.blue,
          ),
          const SizedBox(height: 10),
          _AppointmentTile(
            doctor: 'Dr. Raj Patel',
            specialty: 'General Physician',
            time: 'Tomorrow, 10:00 AM',
            type: 'In-Clinic',
            color: const Color(0xFF4ADE80),
          ),
          const SizedBox(height: 14),
          _SeeAllLink(label: 'View all appointments'),
        ],
      ),
    );
  }
}

class _AppointmentTile extends StatefulWidget {
  final String doctor, specialty, time, type;
  final Color color;
  const _AppointmentTile(
      {required this.doctor,
      required this.specialty,
      required this.time,
      required this.type,
      required this.color});

  @override
  State<_AppointmentTile> createState() => _AppointmentTileState();
}

class _AppointmentTileState extends State<_AppointmentTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              _hovered ? widget.color.withValues(alpha: 0.05) : AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.2)
                  : AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [widget.color, widget.color.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(widget.doctor.split(' ').map((w) => w[0]).take(2).join(),
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.doctor,
                      style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  Text(widget.specialty,
                      style: GoogleFonts.inter(
                          fontSize: 11.5, color: AppColors.textSoft)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(widget.time,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMid)),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.type,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: widget.color)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Medication Reminders
class _MedicationReminders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Medication Reminders',
      icon: Icons.medication_outlined,
      child: Column(
        children: [
          _MedTile(
              name: 'Metformin 500mg',
              time: '8:00 AM · Before breakfast',
              emoji: '💊',
              status: 'taken',
              color: const Color(0xFF4ADE80)),
          const SizedBox(height: 8),
          _MedTile(
              name: 'Atorvastatin 20mg',
              time: '9:00 PM · After dinner',
              emoji: '💊',
              status: 'due',
              color: const Color(0xFFFBBF24)),
          const SizedBox(height: 8),
          _MedTile(
              name: 'Amlodipine 5mg',
              time: '8:00 AM · With water',
              emoji: '💊',
              status: 'taken',
              color: const Color(0xFF4ADE80)),
          const SizedBox(height: 14),
          _SeeAllLink(label: 'Manage medications'),
        ],
      ),
    );
  }
}

class _MedTile extends StatefulWidget {
  final String name, time, emoji, status;
  final Color color;
  const _MedTile(
      {required this.name,
      required this.time,
      required this.emoji,
      required this.status,
      required this.color});
  @override
  State<_MedTile> createState() => _MedTileState();
}

class _MedTileState extends State<_MedTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(widget.emoji,
                      style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  Text(widget.time,
                      style: GoogleFonts.inter(
                          fontSize: 11.5, color: AppColors.textSoft)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: widget.status == 'taken'
                    ? const Color(0xFFEDF7ED)
                    : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                  widget.status == 'taken' ? '✓ Taken' : '⏰ Due',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.color)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Family Glance
class _FamilyGlance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Family',
      icon: Icons.people_outline,
      child: Column(
        children: [
          _FamilyMember(
              name: 'Sarah Doe',
              relation: 'Spouse',
              avatar: 'SD',
              color: const Color(0xFF9333EA)),
          const SizedBox(height: 8),
          _FamilyMember(
              name: 'Tommy Doe',
              relation: 'Child',
              avatar: 'TD',
              color: const Color(0xFF3B82F6)),
          const SizedBox(height: 8),
          _FamilyMember(
              name: 'Mary Doe',
              relation: 'Parent',
              avatar: 'MD',
              color: const Color(0xFFF59E0B)),
          const SizedBox(height: 14),
          _SeeAllLink(label: 'Manage family'),
        ],
      ),
    );
  }
}

class _FamilyMember extends StatefulWidget {
  final String name, relation, avatar;
  final Color color;
  const _FamilyMember(
      {required this.name,
      required this.relation,
      required this.avatar,
      required this.color});
  @override
  State<_FamilyMember> createState() => _FamilyMemberState();
}

class _FamilyMemberState extends State<_FamilyMember> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  widget.color,
                  widget.color.withValues(alpha: 0.7)
                ]),
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text(widget.avatar,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.name,
                      style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  Text(widget.relation,
                      style: GoogleFonts.inter(
                          fontSize: 11.5, color: AppColors.textSoft)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.textSoft),
          ],
        ),
      ),
    );
  }
}

// ── Recent Activity
class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Recent Activity',
      icon: Icons.history_rounded,
      child: Column(
        children: [
          _ActivityItem(
              icon: Icons.science_outlined,
              text: 'Lab Report: Complete Blood Count',
              time: '2 hours ago',
              color: const Color(0xFF2E7D32)),
          _ActivityItem(
              icon: Icons.medication_outlined,
              text: 'Medicine ordered: Metformin 500mg',
              time: 'Yesterday',
              color: const Color(0xFFE65100)),
          _ActivityItem(
              icon: Icons.video_call_outlined,
              text: 'Video consultation with Dr. Priya Sharma',
              time: '3 days ago',
              color: AppColors.blue),
          _ActivityItem(
              icon: Icons.bloodtype_outlined,
              text: 'Blood request: O+ fulfilled',
              time: '5 days ago',
              color: AppColors.accent),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String text, time;
  final Color color;
  const _ActivityItem(
      {required this.icon,
      required this.text,
      required this.time,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textMid)),
          ),
          Text(time,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSoft)),
        ],
      ),
    );
  }
}

// ── Reusable Card Container
class _DashCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _DashCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.blue),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _SeeAllLink extends StatefulWidget {
  final String label;
  const _SeeAllLink({required this.label});
  @override
  State<_SeeAllLink> createState() => _SeeAllLinkState();
}

class _SeeAllLinkState extends State<_SeeAllLink> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue)),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: _hovered ? 8 : 4),
              child: const Icon(Icons.arrow_forward_rounded,
                  size: 14, color: AppColors.blue),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.2).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                color: AppColors.blueMid, shape: BoxShape.circle)),
      );
}
