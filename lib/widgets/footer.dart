import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: AppTheme.darker,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: 40,
      ),
      child: Column(
        children: [
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          if (isMobile) ...[
            const _InfoRow(icon: Icons.phone, text: AppConstants.phone),
            const SizedBox(height: 8),
            const _InfoRow(icon: Icons.email, text: AppConstants.email),
            const SizedBox(height: 8),
            const _InfoRow(icon: Icons.location_on, text: AppConstants.address),
          ] else
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoRow(icon: Icons.phone, text: AppConstants.phone),
                SizedBox(width: 32),
                _InfoRow(icon: Icons.email, text: AppConstants.email),
                SizedBox(width: 32),
                _InfoRow(icon: Icons.location_on, text: AppConstants.address),
              ],
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(
                icon: Icons.camera_alt,
                url: AppConstants.socialLinks['instagram']!,
              ),
              const SizedBox(width: 16),
              _SocialIcon(
                icon: Icons.facebook,
                url: AppConstants.socialLinks['facebook']!,
              ),
              const SizedBox(width: 16),
              _SocialIcon(
                icon: Icons.alternate_email,
                url: AppConstants.socialLinks['twitter']!,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            '© ${DateTime.now().year} ${AppConstants.appName}. Todos los derechos reservados.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String url;

  const _SocialIcon({required this.icon, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.5),
          ),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
    );
  }
}
