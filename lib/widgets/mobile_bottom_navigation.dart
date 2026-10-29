import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MobileBottomNavigation extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onScanQr;
  final VoidCallback onFamily;
  final VoidCallback onEmergency;
  final VoidCallback onBloodBank;
  final VoidCallback onDocuments;
  final VoidCallback onHistory;

  const MobileBottomNavigation({
    super.key,
    required this.onHome,
    required this.onScanQr,
    required this.onFamily,
    required this.onEmergency,
    required this.onBloodBank,
    required this.onDocuments,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 64,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 10,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          _MobileNavAction(
            icon: Icons.home_outlined,
            label: 'Home',
            onTap: onHome,
          ),
          _MobileNavAction(
            icon: Icons.qr_code_scanner_outlined,
            label: 'Scan QR',
            onTap: onScanQr,
          ),
          _MobileNavAction(
            icon: Icons.people_outline_rounded,
            label: 'Family',
            onTap: onFamily,
          ),
          _MobileNavAction(
            icon: Icons.add_rounded,
            label: 'Emergency options',
            onTap: onEmergency,
            isEmergency: true,
          ),
          _MobileNavAction(
            icon: Icons.bloodtype_outlined,
            label: 'Blood bank',
            onTap: onBloodBank,
          ),
          _MobileNavAction(
            icon: Icons.description_outlined,
            label: 'Documents',
            onTap: onDocuments,
          ),
          _MobileNavAction(
            icon: Icons.history_rounded,
            label: 'History',
            onTap: onHistory,
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
  final bool isEmergency;

  const _MobileNavAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isEmergency = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(isEmergency ? 24 : 14),
          onTap: onTap,
          child: Tooltip(
            message: label,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: isEmergency
                    ? Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 27, color: Colors.white),
                      )
                    : Icon(icon, size: 25, color: AppColors.textDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
