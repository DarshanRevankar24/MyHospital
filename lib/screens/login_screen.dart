import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/demo_auth_service.dart';
import '../theme/app_colors.dart';

/// Beautiful animated Login screen with glassmorphism, floating particles,
/// a pulsing heartbeat line, and staggered field reveals.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;
  bool _isBiometricLoading = false;

  late AnimationController _bgCtrl;
  late AnimationController _formCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    _formCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _formFade = CurvedAnimation(
        parent: _formCtrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut));
    _formSlide =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _formCtrl,
                curve: const Interval(0.2, 1.0, curve: Curves.easeOut)));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _formCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _formCtrl.dispose();
    _pulseCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await DemoAuthService.instance.signIn(
        _usernameCtrl.text,
        _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithBiometrics() async {
    setState(() => _isBiometricLoading = true);
    try {
      final result = await AuthService().authenticate(
        localizedReason: 'Use your phone lock, Face ID, or fingerprint to unlock MyHospital',
      );

      if (!mounted) return;

      switch (result) {
        case AuthResult.success:
          Navigator.of(context).pushReplacementNamed('/dashboard');
          break;
        case AuthResult.unavailable:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No fingerprint or Face ID is available on this device.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        case AuthResult.lockedOut:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometrics are temporarily locked. Use your device PIN or try again later.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        case AuthResult.cancelled:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric unlock cancelled.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
        case AuthResult.error:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric unlock failed. Please try again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          break;
      }
    } finally {
      if (mounted) setState(() => _isBiometricLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(
                    math.cos(_bgCtrl.value * 2 * math.pi) * 0.5,
                    math.sin(_bgCtrl.value * 2 * math.pi) * 0.5,
                  ),
                  end: Alignment(
                    math.cos((_bgCtrl.value + 0.5) * 2 * math.pi) * 0.5,
                    math.sin((_bgCtrl.value + 0.5) * 2 * math.pi) * 0.5,
                  ),
                  colors: const [
                    AppColors.navyDark,
                    Color(0xFF0A1628),
                    AppColors.navy,
                    Color(0xFF0F2240),
                  ],
                ),
              ),
            ),
          ),

          // Floating particle orbs
          ..._buildParticles(),

          // Heartbeat ECG line
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Opacity(
                opacity: _pulseAnim.value * 0.15,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 100),
                  painter: _HeartbeatPainter(progress: _bgCtrl.value),
                ),
              ),
            ),
          ),

          // Main content
          isWide ? _buildWideLayout() : _buildNarrowLayout(),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    final particles = <_ParticleData>[
      _ParticleData(top: -80, right: -60, size: 320, color: AppColors.blue.withValues(alpha: 0.08), speed: 1.0),
      _ParticleData(bottom: -100, left: -80, size: 280, color: AppColors.blueMid.withValues(alpha: 0.06), speed: 1.5),
      _ParticleData(top: 100, left: -40, size: 180, color: AppColors.navyAccent.withValues(alpha: 0.12), speed: 2.0),
      _ParticleData(bottom: 200, right: 100, size: 120, color: AppColors.blue.withValues(alpha: 0.05), speed: 0.8),
    ];

    return particles.map((p) {
      return AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) {
          final offset = math.sin(_bgCtrl.value * 2 * math.pi * p.speed) * 20;
          return Positioned(
            top: p.top != null ? p.top! + offset : null,
            bottom: p.bottom != null ? p.bottom! - offset : null,
            left: p.left != null ? p.left! + offset * 0.5 : null,
            right: p.right != null ? p.right! - offset * 0.5 : null,
            child: Container(
              width: p.size,
              height: p.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: p.color,
                boxShadow: [
                  BoxShadow(
                      color: p.color,
                      blurRadius: p.size * 0.6,
                      spreadRadius: p.size * 0.1)
                ],
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        // Left brand panel
        Expanded(flex: 5, child: _BrandPanel(pulseAnim: _pulseAnim)),
        // Right form panel
        Expanded(
          flex: 5,
          child: Center(
            child: FadeTransition(
              opacity: _formFade,
              child: SlideTransition(
                position: _formSlide,
                child: _buildFormCard(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _CompactHeader(pulseAnim: _pulseAnim),
          FadeTransition(
            opacity: _formFade,
            child: SlideTransition(
              position: _formSlide,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildFormCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 60,
              offset: const Offset(0, 20)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 4,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.blueMid, AppColors.navy],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome Back',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('Sign in to your account',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.white38)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blue.withValues(alpha: 0.28)),
              ),
              child: Text(
                'DEMO MODE\nEmail: ${DemoAuthService.demoEmail}  ·  Password: ${DemoAuthService.demoPassword}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.5,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Username field
            _GlassField(
              controller: _usernameCtrl,
              label: 'Username or Email',
              icon: Icons.person_outline,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Password field
            _GlassField(
              controller: _passwordCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              obscure: _obscure,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: Colors.white38),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 8) return 'Min 8 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: _TextLink(text: 'Forgot password?', onTap: () {}),
            ),
            const SizedBox(height: 24),

            // Sign In button
            _AnimatedGradientButton(
              label: 'Sign In',
              icon: Icons.login_rounded,
              isLoading: _isLoading,
              onTap: _login,
            ),
            const SizedBox(height: 16),

            // OS biometric unlock using the device lock / face / fingerprint
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _isBiometricLoading ? null : _loginWithBiometrics,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isBiometricLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        else
                          const Icon(Icons.fingerprint_rounded, color: Colors.white),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            _isBiometricLoading
                                ? 'Checking device lock...'
                                : 'Use Face ID / Fingerprint',
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            Row(
              children: [
                Expanded(
                    child: Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('or continue with',
                      style: GoogleFonts.inter(
                          fontSize: 11.5, color: Colors.white30)),
                ),
                Expanded(
                    child: Container(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.08))),
              ],
            ),
            const SizedBox(height: 20),

            // Social buttons
            Row(
              children: [
                Expanded(
                    child: _SocialButton(
                        label: 'Google', icon: Icons.g_mobiledata_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _SocialButton(label: 'Apple', icon: Icons.apple)),
              ],
            ),
            const SizedBox(height: 24),

            // Sign up link
            Center(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
                  children: [
                    const TextSpan(text: 'Don\'t have an account? '),
                    WidgetSpan(
                        child: _TextLink(
                            text: 'Sign Up',
                            onTap: () =>
                                Navigator.of(context).pushNamed('/signup'))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticleData {
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final double speed;

  const _ParticleData({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.speed,
  });
}

// ── Brand Panel (wide layout)
class _BrandPanel extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _BrandPanel({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, Color(0xFF0F1D34)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing logo
              AnimatedBuilder(
                animation: pulseAnim,
                builder: (_, child) => Transform.scale(
                  scale: 0.95 + pulseAnim.value * 0.05,
                  child: child,
                ),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFB8C8D8), Color(0xFF6A7F94)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue.withValues(alpha: 0.35),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: ClipOval(
                    child: Image.asset('web/hospital_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                              color: AppColors.navyAccent,
                              child: const Icon(Icons.local_hospital,
                                  color: Colors.white60, size: 50),
                            )),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('MyHospital',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Text('Healthcare at Your Fingertips',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white38,
                      letterSpacing: 0.5)),
              const SizedBox(height: 48),
              // Feature highlights
              ...[
                _FeatureRow(
                    icon: Icons.shield_outlined,
                    text: 'HIPAA & DPDPA Compliant'),
                _FeatureRow(
                    icon: Icons.verified_outlined,
                    text: '2,000+ Verified Doctors'),
                _FeatureRow(
                    icon: Icons.favorite_border,
                    text: '50,000+ Happy Patients'),
                _FeatureRow(
                    icon: Icons.access_time,
                    text: '24/7 Emergency Access'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _CompactHeader({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: 0.95 + pulseAnim.value * 0.05,
              child: child,
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFB8C8D8), Color(0xFF6A7F94)],
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.3),
                      blurRadius: 28,
                      spreadRadius: 3)
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: ClipOval(
                child: Image.asset('web/hospital_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 36)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('MyHospital',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text('Sign in to continue',
              style:
                  GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blue.withValues(alpha: 0.18)),
            child: Icon(icon, color: Colors.white60, size: 16),
          ),
          const SizedBox(width: 12),
          Text(text,
              style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _GlassField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _GlassField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<_GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<_GlassField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: _focused
                  ? AppColors.blueMid.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.1)),
          boxShadow: _focused
              ? [
                  BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.obscure,
          validator: widget.validator,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: GoogleFonts.inter(
                fontSize: 13.5,
                color: _focused ? AppColors.blueMid : Colors.white38),
            prefixIcon: Icon(widget.icon,
                size: 18,
                color: _focused ? AppColors.blueMid : Colors.white38),
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: _focused
                ? AppColors.blue.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.04),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.accent),
          ),
        ),
      ),
    );
  }
}

class _AnimatedGradientButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;

  const _AnimatedGradientButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_AnimatedGradientButton> createState() =>
      _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<_AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform:
                Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(
                    -1 + _shimmerCtrl.value * 3, 0),
                end: Alignment(
                    1 + _shimmerCtrl.value * 3, 0),
                colors: _hovered
                    ? [
                        AppColors.blueDark,
                        AppColors.blueMid,
                        AppColors.blue,
                        AppColors.blueDark,
                      ]
                    : [
                        AppColors.blue,
                        AppColors.blueMid,
                        AppColors.blue,
                      ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue
                      .withValues(alpha: _hovered ? 0.45 : 0.25),
                  blurRadius: _hovered ? 24 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon, size: 18, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(widget.label,
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatefulWidget {
  final String label;
  final IconData icon;
  const _SocialButton({required this.label, required this.icon});
  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 50,
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _hovered
                    ? AppColors.blueMid.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  size: 22,
                  color:
                      _hovered ? AppColors.blueMid : Colors.white60),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _hovered
                          ? Colors.white
                          : Colors.white60)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _TextLink({required this.text, required this.onTap});
  @override
  State<_TextLink> createState() => _TextLinkState();
}

class _TextLinkState extends State<_TextLink> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(widget.text,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _hovered ? Colors.white : AppColors.blueMid,
                decoration: _hovered
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: AppColors.blueMid)),
      ),
    );
  }
}

// ── Custom Heartbeat ECG Line Painter
class _HeartbeatPainter extends CustomPainter {
  final double progress;
  _HeartbeatPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.blueMid
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final midY = h * 0.6;

    // Create ECG-like wave pattern
    final offset = progress * w;

    path.moveTo(0, midY);
    for (double x = 0; x < w; x += 1) {
      final adjustedX = (x + offset) % w;
      final normalized = (adjustedX % 200) / 200;

      double y;
      if (normalized > 0.35 && normalized < 0.4) {
        y = midY - 30 * math.sin((normalized - 0.35) / 0.05 * math.pi);
      } else if (normalized > 0.4 && normalized < 0.45) {
        y = midY + 50 * math.sin((normalized - 0.4) / 0.05 * math.pi);
      } else if (normalized > 0.45 && normalized < 0.5) {
        y = midY - 20 * math.sin((normalized - 0.45) / 0.05 * math.pi);
      } else {
        y = midY + math.sin(normalized * 4 * math.pi) * 2;
      }

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartbeatPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
