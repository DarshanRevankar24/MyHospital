import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/demo_auth_service.dart';
import '../theme/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  String _gender = 'Male';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  bool _isLoading = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      _showSnack('Please accept the Terms & Privacy Policy to continue.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await DemoAuthService.instance.signUp(
        name: '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}',
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Account created! Welcome to MyHospital 🎉', isSuccess: true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(error.toString());
      }
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5)),
        backgroundColor: isSuccess ? AppColors.blue : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          Positioned(
            top: -100, right: -100,
            child: _GlowOrb(size: 380, color: AppColors.blueMid.withValues(alpha: 0.12)),
          ),
          Positioned(
            bottom: -80, left: -80,
            child: _GlowOrb(size: 300, color: AppColors.navyMid.withValues(alpha: 0.6)),
          ),
          isWide
              ? _WideLayout(
                  fadeAnim: _fadeAnim,
                  slideAnim: _slideAnim,
                  formKey: _formKey,
                  firstNameCtrl: _firstNameCtrl,
                  lastNameCtrl: _lastNameCtrl,
                  emailCtrl: _emailCtrl,
                  phoneCtrl: _phoneCtrl,
                  passwordCtrl: _passwordCtrl,
                  confirmCtrl: _confirmCtrl,
                  dobCtrl: _dobCtrl,
                  gender: _gender,
                  obscurePassword: _obscurePassword,
                  obscureConfirm: _obscureConfirm,
                  agreeTerms: _agreeTerms,
                  isLoading: _isLoading,
                  onTogglePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onToggleConfirm: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  onGenderChanged: (v) => setState(() => _gender = v),
                  onTermsChanged: (v) =>
                      setState(() => _agreeTerms = v ?? false),
                  onSubmit: _submit,
                )
              : _NarrowLayout(
                  fadeAnim: _fadeAnim,
                  slideAnim: _slideAnim,
                  formKey: _formKey,
                  firstNameCtrl: _firstNameCtrl,
                  lastNameCtrl: _lastNameCtrl,
                  emailCtrl: _emailCtrl,
                  phoneCtrl: _phoneCtrl,
                  passwordCtrl: _passwordCtrl,
                  confirmCtrl: _confirmCtrl,
                  dobCtrl: _dobCtrl,
                  gender: _gender,
                  obscurePassword: _obscurePassword,
                  obscureConfirm: _obscureConfirm,
                  agreeTerms: _agreeTerms,
                  isLoading: _isLoading,
                  onTogglePassword: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  onToggleConfirm: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  onGenderChanged: (v) => setState(() => _gender = v),
                  onTermsChanged: (v) =>
                      setState(() => _agreeTerms = v ?? false),
                  onSubmit: _submit,
                ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: size * 0.55, spreadRadius: size * 0.1)],
      ),
    );
  }
}

// ── Wide layout
class _WideLayout extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, passwordCtrl, confirmCtrl, dobCtrl;
  final String gender;
  final bool obscurePassword, obscureConfirm, agreeTerms, isLoading;
  final VoidCallback onTogglePassword, onToggleConfirm, onSubmit;
  final ValueChanged<bool?> onTermsChanged;
  final ValueChanged<String> onGenderChanged;

  const _WideLayout({
    required this.fadeAnim, required this.slideAnim, required this.formKey,
    required this.firstNameCtrl, required this.lastNameCtrl,
    required this.emailCtrl, required this.phoneCtrl,
    required this.passwordCtrl, required this.confirmCtrl, required this.dobCtrl,
    required this.gender, required this.obscurePassword, required this.obscureConfirm,
    required this.agreeTerms, required this.isLoading,
    required this.onTogglePassword, required this.onToggleConfirm,
    required this.onTermsChanged, required this.onGenderChanged, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(flex: 5, child: _BrandPanel()),
      Expanded(
        flex: 6,
        child: Container(
          color: Colors.white,
          child: _FormPanel(
            fadeAnim: fadeAnim, slideAnim: slideAnim, formKey: formKey,
            firstNameCtrl: firstNameCtrl, lastNameCtrl: lastNameCtrl,
            emailCtrl: emailCtrl, phoneCtrl: phoneCtrl,
            passwordCtrl: passwordCtrl, confirmCtrl: confirmCtrl,
            dobCtrl: dobCtrl, gender: gender,
            obscurePassword: obscurePassword, obscureConfirm: obscureConfirm,
            agreeTerms: agreeTerms, isLoading: isLoading,
            onTogglePassword: onTogglePassword, onToggleConfirm: onToggleConfirm,
            onTermsChanged: onTermsChanged, onGenderChanged: onGenderChanged,
            onSubmit: onSubmit,
          ),
        ),
      ),
    ]);
  }
}

// ── Narrow layout
class _NarrowLayout extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, passwordCtrl, confirmCtrl, dobCtrl;
  final String gender;
  final bool obscurePassword, obscureConfirm, agreeTerms, isLoading;
  final VoidCallback onTogglePassword, onToggleConfirm, onSubmit;
  final ValueChanged<bool?> onTermsChanged;
  final ValueChanged<String> onGenderChanged;

  const _NarrowLayout({
    required this.fadeAnim, required this.slideAnim, required this.formKey,
    required this.firstNameCtrl, required this.lastNameCtrl,
    required this.emailCtrl, required this.phoneCtrl,
    required this.passwordCtrl, required this.confirmCtrl, required this.dobCtrl,
    required this.gender, required this.obscurePassword, required this.obscureConfirm,
    required this.agreeTerms, required this.isLoading,
    required this.onTogglePassword, required this.onToggleConfirm,
    required this.onTermsChanged, required this.onGenderChanged, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.navyDark, AppColors.navyMid],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 28),
        child: _MiniHeader(),
      ),
      Container(
        color: Colors.white,
        child: _FormPanel(
          fadeAnim: fadeAnim, slideAnim: slideAnim, formKey: formKey,
          firstNameCtrl: firstNameCtrl, lastNameCtrl: lastNameCtrl,
          emailCtrl: emailCtrl, phoneCtrl: phoneCtrl,
          passwordCtrl: passwordCtrl, confirmCtrl: confirmCtrl,
          dobCtrl: dobCtrl, gender: gender,
          obscurePassword: obscurePassword, obscureConfirm: obscureConfirm,
          agreeTerms: agreeTerms, isLoading: isLoading,
          onTogglePassword: onTogglePassword, onToggleConfirm: onToggleConfirm,
          onTermsChanged: onTermsChanged, onGenderChanged: onGenderChanged,
          onSubmit: onSubmit,
        ),
      ),
    ]));
  }
}

// ── Brand Panel
class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.navyDark, Color(0xFF1A2C4A)],
        ),
      ),
      child: LayoutBuilder(builder: (ctx, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 80),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _BackButton(),
                  ),
                  const Spacer(),
                  // Circular logo
                  Container(
                    width: 150,
                    height: 150,
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
                          blurRadius: 36,
                          spreadRadius: 3,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    child: ClipOval(
                      child: Image.asset(
                        'web/hospital_logo.png',
                        width: 140, height: 140, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.navyAccent,
                          child: const Icon(Icons.local_hospital,
                              color: Colors.white60, size: 60),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('MyHospital',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 28, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: -0.3)),
                  const SizedBox(height: 5),
                  Text('Healthcare at Your Fingertips',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.white38, letterSpacing: 0.3),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 28),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.15),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ..._TrustBadge.items.map((b) => _TrustBadgeItem(badge: b)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.blue.withValues(alpha: 0.25), width: 1),
                    ),
                    child: Row(children: [
                      const Icon(Icons.person_pin_circle_outlined,
                          color: Colors.white60, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Patient accounts only. Staff & vendors use their dedicated portals.',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.white54, height: 1.5),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Text('© 2026 MyHospital · Healthcare Marketplace',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.white24)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Mini header
class _MiniHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
        ),
      ]),
      const SizedBox(height: 8),
      Container(
        width: 90, height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFB8C8D8), Color(0xFF6A7F94)],
          ),
          boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.3), blurRadius: 24, spreadRadius: 2)],
        ),
        padding: const EdgeInsets.all(3),
        child: ClipOval(
          child: Image.asset('web/hospital_logo.png', width: 84, height: 84, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.local_hospital, color: Colors.white, size: 40)),
        ),
      ),
      const SizedBox(height: 14),
      Text('MyHospital',
          style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 4),
      Text('Healthcare at Your Fingertips',
          style: GoogleFonts.inter(fontSize: 12, color: Colors.white38)),
    ]);
  }
}

// ── Back button
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.arrow_back_ios_new, color: Colors.white60, size: 13),
            const SizedBox(width: 6),
            Text('Back to Home',
                style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white60, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}

// ── Trust badge data
class _TrustBadge {
  final IconData icon;
  final String title;
  final String subtitle;
  const _TrustBadge({required this.icon, required this.title, required this.subtitle});

  static const items = [
    _TrustBadge(icon: Icons.shield_outlined, title: 'Your data is safe', subtitle: 'HIPAA & DPDPA compliant encryption'),
    _TrustBadge(icon: Icons.verified_outlined, title: 'Verified Providers', subtitle: '2,000+ doctors, 300+ labs, 200+ pharmacies'),
    _TrustBadge(icon: Icons.favorite_border, title: '50,000+ Happy Patients', subtitle: 'Trusted across Karnataka'),
  ];
}

class _TrustBadgeItem extends StatelessWidget {
  final _TrustBadge badge;
  const _TrustBadgeItem({required this.badge});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.blue.withValues(alpha: 0.2)),
          child: Icon(badge.icon, color: Colors.white70, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(badge.title,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 2),
          Text(badge.subtitle,
              style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white38)),
        ])),
      ]),
    );
  }
}

// ── Form Panel
class _FormPanel extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, passwordCtrl, confirmCtrl, dobCtrl;
  final String gender;
  final bool obscurePassword, obscureConfirm, agreeTerms, isLoading;
  final VoidCallback onTogglePassword, onToggleConfirm, onSubmit;
  final ValueChanged<bool?> onTermsChanged;
  final ValueChanged<String> onGenderChanged;

  const _FormPanel({
    required this.fadeAnim, required this.slideAnim, required this.formKey,
    required this.firstNameCtrl, required this.lastNameCtrl,
    required this.emailCtrl, required this.phoneCtrl,
    required this.passwordCtrl, required this.confirmCtrl, required this.dobCtrl,
    required this.gender, required this.obscurePassword, required this.obscureConfirm,
    required this.agreeTerms, required this.isLoading,
    required this.onTogglePassword, required this.onToggleConfirm,
    required this.onTermsChanged, required this.onGenderChanged, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 48),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Header
                Row(children: [
                  Container(
                    width: 4, height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [AppColors.blueMid, AppColors.navy],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Create Patient Account',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.navy)),
                    const SizedBox(height: 3),
                    Text('Join 50,000+ patients on MyHospital',
                        style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textSoft)),
                  ]),
                ]),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.blueLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Offline demo: this account is kept in memory for testing and is not sent to a server.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMid,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: RichText(text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textMid),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      WidgetSpan(child: _TextLink(text: 'Sign in', onTap: () => Navigator.of(context).maybePop())),
                    ],
                  )),
                ),
                const SizedBox(height: 28),

                _SectionLabel(label: 'Personal Details'),
                const SizedBox(height: 14),

                Row(children: [
                  Expanded(child: _SignupField(controller: firstNameCtrl, label: 'First Name', icon: Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null)),
                  const SizedBox(width: 14),
                  Expanded(child: _SignupField(controller: lastNameCtrl, label: 'Last Name', icon: Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null)),
                ]),
                const SizedBox(height: 14),

                Row(children: [
                  Expanded(child: _SignupField(
                    controller: dobCtrl, label: 'Date of Birth',
                    icon: Icons.cake_outlined, keyboardType: TextInputType.datetime,
                    hint: 'DD / MM / YYYY',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  )),
                  const SizedBox(width: 14),
                  Expanded(child: _GenderSelector(value: gender, onChanged: onGenderChanged)),
                ]),
                const SizedBox(height: 22),

                _SectionLabel(label: 'Contact Information'),
                const SizedBox(height: 14),

                _SignupField(controller: emailCtrl, label: 'Email Address', icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    }),
                const SizedBox(height: 14),

                _SignupField(controller: phoneCtrl, label: 'Mobile Number', icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length < 10) return 'Enter a valid number';
                      return null;
                    }),
                const SizedBox(height: 22),

                _SectionLabel(label: 'Security'),
                const SizedBox(height: 14),

                _SignupField(controller: passwordCtrl, label: 'Password', icon: Icons.lock_outline,
                    obscure: obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18, color: AppColors.textSoft),
                      onPressed: onTogglePassword,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 8) return 'Min 8 characters';
                      return null;
                    }),
                const SizedBox(height: 14),

                _SignupField(controller: confirmCtrl, label: 'Confirm Password', icon: Icons.lock_outline,
                    obscure: obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18, color: AppColors.textSoft),
                      onPressed: onToggleConfirm,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v != passwordCtrl.text) return 'Passwords do not match';
                      return null;
                    }),
                const SizedBox(height: 24),

                // Terms
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: agreeTerms ? AppColors.blueLight : AppColors.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: agreeTerms ? AppColors.blue.withValues(alpha: 0.3) : AppColors.border),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 20, height: 20,
                        child: Checkbox(
                          value: agreeTerms, onChanged: onTermsChanged,
                          activeColor: AppColors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          side: const BorderSide(color: AppColors.border, width: 1.5),
                        )),
                    const SizedBox(width: 12),
                    Expanded(child: RichText(text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMid),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        WidgetSpan(child: _TextLink(text: 'Terms of Service', onTap: () {})),
                        const TextSpan(text: ' and '),
                        WidgetSpan(child: _TextLink(text: 'Privacy Policy', onTap: () {})),
                        const TextSpan(text: '. Your health data is encrypted and never shared.'),
                      ],
                    ))),
                  ]),
                ),
                const SizedBox(height: 26),

                _SubmitButton(isLoading: isLoading, onTap: onSubmit),
                const SizedBox(height: 26),

                Row(children: [
                  const Expanded(child: Divider(color: AppColors.border, height: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or sign up with', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
                  ),
                  const Expanded(child: Divider(color: AppColors.border, height: 1)),
                ]),
                const SizedBox(height: 18),

                Row(children: [
                  Expanded(child: _SocialButton(label: 'Google', icon: Icons.g_mobiledata_rounded)),
                  const SizedBox(width: 12),
                  Expanded(child: _SocialButton(label: 'Apple', icon: Icons.apple)),
                ]),
                const SizedBox(height: 8),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.blue, letterSpacing: 1.1)),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 1, color: AppColors.blueLight)),
    ]);
  }
}

class _GenderSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _GenderSelector({required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Gender', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
      const SizedBox(height: 6),
      Container(
        height: 54,
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: ['Male', 'Female', 'Other'].map((g) => Expanded(child: GestureDetector(
          onTap: () => onChanged(g),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: value == g ? AppColors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(child: Text(g, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
              color: value == g ? Colors.white : AppColors.textMid,
            ))),
          ),
        ))).toList()),
      ),
    ]);
  }
}

class _SignupField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _SignupField({
    required this.controller, required this.label, required this.icon,
    this.hint, this.obscure = false, this.suffixIcon, this.keyboardType, this.validator,
  });

  @override
  State<_SignupField> createState() => _SignupFieldState();
}

class _SignupFieldState extends State<_SignupField> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: TextFormField(
        controller: widget.controller, obscureText: widget.obscure,
        keyboardType: widget.keyboardType, validator: widget.validator,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSoft),
          labelStyle: GoogleFonts.inter(fontSize: 13.5, color: _focused ? AppColors.blue : AppColors.textSoft),
          prefixIcon: Icon(widget.icon, size: 18, color: _focused ? AppColors.blue : AppColors.textSoft),
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: _focused ? AppColors.blueLight : AppColors.bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.blue, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _SubmitButton({required this.isLoading, required this.onTap});
  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(0, _hovered && !widget.isLoading ? -2 : 0, 0),
          width: double.infinity, height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft, end: Alignment.centerRight,
              colors: _hovered && !widget.isLoading
                  ? [AppColors.blueDark, AppColors.navy]
                  : [AppColors.blue, AppColors.navyMid],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(
              color: AppColors.blue.withValues(alpha: _hovered && !widget.isLoading ? 0.38 : 0.18),
              blurRadius: _hovered && !widget.isLoading ? 22 : 12,
              offset: const Offset(0, 6),
            )],
          ),
          child: Center(child: widget.isLoading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.how_to_reg_outlined, size: 18, color: Colors.white),
                  const SizedBox(width: 10),
                  Text('Create My Account',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.2)),
                ])),
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
            color: _hovered ? AppColors.blueLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _hovered ? AppColors.blue : AppColors.border, width: _hovered ? 1.5 : 1),
            boxShadow: _hovered ? [BoxShadow(color: AppColors.blue.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(widget.icon, size: 22, color: _hovered ? AppColors.blue : AppColors.textMid),
            const SizedBox(width: 8),
            Text(widget.label, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600,
                color: _hovered ? AppColors.blue : AppColors.textMid)),
          ]),
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
        child: Text(widget.text, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: _hovered ? AppColors.blueDark : AppColors.blue,
          decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
        )),
      ),
    );
  }
}
