import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});
  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  String _searchQuery = '';
  final Map<int, int> _cart = {}; // index -> quantity

  static const _medicines = [
    _Med(name: 'Metformin 500mg', brand: 'Glycomet', form: 'Tablet', price: 85, mrp: 120, inStock: true),
    _Med(name: 'Atorvastatin 20mg', brand: 'Atorva', form: 'Tablet', price: 145, mrp: 200, inStock: true),
    _Med(name: 'Amlodipine 5mg', brand: 'Amlong', form: 'Tablet', price: 65, mrp: 90, inStock: true),
    _Med(name: 'Pantoprazole 40mg', brand: 'Pan-D', form: 'Capsule', price: 95, mrp: 140, inStock: true),
    _Med(name: 'Cetirizine 10mg', brand: 'Cetzine', form: 'Tablet', price: 35, mrp: 50, inStock: false),
    _Med(name: 'Azithromycin 500mg', brand: 'Azithral', form: 'Tablet', price: 180, mrp: 250, inStock: true),
    _Med(name: 'Paracetamol 650mg', brand: 'Dolo', form: 'Tablet', price: 28, mrp: 35, inStock: true),
    _Med(name: 'Vitamin D3 60K', brand: 'D-Rise', form: 'Capsule', price: 120, mrp: 160, inStock: true),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  int get _cartTotal => _cart.entries.fold(0, (sum, e) => sum + _medicines[e.key].price * e.value);
  int get _cartCount => _cart.values.fold(0, (sum, v) => sum + v);

  Future<void> _openPrescriptionUpload() async {
    if (!kIsWeb) {
      final result = await AuthService().confirmIdentity(
        reason: 'Authenticate before accessing prescription services',
      );
      if (result != AuthResult.success) {
        if (mounted) {
          final message = switch (result) {
            AuthResult.unavailable => 'Set up device biometrics or a screen lock to continue.',
            AuthResult.lockedOut => 'Device authentication is locked. Try again later.',
            AuthResult.cancelled => 'Authentication was cancelled.',
            AuthResult.error => 'Could not authenticate. Please try again.',
            AuthResult.success => '',
          };
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Prescription upload'),
        content: const Text('Prescription uploads are not available yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final filtered = _medicines.where((m) =>
        _searchQuery.isEmpty || m.name.toLowerCase().contains(_searchQuery.toLowerCase()) || m.brand.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), color: AppColors.textMid, onPressed: () => Navigator.pop(context)),
        title: Text('Pharmacy', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        actions: [
          if (_cartCount > 0) Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.shopping_cart_outlined, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text('$_cartCount · ₹$_cartTotal', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            )),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _GradientHeader(emoji: '💊', title: 'Order Medicines', subtitle: 'Genuine medicines from 200+ partner pharmacies'),
            const SizedBox(height: 24),

            // Upload Prescription banner
            _UploadBanner(onTap: _openPrescriptionUpload),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Search medicines by name or brand…', hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textSoft),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSoft),
                  border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            ...filtered.asMap().entries.map((e) {
              final idx = _medicines.indexOf(e.value);
              return _MedicineCard(
                med: e.value,
                quantity: _cart[idx] ?? 0,
                onAdd: () => setState(() => _cart[idx] = (_cart[idx] ?? 0) + 1),
                onRemove: () => setState(() {
                  if ((_cart[idx] ?? 0) > 1) _cart[idx] = _cart[idx]! - 1;
                  else _cart.remove(idx);
                }),
              );
            }),

            if (_cartCount > 0) ...[
              const SizedBox(height: 20),
              _CartSummary(
                count: _cartCount,
                total: _cartTotal,
                onCheckout: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('✅ Order placed! Delivery in 2 hours', style: GoogleFonts.inter(color: Colors.white)),
                    backgroundColor: const Color(0xFF4ADE80),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                  setState(() => _cart.clear());
                },
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

class _Med {
  final String name, brand, form;
  final int price, mrp;
  final bool inStock;
  const _Med({required this.name, required this.brand, required this.form, required this.price, required this.mrp, required this.inStock});
}

class _GradientHeader extends StatelessWidget {
  final String emoji, title, subtitle;
  const _GradientHeader({required this.emoji, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.navyDark, AppColors.navy, Color(0xFF1A2C4A)]),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: AppColors.navy.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: Row(children: [
      Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28)))),
      const SizedBox(width: 20),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
      ])),
    ]),
  );
}

class _UploadBanner extends StatefulWidget {
  final VoidCallback onTap;

  const _UploadBanner({required this.onTap});

  @override
  State<_UploadBanner> createState() => _UploadBannerState();
}

class _UploadBannerState extends State<_UploadBanner> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.blueLight : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hovered ? AppColors.blue.withValues(alpha: 0.3) : AppColors.border, style: BorderStyle.solid),
          ),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('📋', style: TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Upload Prescription', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              Text('Upload your prescription and we\'ll prepare your order', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.blue, AppColors.blueMid]), borderRadius: BorderRadius.circular(10)),
              child: Text('Upload', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ]),
        ),
      ),
    );
  }
}

class _MedicineCard extends StatefulWidget {
  final _Med med;
  final int quantity;
  final VoidCallback onAdd, onRemove;
  const _MedicineCard({required this.med, required this.quantity, required this.onAdd, required this.onRemove});
  @override
  State<_MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends State<_MedicineCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final m = widget.med;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.quantity > 0 ? AppColors.blueLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: widget.quantity > 0 ? AppColors.blue.withValues(alpha: 0.3) : _hovered ? AppColors.blue.withValues(alpha: 0.2) : AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('💊', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            Row(children: [
              Text('${m.brand} · ${m.form}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
              if (!m.inStock) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(6)),
                  child: Text('Out of stock', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.accent)),
                ),
              ],
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              Text('₹${m.price}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(width: 6),
              Text('₹${m.mrp}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft, decoration: TextDecoration.lineThrough, decorationColor: AppColors.textSoft)),
            ]),
            const SizedBox(height: 6),
            if (m.inStock)
              widget.quantity > 0
                  ? _QuantityControl(quantity: widget.quantity, onAdd: widget.onAdd, onRemove: widget.onRemove)
                  : GestureDetector(
                      onTap: widget.onAdd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(8)),
                        child: Text('Add', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
          ]),
        ]),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd, onRemove;
  const _QuantityControl({required this.quantity, required this.onAdd, required this.onRemove});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(onTap: onRemove, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.remove, size: 14, color: Colors.white))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('$quantity', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
        GestureDetector(onTap: onAdd, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.add, size: 14, color: Colors.white))),
      ]),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int count, total;
  final VoidCallback onCheckout;
  const _CartSummary({required this.count, required this.total, required this.onCheckout});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.blue, AppColors.blueMid]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$count item${count > 1 ? 's' : ''} in cart', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          Text('Total: ₹$total', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          Text('Free delivery on orders above ₹299', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54)),
        ])),
        GestureDetector(
          onTap: onCheckout,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text('Checkout', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.blue)),
          ),
        ),
      ]),
    );
  }
}
