import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class LabTestsScreen extends StatefulWidget {
  const LabTestsScreen({super.key});
  @override
  State<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends State<LabTestsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  String _searchQuery = '';
  final Set<int> _selectedTests = {};

  static const _tests = [
    _Test(
      name: 'Complete Blood Count (CBC)',
      category: 'Hematology',
      turnaround: '4 hrs',
      popular: true,
    ),
    _Test(
      name: 'Lipid Profile',
      category: 'Biochemistry',
      turnaround: '6 hrs',
      popular: true,
    ),
    _Test(
      name: 'Thyroid Profile (T3/T4/TSH)',
      category: 'Endocrine',
      turnaround: '8 hrs',
      popular: true,
    ),
    _Test(
      name: 'HbA1c (Diabetes)',
      category: 'Diabetes',
      turnaround: '4 hrs',
      popular: false,
    ),
    _Test(
      name: 'Liver Function Test',
      category: 'Biochemistry',
      turnaround: '6 hrs',
      popular: false,
    ),
    _Test(
      name: 'Kidney Function Test',
      category: 'Biochemistry',
      turnaround: '6 hrs',
      popular: false,
    ),
    _Test(
      name: 'Vitamin D',
      category: 'Vitamins',
      turnaround: '12 hrs',
      popular: true,
    ),
    _Test(
      name: 'Vitamin B12',
      category: 'Vitamins',
      turnaround: '12 hrs',
      popular: false,
    ),
    _Test(
      name: 'Iron Studies',
      category: 'Hematology',
      turnaround: '8 hrs',
      popular: false,
    ),
    _Test(
      name: 'Urine Routine',
      category: 'Urinalysis',
      turnaround: '3 hrs',
      popular: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final filtered = _tests
        .where(
          (t) =>
              _searchQuery.isEmpty ||
              t.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: AppColors.textMid,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lab Tests',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GradientHeader(
                emoji: Icons.science_outlined,
                title: 'Book Lab Tests',
                subtitle: '500+ tests from 300+ NABL-accredited labs',
              ),
              const SizedBox(height: 24),

              // Search
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search lab tests…',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSoft,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.textSoft,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Test list
              Text(
                'Individual Tests',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),
              ...filtered.asMap().entries.map(
                (entry) => _TestTile(
                  test: entry.value,
                  index: entry.key,
                  isSelected: _selectedTests.contains(entry.key),
                  onToggle: () => setState(() {
                    if (_selectedTests.contains(entry.key))
                      _selectedTests.remove(entry.key);
                    else
                      _selectedTests.add(entry.key);
                  }),
                ),
              ),

              if (_selectedTests.isNotEmpty) ...[
                const SizedBox(height: 20),
                _SelectedSummary(
                  count: _selectedTests.length,
                  onBook: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${_selectedTests.length} tests booked!',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                        backgroundColor: const Color(0xFF4ADE80),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    setState(() => _selectedTests.clear());
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Test {
  final String name, category, turnaround;
  final bool popular;
  const _Test({
    required this.name,
    required this.category,
    required this.turnaround,
    required this.popular,
  });
}

class _GradientHeader extends StatelessWidget {
  final IconData emoji;
  final String title, subtitle;
  const _GradientHeader({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navy, Color(0xFF1A2C4A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(child: Icon(emoji, size: 30, color: Colors.white)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TestTile extends StatefulWidget {
  final _Test test;
  final int index;
  final bool isSelected;
  final VoidCallback onToggle;
  const _TestTile({
    required this.test,
    required this.index,
    required this.isSelected,
    required this.onToggle,
  });
  @override
  State<_TestTile> createState() => _TestTileState();
}

class _TestTileState extends State<_TestTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final t = widget.test;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.blueLight : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.blue
                  : _hovered
                  ? AppColors.blue.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.science_outlined,
                    size: 22,
                    color: AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (t.popular)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Popular',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          t.category,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: AppColors.textSoft,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textSoft,
                        ),
                        Text(
                          ' ${t.turnaround}',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: AppColors.textSoft,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.blue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.blue
                        : AppColors.border,
                    width: 2,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedSummary extends StatelessWidget {
  final int count;
  final VoidCallback onBook;
  const _SelectedSummary({required this.count, required this.onBook});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.blue, AppColors.blueMid]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count test${count > 1 ? 's' : ''} selected',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Choose a lab to continue',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onBook,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Book Now',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
