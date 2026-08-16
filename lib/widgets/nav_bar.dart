import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class NavBar extends StatelessWidget {
  final VoidCallback onServicesPressed;
  final VoidCallback onAboutPressed;
  final VoidCallback onAppointmentPressed;
  final VoidCallback onNoticesPressed;
  final VoidCallback onContactPressed;

  const NavBar({
    super.key,
    required this.onServicesPressed,
    required this.onAboutPressed,
    required this.onAppointmentPressed,
    required this.onNoticesPressed,
    required this.onContactPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return SizedBox(
      height: 68,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // ── Left: Nav Links
            if (isWide) ...[
              _NavLink(label: 'Services', onTap: onServicesPressed),
              _NavLink(label: 'About', onTap: onAboutPressed),
              _NavLink(label: 'Appointment', onTap: onAppointmentPressed),
              _NavLink(label: 'Notices', onTap: onNoticesPressed),
              _NavLink(label: 'Contact', onTap: onContactPressed),
            ],
            const Spacer(),

            // ── Right: Sign Up + Book Button + Logo/Profile
            _SignUpButton(),
            const SizedBox(width: 10),
            _BookButton(onTap: onAppointmentPressed),
            const SizedBox(width: 12),
            const _LogoProfileMenu(),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
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
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.tealLight : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _hovered ? AppColors.teal : AppColors.textMid,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignUpButton extends StatefulWidget {
  const _SignUpButton();

  @override
  State<_SignUpButton> createState() => _SignUpButtonState();
}

class _SignUpButtonState extends State<_SignUpButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/signup'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.blueLight : Colors.transparent,
            border: Border.all(
              color: _hovered ? AppColors.blue : AppColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Sign Up',
            style: GoogleFonts.inter(
              color: _hovered ? AppColors.blue : AppColors.textMid,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookButton extends StatefulWidget {
  final VoidCallback onTap;
  const _BookButton({required this.onTap});

  @override
  State<_BookButton> createState() => _BookButtonState();
}

class _BookButtonState extends State<_BookButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.tealDark : AppColors.teal,
            borderRadius: BorderRadius.circular(10),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.teal.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Text(
            'Book Appointment',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo + Profile Dropdown
class _LogoProfileMenu extends StatefulWidget {
  const _LogoProfileMenu();

  @override
  State<_LogoProfileMenu> createState() => _LogoProfileMenuState();
}

class _LogoProfileMenuState extends State<_LogoProfileMenu> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  void _toggle() {
    if (_isOpen) {
      _close();
    } else {
      _open();
    }
  }

  void _open() {
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _close,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(-140, 64),
              child: Material(
                elevation: 16,
                borderRadius: BorderRadius.circular(18),
                shadowColor: AppColors.teal.withOpacity(0.2),
                child: _ProfileDropdown(onClose: _close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isOpen ? AppColors.tealLight : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'web/hospital_logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_hospital, color: Colors.white, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MyHospital',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tealDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Compassionate Care',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.textSoft,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  final VoidCallback onClose;
  const _ProfileDropdown({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'JD',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('John Doe',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark)),
                const Text('john.doe@email.com',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textSoft)),
              ],
            ),
          ),
          // Menu items
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _DropdownItem(icon: Icons.person_outline, label: 'My Profile'),
                _DropdownItem(icon: Icons.calendar_today_outlined, label: 'My Appointments'),
                _DropdownItem(icon: Icons.description_outlined, label: 'Medical Records'),
                _DropdownItem(icon: Icons.medication_outlined, label: 'Prescriptions'),
                _DropdownItem(icon: Icons.settings_outlined, label: 'Settings'),
                const Divider(height: 16, color: AppColors.border),
                _DropdownItem(
                  icon: Icons.logout,
                  label: 'Sign Out',
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;

  const _DropdownItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  @override
  State<_DropdownItem> createState() => _DropdownItemState();
}

class _DropdownItemState extends State<_DropdownItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isDestructive ? AppColors.accent : AppColors.textMid;
    final hoverBg = widget.isDestructive ? AppColors.accentSoft : AppColors.tealLight;
    final hoverColor = widget.isDestructive ? AppColors.accent : AppColors.teal;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? hoverBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(widget.icon,
                  size: 16, color: _hovered ? hoverColor : color.withOpacity(0.65)),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: _hovered ? hoverColor : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
