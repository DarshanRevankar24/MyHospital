import 'dart:convert';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});
  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  bool _showAddForm = false;

  final _members = <_FamilyMemberData>[
    _FamilyMemberData(name: 'Sarah Doe', relation: 'Spouse', phone: '+91 98765 43210', docAccess: true, avatar: 'SD', color: Color(0xFF9333EA)),
    _FamilyMemberData(name: 'Tommy Doe', relation: 'Child', phone: '+91 98765 43211', docAccess: true, avatar: 'TD', color: Color(0xFF3B82F6)),
    _FamilyMemberData(name: 'Mary Doe', relation: 'Parent', phone: '+91 98765 43212', docAccess: false, avatar: 'MD', color: Color(0xFFF59E0B)),
  ];

  final _requests = <_RequestData>[
    _RequestData(name: 'Robert Doe', relation: 'Sibling', message: 'Hey, please add me to the family!', isIncoming: true),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  Future<void> _createQrInvite() async {
    var relation = 'spouse';
    final selectedRelation = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Create family invite'),
          content: DropdownButtonFormField<String>(
            initialValue: relation,
            decoration: const InputDecoration(labelText: 'Relationship'),
            items: const [
              'spouse',
              'parent',
              'child',
              'sibling',
              'grandparent',
              'grandchild',
              'other',
            ].map((value) => DropdownMenuItem(
              value: value,
              child: Text(value[0].toUpperCase() + value.substring(1)),
            )).toList(),
            onChanged: (value) {
              if (value != null) setDialogState(() => relation = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, relation),
              child: const Text('Create QR'),
            ),
          ],
        ),
      ),
    );
    if (selectedRelation == null) return;

    try {
      final invite = await ApiService.createFamilyQrInvite(selectedRelation);
      final qrCode = invite['qr_code'];
      if (qrCode is! String || !qrCode.startsWith('data:image/png;base64,')) {
        throw const FormatException('The server returned an invalid QR image.');
      }
      final qrBytes = base64Decode(qrCode.substring(qrCode.indexOf(',') + 1));
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Share this family invite'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(qrBytes, width: 220, height: 220),
              const SizedBox(height: 12),
              const Text(
                'Ask the other person to scan this QR code while signed in. '
                'It can only be used once.',
                textAlign: TextAlign.center,
              ),
              if (invite['expires_at'] != null) ...[
                const SizedBox(height: 8),
                Text('Expires: ${invite['expires_at']}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (error) {
      _showMessage('Could not create invite: $error');
    }
  }

  Future<void> _redeemQrInvite() async {
    final tokenController = TextEditingController();
    final tokenOrScan = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Redeem family invite'),
        content: TextField(
          controller: tokenController,
          minLines: 1,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Invite token',
            hintText: 'Paste a token or scan a QR code',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          if (_supportsQrScanning)
            TextButton.icon(
              onPressed: () =>
                  Navigator.pop(dialogContext, '__SCAN_FAMILY_QR__'),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, tokenController.text),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
    tokenController.dispose();
    final token = tokenOrScan == '__SCAN_FAMILY_QR__'
        ? await _scanFamilyInvite()
        : tokenOrScan;
    final normalizedToken = token?.trim();
    if (normalizedToken == null || normalizedToken.isEmpty) return;
    if (normalizedToken.length < 32 || normalizedToken.length > 128) {
      _showMessage('Enter a valid family invite token.');
      return;
    }

    try {
      await ApiService.redeemFamilyQrInvite(normalizedToken);
      _showMessage('Family invite redeemed successfully.');
    } catch (error) {
      _showMessage('Could not redeem invite: $error');
    }
  }

  bool get _supportsQrScanning =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<String?> _scanFamilyInvite() {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Scan family invite'),
        content: SizedBox(
          width: 320,
          height: 320,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MobileScanner(
              onDetect: (capture) {
                if (capture.barcodes.isEmpty) return;
                final value = capture.barcodes.first.rawValue?.trim();
                if (value == null || value.isEmpty) return;
                Navigator.pop(dialogContext, value);
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 18), color: AppColors.textMid, onPressed: () => Navigator.pop(context)),
        title: Text('Family', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12), child: IconButton(
            icon: Icon(_showAddForm ? Icons.close : Icons.person_add_outlined, color: AppColors.blue),
            onPressed: () => setState(() => _showAddForm = !_showAddForm),
          )),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.border)),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF7B1FA2)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF4A148C).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Row(children: [
                Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                  child: const Center(
                    child: Icon(
                      Icons.family_restroom_rounded,
                      size: 30,
                      color: Colors.white,
                    ),
                  )),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Family Hub', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('${_members.length} connected · manage access & medications', style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
                ])),
              ]),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _createQrInvite,
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Create QR invite'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _redeemQrInvite,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Redeem invite'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add form
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _AddFamilyForm(onSend: (name) {
                setState(() {
                  _showAddForm = false;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Request sent to $name!', style: GoogleFonts.inter(color: Colors.white)),
                    backgroundColor: const Color(0xFF4ADE80), behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                });
              }),
              crossFadeState: _showAddForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            if (_showAddForm) const SizedBox(height: 20),

            // Pending requests
            if (_requests.isNotEmpty) ...[
              Text('Pending Requests', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              const SizedBox(height: 12),
              ..._requests.map((r) => _RequestCard(
                request: r,
                onAccept: () => setState(() {
                  _requests.remove(r);
                  _members.add(_FamilyMemberData(name: r.name, relation: r.relation, phone: '', docAccess: true, avatar: r.name.split(' ').map((w) => w[0]).join(), color: const Color(0xFF059669)));
                }),
                onReject: () => setState(() => _requests.remove(r)),
              )),
              const SizedBox(height: 24),
            ],

            // Connected members
            Text('Connected Family', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 14),
            ..._members.map((m) => _FamilyCard(
              member: m,
              onToggleAccess: () => setState(() => m.docAccess = !m.docAccess),
              onRemove: () => setState(() => _members.remove(m)),
            )),
          ]),
        ),
      ),
    );
  }
}

class _FamilyMemberData {
  final String name, relation, phone, avatar;
  final Color color;
  bool docAccess;
  _FamilyMemberData({required this.name, required this.relation, required this.phone, required this.docAccess, required this.avatar, required this.color});
}

class _RequestData {
  final String name, relation;
  final String? message;
  final bool isIncoming;
  _RequestData({required this.name, required this.relation, this.message, required this.isIncoming});
}

class _FamilyCard extends StatefulWidget {
  final _FamilyMemberData member;
  final VoidCallback onToggleAccess, onRemove;
  const _FamilyCard({required this.member, required this.onToggleAccess, required this.onRemove});
  @override
  State<_FamilyCard> createState() => _FamilyCardState();
}

class _FamilyCardState extends State<_FamilyCard> {
  bool _hovered = false;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _hovered ? m.color.withValues(alpha: 0.3) : AppColors.border),
          boxShadow: _hovered ? [BoxShadow(color: m.color.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6))] : [],
        ),
        child: Column(children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [m.color, m.color.withValues(alpha: 0.7)]), shape: BoxShape.circle),
                child: Center(child: Text(m.avatar, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: m.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(m.relation, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: m.color)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: m.docAccess ? const Color(0xFFEDF7ED) : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          m.docAccess ? Icons.lock_open : Icons.lock_outline,
                          size: 12,
                          color: m.docAccess
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFE65100),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          m.docAccess ? 'Doc Access' : 'Restricted',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: m.docAccess
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ])),
              AnimatedRotation(turns: _expanded ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSoft)),
            ]),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(children: [
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _ActionButton(label: m.docAccess ? 'Revoke Access' : 'Grant Access', icon: m.docAccess ? Icons.lock_outline : Icons.lock_open, color: const Color(0xFFF59E0B), onTap: widget.onToggleAccess)),
                  const SizedBox(width: 10),
                  Expanded(child: _ActionButton(label: 'View Records', icon: Icons.description_outlined, color: AppColors.blue, onTap: () {})),
                  const SizedBox(width: 10),
                  Expanded(child: _ActionButton(label: 'Medications', icon: Icons.medication_outlined, color: const Color(0xFF9333EA), onTap: () {})),
                ]),
                const SizedBox(height: 10),
                _ActionButton(label: 'Remove from Family', icon: Icons.person_remove_outlined, color: AppColors.accent, onTap: widget.onRemove),
              ]),
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ]),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});
  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withValues(alpha: 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.color.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(widget.icon, size: 14, color: widget.color),
            const SizedBox(width: 6),
            Text(widget.label, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: widget.color)),
          ]),
        ),
      ),
    );
  }
}

class _RequestCard extends StatefulWidget {
  final _RequestData request;
  final VoidCallback onAccept, onReject;
  const _RequestCard({required this.request, required this.onAccept, required this.onReject});
  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFFFF8E1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)]), shape: BoxShape.circle),
            child: Center(child: Text(r.name.split(' ').map((w) => w[0]).join(), style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            Text('${r.relation} · ${r.isIncoming ? "wants to connect" : "request sent"}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
            if (r.message != null) ...[
              const SizedBox(height: 4),
              Text('"${r.message}"', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMid, fontStyle: FontStyle.italic)),
            ],
          ])),
          if (r.isIncoming) ...[
            _MiniActionBtn(icon: Icons.check, color: const Color(0xFF4ADE80), onTap: widget.onAccept),
            const SizedBox(width: 8),
            _MiniActionBtn(icon: Icons.close, color: AppColors.accent, onTap: widget.onReject),
          ],
        ]),
      ),
    );
  }
}

class _MiniActionBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MiniActionBtn({required this.icon, required this.color, required this.onTap});
  @override
  State<_MiniActionBtn> createState() => _MiniActionBtnState();
}

class _MiniActionBtnState extends State<_MiniActionBtn> {
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
          duration: const Duration(milliseconds: 150),
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: _hovered ? widget.color : widget.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, size: 16, color: _hovered ? Colors.white : widget.color),
        ),
      ),
    );
  }
}

class _AddFamilyForm extends StatefulWidget {
  final ValueChanged<String> onSend;
  const _AddFamilyForm({required this.onSend});
  @override
  State<_AddFamilyForm> createState() => _AddFamilyFormState();
}

class _AddFamilyFormState extends State<_AddFamilyForm> {
  final _idCtrl = TextEditingController();
  String _relation = 'spouse';

  @override
  void dispose() { _idCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF9333EA).withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Send Connection Request', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 16),
        TextField(
          controller: _idCtrl, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            labelText: 'Username or Phone Number', labelStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textSoft),
            prefixIcon: const Icon(Icons.person_search_outlined, size: 18, color: AppColors.textSoft),
            filled: true, fillColor: AppColors.bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9333EA), width: 1.5)),
          ),
        ),
        const SizedBox(height: 12),
        Text('Relationship', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSoft)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: ['spouse', 'parent', 'child', 'sibling', 'grandparent', 'other'].map((r) {
          final active = r == _relation;
          return GestureDetector(
            onTap: () => setState(() => _relation = r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF9333EA) : AppColors.bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? const Color(0xFF9333EA) : AppColors.border),
              ),
              child: Text(r[0].toUpperCase() + r.substring(1), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textMid)),
            ),
          );
        }).toList()),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () { if (_idCtrl.text.isNotEmpty) widget.onSend(_idCtrl.text); },
          child: Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF9333EA)]), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text('Send Request', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
          ),
        ),
      ]),
    );
  }
}
