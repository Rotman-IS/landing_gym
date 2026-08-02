import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: AppTheme.darker,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            'Lo que dicen nuestros miembros',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: isMobile ? 28 : 36,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Resultados reales de personas reales',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 48),
          if (isMobile)
            Column(
              children: AppConstants.testimonials
                  .map((t) => _TestimonialCard(
                        name: t['name']!,
                        text: t['text']!,
                      ))
                  .toList(),
            )
          else
            Row(
              children: AppConstants.testimonials.map((t) {
                return Expanded(
                  child: _TestimonialCard(
                    name: t['name']!,
                    text: t['text']!,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final String name;
  final String text;

  const _TestimonialCard({required this.name, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            size: 40,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
