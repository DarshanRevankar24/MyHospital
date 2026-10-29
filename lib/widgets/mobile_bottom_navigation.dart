import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class MobileBottomNavigation extends StatelessWidget {
  final VoidCallback onScanQr;
  final VoidCallback onFamily;
  final VoidCallback onBloodBank;
  final VoidCallback onDocuments;
  final VoidCallback onHistory;

  const MobileBottomNavigation({
    super.key,
    required this.onScanQr,
    required this.onFamily,
    required this.onBloodBank,
    required this.onDocuments,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 76,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 7,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _MobileNavAction(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan QR',
              onTap: onScanQr,
            ),
          ),
          Expanded(
            child: _MobileNavAction(
              icon: Icons.people_outline_rounded,
              label: 'Family',
              onTap: onFamily,
            ),
          ),
          const SizedBox(width: 64),
          Expanded(
            child: _MobileNavAction(
              icon: Icons.bloodtype_outlined,
              label: 'Blood',
              onTap: onBloodBank,
            ),
          ),
          Expanded(
            child: _MobileNavAction(
              icon: Icons.description_outlined,
              label: 'Docs',
              onTap: onDocuments,
            ),
          ),
          Expanded(
            child: _MobileNavAction(
              icon: Icons.history_rounded,
              label: 'History',
              onTap: onHistory,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileNavAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MobileNavAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 25, color: AppColors.blue),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
