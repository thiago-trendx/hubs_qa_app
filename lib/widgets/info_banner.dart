import 'package:flutter/material.dart';

/// Small colored strip used for availability/permission notices across the
/// write tabs (metric, sono, treino) — one widget so the three screens don't
/// each reimplement the same banner.
class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.color, required this.icon, required this.message, this.action});

  final Color color;
  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: color))),
          if (action != null) action!,
        ],
      ),
    );
  }
}
