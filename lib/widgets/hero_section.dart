import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  /// Claves de las dos regiones de la composicion. Permiten verificar en test
  /// que en desktop sus rectangulos no se intersecan.
  static const Key textKey = Key('hero_text');
  static const Key bannerKey = Key('hero_banner');

  // Reparto vertical en desktop: el texto ocupa la banda superior y la imagen
  // la inferior. Proporcional, nunca en pixeles fijos, para que la relacion se
  // mantenga entre un portatil de 768 px de alto y un monitor de 1440.
  static const int _textFlex = 3;
  static const int _bannerFlex = 7;

  /// Relacion de aspecto del bitmap (1200 x 896). Fijarla en un AspectRatio
  /// hace que la caja del widget coincida exactamente con la imagen pintada,
  /// requisito para que la mascara de difuminado se alinee con sus bordes.
  static const double _bannerAspectRatio = 1200 / 896;

  // El fondo del bitmap no es negro puro, sino un azul-gris texturizado: su
  // borde recto se recorta contra la seccion. Estas mascaras lo disuelven.
  // Los margenes de difuminado son estrechos a proposito: las tarjetas de
  // metrica arrancan al 7% del ancho y al 12% del alto, y no deben perderse.
  static const LinearGradient _sideFade = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0x00FFFFFF),
      Color(0xFFFFFFFF),
      Color(0xFFFFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: [0.0, 0.07, 0.93, 1.0],
  );

  static const LinearGradient _topFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
    stops: [0.0, 0.09],
  );

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: isMobile ? size.height * 0.7 : size.height * 0.85,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.darker, AppTheme.dark, AppTheme.surface],
        ),
      ),
      child: Stack(
        children: [
          // El ornamento se pinta primero: nunca por encima de la fotografia.
          Positioned(
            right: -100,
            top: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.glow,
              ),
            ),
          ),
          Positioned.fill(
            child: isMobile ? _buildMobile(context) : _buildDesktop(context),
          ),
        ],
      ),
    );
  }

  /// Desktop: dos regiones hermanas dentro de una Column. El no-solapamiento
  /// entre texto e imagen es estructural, no depende de paddings calculados.
  Widget _buildDesktop(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: _textFlex,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // scaleDown absorbe el desbordamiento vertical en viewports
                  // bajos sin romper el reparto proporcional de la Column. El
                  // SizedBox le fija la anchura disponible: sin el, FittedBox
                  // pasaria restricciones infinitas y el texto no haria wrap.
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: _textBlock(context, isMobile: false),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          flex: _bannerFlex,
          child: DecoratedBox(
            // La imagen se muestra completa, asi que a los lados sobra
            // espacio: se cubre con darker. La franja superior funde el
            // gradiente de la seccion con esa cama oscura.
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.scrimClear, AppTheme.darker],
                stops: const [0.0, 0.18],
              ),
            ),
            // El AspectRatio reproduce el encaje de BoxFit.contain (la caja
            // mas grande con la relacion del bitmap que cabe en la banda) y
            // ademas hace que los limites del widget sean los de la imagen,
            // que es lo que las mascaras necesitan para alinearse.
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AspectRatio(
                aspectRatio: _bannerAspectRatio,
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: _sideFade.createShader,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: _topFade.createShader,
                    // contain, nunca cover: la banda es mucho mas ancha que
                    // alta y un recorte eliminaria las cuatro tarjetas de
                    // metrica de las esquinas del bitmap.
                    child: _banner(
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Movil: no hay altura para separar bandas, asi que la imagen va a sangre
  /// y el texto se superpone sobre un scrim que garantiza su legibilidad.
  Widget _buildMobile(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // cover con recorte centrado: se pierden las tarjetas laterales, se
        // conservan los atletas, que son el sujeto.
        _banner(fit: BoxFit.cover, alignment: Alignment.center),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.scrimDense,
                AppTheme.scrimDense,
                AppTheme.scrimClear,
              ],
              stops: const [0.0, 0.62, 1.0],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _textBlock(context, isMobile: true),
          ),
        ),
      ],
    );
  }

  Widget _textBlock(BuildContext context, {required bool isMobile}) {
    return Column(
      key: textKey,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppConstants.tagline,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: isMobile ? 32 : 48,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          AppConstants.heroSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: isMobile ? 16 : 18,
              ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {},
          child: const Text(AppConstants.ctaText),
        ),
      ],
    );
  }

  Widget _banner({required BoxFit fit, required Alignment alignment}) {
    return Image.asset(
      AppConstants.heroBannerAsset,
      key: bannerKey,
      fit: fit,
      alignment: alignment,
      filterQuality: FilterQuality.medium,
      // Decorativa: el mensaje ya esta en el tagline y el subtitulo.
      excludeFromSemantics: true,
      // Si el asset falta o no decodifica, la seccion se queda con su
      // gradiente y su texto en lugar de mostrar un hueco roto.
      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
