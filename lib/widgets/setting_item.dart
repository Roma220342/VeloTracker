import 'package:flutter/material.dart';
import 'package:velotracker/theme/app_theme.dart';

class SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingItem({
    super.key,
    required this.icon,
    this.iconColor = primaryColor,
    this.iconBgColor = primaryContainerColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          // 1. ІКОНКА В КОЛІ
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),

          // 2. ТЕКСТ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? errorColor : textPrimaryColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: textSecondaryColor,
                    ),
                  ),
              ],
            ),
          ),

          // 3. ПРАВА ЧАСТИНА (Switch або текст)
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}