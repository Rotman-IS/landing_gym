import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class Navbar extends StatelessWidget {
  final void Function(String section)? onSectionTap;

  const Navbar({super.key, this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: AppTheme.darker,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 48,
        vertical: 12,
      ),
      child: Row(
        children: [
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          if (isMobile)
            _MobileMenu(onSectionTap: onSectionTap)
          else
            ...AppConstants.navLinks.map(
              (link) => _NavLink(
                label: link['label']!,
                onTap: () => onSectionTap?.call(link['section']!),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _MobileMenu extends StatefulWidget {
  final void Function(String section)? onSectionTap;

  const _MobileMenu({this.onSectionTap});

  @override
  State<_MobileMenu> createState() => _MobileMenuState();
}

class _MobileMenuState extends State<_MobileMenu> {
  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darker,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppConstants.navLinks.map(
              (link) => ListTile(
                title: Text(
                  link['label']!,
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onSectionTap?.call(link['section']!);
                },
              ),
            ).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu, color: AppTheme.textPrimary),
      onPressed: _openMenu,
    );
  }
}
