import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/hero_section.dart';
import '../widgets/features_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/cta_section.dart';
import '../widgets/footer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Navbar(
              onSectionTap: (section) {
                // los offsets se pueden ajustar con GlobalKey
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: const Column(
                  children: [
                    HeroSection(),
                    FeaturesSection(),
                    TestimonialsSection(),
                    CtaSection(),
                    Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
