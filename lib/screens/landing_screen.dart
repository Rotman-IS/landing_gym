import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/navbar.dart';
import '../widgets/hero_section.dart';
import '../widgets/features_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/cta_section.dart';
import '../widgets/footer.dart';

/// Duracion y curva del desplazamiento entre secciones. Viven aca, y no en cada
/// llamada, para que ajustar la sensacion del scroll sea un cambio en un solo
/// lugar.
const Duration _scrollDuration = Duration(milliseconds: 600);
const Curve _scrollCurve = Curves.easeInOut;

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  /// Identificadores de las secciones navegables. Cada `section` declarada en
  /// [AppConstants.navLinks] tiene que estar aca: una que falte deja el link
  /// del navbar sin destino, y como `_scrollTo` falla en silencio a proposito,
  /// nadie se enteraria. El test de cobertura de navegacion cubre ese hueco.
  static const List<String> sectionIds = [
    'hero',
    'features',
    'testimonials',
    'cta',
  ];

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();

  /// Las `GlobalKey` no son constantes, asi que se crean una sola vez aca y no
  /// dentro de `build`: una key duplicada por rebuild romperia el arbol.
  final Map<String, GlobalKey> _sectionKeys = {
    for (final id in LandingScreen.sectionIds) id: GlobalKey(),
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Desplaza hasta la seccion pedida, alineandola al borde superior del area
  /// desplazable. El navbar vive fuera del scroll, asi que no hay altura que
  /// compensar.
  ///
  /// Ignora en silencio los destinos que no puede resolver: en una landing
  /// estatica el unico caso real es un identificador mal escrito, y un tap sin
  /// efecto es preferible a una excepcion en produccion.
  void _scrollTo(String section) {
    final BuildContext? sectionContext = _sectionKeys[section]?.currentContext;
    if (sectionContext == null) return;

    Scrollable.ensureVisible(
      sectionContext,
      alignment: 0.0,
      duration: _scrollDuration,
      curve: _scrollCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Navbar(onSectionTap: _scrollTo),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                // `KeyedSubtree` sostiene la key de navegacion para que cada
                // seccion conserve su constructor `const`.
                child: Column(
                  children: [
                    KeyedSubtree(
                      key: _sectionKeys['hero'],
                      child: const HeroSection(),
                    ),
                    KeyedSubtree(
                      key: _sectionKeys['features'],
                      child: const FeaturesSection(),
                    ),
                    KeyedSubtree(
                      key: _sectionKeys['testimonials'],
                      child: const TestimonialsSection(),
                    ),
                    KeyedSubtree(
                      key: _sectionKeys['cta'],
                      child: const CtaSection(),
                    ),
                    const Footer(),
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
