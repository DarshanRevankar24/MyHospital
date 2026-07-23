import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.tealDark,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          // Left info items
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TopBarItem(
                    icon: Icons.location_on_outlined,
                    text: '12, MG Road, Bengaluru – 560001, Karnataka',
                  ),
                  const SizedBox(width: 24),
                  _TopBarItem(
                    icon: Icons.phone_outlined,
                    text: '+91 80 4567 8900',
                  ),
                  const SizedBox(width: 24),
                  _TopBarItem(
                    icon: Icons.access_time_outlined,
                    text: 'OPD: Mon–Sat, 8 AM – 8 PM',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right items
          _TopBarLink(text: 'Patient Portal'),
          const SizedBox(width: 16),
          _TopBarLink(text: 'Careers'),
          const SizedBox(width: 12),
          _EmergencyBadge(),
        ],
      ),
    );
  }
}

class _TopBarItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TopBarItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white70),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11.5,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _TopBarLink extends StatefulWidget {
  final String text;
  const _TopBarLink({required this.text});

  @override
  State<_TopBarLink> createState() => _TopBarLinkState();
}

class _TopBarLinkState extends State<_TopBarLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Text(
        widget.text,
        style: TextStyle(
          color: _hovered ? Colors.white : Colors.white70,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmergencyBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        '🚨  Emergency: 108',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
