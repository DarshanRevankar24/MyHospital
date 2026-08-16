import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
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
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      _showSnack('Please accept the Terms & Privacy Policy to continue.');
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      _showSnack('Account created successfully! Welcome to MyHospital 🎉',
          isSuccess: true);
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13.5)),
        backgroundColor:
            isSuccess ? AppColors.blue : AppColors.accent,
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
          // ── Background decorative circles
          Positioned(
            top: -80,
            right: -80,
            child: _GlowCircle(size: 320, color: AppColors.blueMid.withOpacity(0.15)),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _GlowCircle(size: 260, color: AppColors.navyMid.withOpacity(0.5)),
          ),
          Positioned(
            top: 200,
            left: 100,
            child: _GlowCircle(size: 120, color: AppColors.blueDark.withOpacity(0.2)),
          ),

          // ── Main content
          isWide ? _WideLayout(
            fadeAnim: _fadeAnim,
            slideAnim: _slideAnim,
            formKey: _formKey,
            firstNameCtrl: _firstNameCtrl,
            lastNameCtrl: _lastNameCtrl,
            emailCtrl: _emailCtrl,
            phoneCtrl: _phoneCtrl,
            passwordCtrl: _passwordCtrl,
            confirmCtrl: _confirmCtrl,
            obscurePassword: _obscurePassword,
            obscureConfirm: _obscureConfirm,
            agreeTerms: _agreeTerms,
            isLoading: _isLoading,
            onTogglePassword: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onToggleConfirm: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            onTermsChanged: (v) => setState(() => _agreeTerms = v ?? false),
            onSubmit: _submit,
          ) : _NarrowLayout(
            fadeAnim: _fadeAnim,
            slideAnim: _slideAnim,
            formKey: _formKey,
            firstNameCtrl: _firstNameCtrl,
            lastNameCtrl: _lastNameCtrl,
            emailCtrl: _emailCtrl,
            phoneCtrl: _phoneCtrl,
            passwordCtrl: _passwordCtrl,
            confirmCtrl: _confirmCtrl,
            obscurePassword: _obscurePassword,
            obscureConfirm: _obscureConfirm,
            agreeTerms: _agreeTerms,
            isLoading: _isLoading,
            onTogglePassword: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onToggleConfirm: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            onTermsChanged: (v) => setState(() => _agreeTerms = v ?? false),
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

// ── Glow circle decoration
class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: size * 0.5, spreadRadius: size * 0.1),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ── Wide (desktop) Layout
// ─────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, passwordCtrl, confirmCtrl;
  final bool obscurePassword, obscureConfirm, agreeTerms, isLoading;
  final VoidCallback onTogglePassword, onToggleConfirm, onSubmit;
  final ValueChanged<bool?> onTermsChanged;

  const _WideLayout({
    required this.fadeAnim,
    required this.slideAnim,
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.agreeTerms,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onTermsChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel – branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.navyDark, AppColors.navyMid],
              ),
            ),
            child: _BrandPanel(),
          ),
        ),
        // Right panel – form
        Expanded(
          flex: 6,
          child: Container(
            color: Colors.white,
            child: _FormPanel(
              fadeAnim: fadeAnim,
              slideAnim: slideAnim,
              formKey: formKey,
              firstNameCtrl: firstNameCtrl,
              lastNameCtrl: lastNameCtrl,
              emailCtrl: emailCtrl,
              phoneCtrl: phoneCtrl,
              passwordCtrl: passwordCtrl,
              confirmCtrl: confirmCtrl,
              obscurePassword: obscurePassword,
              obscureConfirm: obscureConfirm,
              agreeTerms: agreeTerms,
              isLoading: isLoading,
              onTogglePassword: onTogglePassword,
              onToggleConfirm: onToggleConfirm,
              onTermsChanged: onTermsChanged,
              onSubmit: onSubmit,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ── Narrow (mobile) Layout
// ─────────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, passwordCtrl, confirmCtrl;
  final bool obscurePassword, obscureConfirm, agreeTerms, isLoading;
  final VoidCallback onTogglePassword, onToggleConfirm, onSubmit;
  final ValueChanged<bool?> onTermsChanged;

  const _NarrowLayout({
    required this.fadeAnim,
    required this.slideAnim,
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.agreeTerms,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onTermsChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Mini brand header for narrow screens
          Container(
            color: AppColors.navyDark,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: _MiniHeader(),
          ),
          Container(
            color: Colors.white,
            child: _FormPanel(
              fadeAnim: fadeAnim,
              slideAnim: slideAnim,
              formKey: formKey,
              firstNameCtrl: firstNameCtrl,
              lastNameCtrl: lastNameCtrl,
              emailCtrl: emailCtrl,
              phoneCtrl: phoneCtrl,
              passwordCtrl: passwordCtrl,
              confirmCtrl: confirmCtrl,
              obscurePassword: obscurePassword,
              obscureConfirm: obscureConfirm,
              agreeTerms: agreeTerms,
              isLoading: isLoading,
              onTogglePassword: onTogglePassword,
              onToggleConfirm: onToggleConfirm,
              onTermsChanged: onTermsChanged,
              onSubmit: onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ── Left Brand Panel (desktop)
// ─────────────────────────────────────────────
class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          _BackButton(),
          const Spacer(),

          // Logo
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'web/hospital_logo.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.navyAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.local_hospital,
                      color: Colors.white60, size: 80),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Center(
            child: Text(
              'MyHospital',
              style: GoogleFonts.playfairDisplay(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Compassionate Care · Modern Medicine',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white54,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),

          // Trust badges
          ..._TrustBadge.items.map((b) => _TrustBadgeItem(badge: b)),

          const Spacer(),

          // Footer note
          Text(
            '© 2026 MyHospital · NABH Accredited',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white30),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MiniHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
        ),
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            'web/hospital_logo.png',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.local_hospital, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'MyHospital',
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const Spacer(),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_ios_new, color: Colors.white60, size: 15),
            const SizedBox(width: 6),
            Text('Back to Home',
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.white60, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _TrustBadge {
  final IconData icon;
  final String title;
  final String subtitle;
  const _TrustBadge(
      {required this.icon, required this.title, required this.subtitle});

  static const items = [
    _TrustBadge(
        icon: Icons.security_outlined,
        title: 'HIPAA Compliant',
        subtitle: 'Your data is 100% secure'),
    _TrustBadge(
        icon: Icons.verified_outlined,
        title: 'NABH Accredited',
        subtitle: 'National quality standards'),
    _TrustBadge(
        icon: Icons.people_outline,
        title: '50,000+ Patients',
        subtitle: 'Trusted across Karnataka'),
  ];
}

class _TrustBadgeItem extends StatelessWidget {
  final _TrustBadge badge;
  const _TrustBadgeItem({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(badge.icon, color: Colors.white70, size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(badge.title,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
              Text(badge.subtitle,
                  style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ── Form Panel (shared)
// ─────────────────────────────────────────────
class _FormPanel extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl, lastNameCtrl, emailCtrl,
      phoneCtrl, passwordCtrl, confirmCtrl;
  final bool obscurePassword, obscureConfirm, agreeTerms, isLoading;
  final VoidCallback onTogglePassword, onToggleConfirm, onSubmit;
  final ValueChanged<bool?> onTermsChanged;

  const _FormPanel({
    required this.fadeAnim,
    required this.slideAnim,
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.agreeTerms,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onTermsChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 52),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text('Create Account',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy)),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textMid),
                      children: [
                        const TextSpan(text: 'Already registered? '),
                        WidgetSpan(
                          child: _TextLink(
                            text: 'Sign in',
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name row
                  Row(
                    children: [
                      Expanded(
                        child: _SignupField(
                          controller: firstNameCtrl,
                          label: 'First Name',
                          icon: Icons.person_outline,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _SignupField(
                          controller: lastNameCtrl,
                          label: 'Last Name',
                          icon: Icons.person_outline,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _SignupField(
                    controller: emailCtrl,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  _SignupField(
                    controller: phoneCtrl,
                    label: 'Mobile Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length < 10) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _SignupField(
                    controller: passwordCtrl,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    obscure: obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: AppColors.textSoft,
                      ),
                      onPressed: onTogglePassword,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 8) return 'Min 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm password
                  _SignupField(
                    controller: confirmCtrl,
                    label: 'Confirm Password',
                    icon: Icons.lock_outline,
                    obscure: obscureConfirm,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: AppColors.textSoft,
                      ),
                      onPressed: onToggleConfirm,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v != passwordCtrl.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Role selection
                  _RoleSelector(),
                  const SizedBox(height: 20),

                  // Terms
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: agreeTerms,
                          onChanged: onTermsChanged,
                          activeColor: AppColors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          side: const BorderSide(
                              color: AppColors.border, width: 1.5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.textMid),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              WidgetSpan(
                                  child: _TextLink(
                                      text: 'Terms of Service',
                                      onTap: () {})),
                              const TextSpan(text: ' and '),
                              WidgetSpan(
                                  child: _TextLink(
                                      text: 'Privacy Policy',
                                      onTap: () {})),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Submit button
                  _SubmitButton(isLoading: isLoading, onTap: onSubmit),
                  const SizedBox(height: 28),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                          child: Divider(color: AppColors.border, height: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or continue with',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.textSoft)),
                      ),
                      const Expanded(
                          child: Divider(color: AppColors.border, height: 1)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Social buttons
                  Row(
                    children: [
                      Expanded(
                          child: _SocialButton(
                              label: 'Google',
                              icon: Icons.g_mobiledata_rounded)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _SocialButton(
                              label: 'Apple',
                              icon: Icons.apple)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ── Individual Form Field
// ─────────────────────────────────────────────
class _SignupField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _SignupField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
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
        controller: widget.controller,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: GoogleFonts.inter(
            fontSize: 13.5,
            color: _focused ? AppColors.blue : AppColors.textSoft,
          ),
          prefixIcon: Icon(widget.icon,
              size: 18,
              color: _focused ? AppColors.blue : AppColors.textSoft),
          suffixIcon: widget.suffixIcon,
          filled: true,
          fillColor: _focused ? AppColors.blueLight : AppColors.bg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.blue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ── Role Selector
// ─────────────────────────────────────────────
class _RoleSelector extends StatefulWidget {
  @override
  State<_RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<_RoleSelector> {
  String _selected = 'Patient';

  static const _roles = ['Patient', 'Doctor', 'Staff'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Register as',
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMid)),
        const SizedBox(height: 10),
        Row(
          children: _roles
              .map((role) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: role != _roles.last ? 10 : 0),
                      child: _RoleChip(
                        label: role,
                        selected: _selected == role,
                        onTap: () => setState(() => _selected = role),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _RoleChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RoleChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  State<_RoleChip> createState() => _RoleChipState();
}

class _RoleChipState extends State<_RoleChip> {
  bool _hovered = false;

  static const _icons = {
    'Patient': Icons.person_outline,
    'Doctor': Icons.medical_services_outlined,
    'Staff': Icons.badge_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: widget.selected
                ? AppColors.blue
                : (_hovered ? AppColors.blueLight : AppColors.bg),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.selected ? AppColors.blue : AppColors.border,
              width: widget.selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                _icons[widget.label] ?? Icons.person_outline,
                size: 20,
                color: widget.selected ? Colors.white : AppColors.textMid,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: widget.selected ? Colors.white : AppColors.textMid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ── Submit Button
// ─────────────────────────────────────────────
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
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered && !widget.isLoading
                  ? [AppColors.blueDark, AppColors.navy]
                  : [AppColors.blue, AppColors.navyMid],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _hovered && !widget.isLoading
                ? [
                    BoxShadow(
                      color: AppColors.blue.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Create Account',
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward,
                          size: 18, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ── Social Login Button
// ─────────────────────────────────────────────
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
          height: 48,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.bg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _hovered ? AppColors.blue : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  size: 22,
                  color: _hovered ? AppColors.blue : AppColors.textMid),
              const SizedBox(width: 8),
              Text(widget.label,
                  style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _hovered ? AppColors.blue : AppColors.textMid)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ── Inline text link
// ─────────────────────────────────────────────
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
        child: Text(
          widget.text,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _hovered ? AppColors.blueDark : AppColors.blue,
            decoration: _hovered ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
