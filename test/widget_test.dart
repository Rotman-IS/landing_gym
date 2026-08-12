import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:basic_landing/main.dart';
import 'package:basic_landing/screens/landing_screen.dart';
import 'package:basic_landing/theme/app_theme.dart';
import 'package:basic_landing/utils/constants.dart';
import 'package:basic_landing/widgets/features_section.dart';
import 'package:basic_landing/widgets/hero_section.dart';
import 'package:basic_landing/widgets/navbar.dart';

/// El viewport por defecto de flutter_test es 800 x 600, que cae siempre en la
/// rama desktop del hero. Fijar el tamano explicitamente es la unica forma de
/// ejercitar ambos breakpoints.
void setSurface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Bundle que falla en toda carga, para ejercitar la degradacion del hero
/// cuando el asset no esta disponible.
class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    throw FlutterError('asset no disponible: $key');
  }
}

/// Monta el hero aislado. Las pruebas de esta capability no montan la landing
/// completa a proposito: navbar y footer tienen desbordamientos de layout
/// preexistentes que harian fallar cualquier test por motivos ajenos al hero.
Future<void> pumpHero(WidgetTester tester, {AssetBundle? bundle}) async {
  final Widget app = MaterialApp(
    theme: AppTheme.darkTheme,
    home: const Scaffold(body: SingleChildScrollView(child: HeroSection())),
  );
  await tester.pumpWidget(
    bundle == null ? app : DefaultAssetBundle(bundle: bundle, child: app),
  );
}

/// Monta la seccion de features aislada, por el mismo motivo que `pumpHero`:
/// los desbordamientos del navbar y del footer son ajenos a esta capability.
///
/// [textScaler] permite forzar un contenido mas alto sin tocar el copy de
/// `AppConstants`, que es `const` y no se puede sustituir desde una prueba.
Future<void> pumpFeatures(WidgetTester tester, {TextScaler? textScaler}) async {
  const Widget section =
      Scaffold(body: SingleChildScrollView(child: FeaturesSection()));
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.darkTheme,
    home: textScaler == null
        ? section
        : Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: textScaler),
              child: section,
            ),
          ),
  ));
}

/// Rectangulos de las cuatro tarjetas, en el orden de `AppConstants.features`.
List<Rect> featureCardRects(WidgetTester tester) => List.generate(
      AppConstants.features.length,
      (i) => tester.getRect(find.byKey(FeaturesSection.cardKey(i))),
    );

/// Numero de filas de la reticula, deducido de cuantas coordenadas verticales
/// distintas ocupan las tarjetas.
int featureRowCount(WidgetTester tester) =>
    featureCardRects(tester).map((r) => r.top).toSet().length;

void main() {
  testWidgets('App renders landing screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LandingGymApp());

    expect(find.text('Iron Gym'), findsWidgets);
    expect(
        find.text('Transforma tu cuerpo, transforma tu vida'), findsOneWidget);
  });

  group('hero banner', () {
    testWidgets('desktop: texto e imagen ocupan bandas disjuntas',
        (WidgetTester tester) async {
      setSurface(tester, const Size(1440, 900));
      await pumpHero(tester);

      final textRect = tester.getRect(find.byKey(HeroSection.textKey));
      final bannerRect = tester.getRect(find.byKey(HeroSection.bannerKey));

      expect(textRect.overlaps(bannerRect), isFalse,
          reason: 'el bloque de texto no puede dibujarse sobre la imagen');
      expect(textRect.bottom, lessThanOrEqualTo(bannerRect.top),
          reason: 'el texto va en la banda superior');
    });

    testWidgets('desktop: las bandas no se solapan en un viewport bajo',
        (WidgetTester tester) async {
      setSurface(tester, const Size(1440, 700));
      await pumpHero(tester);

      final textRect = tester.getRect(find.byKey(HeroSection.textKey));
      final bannerRect = tester.getRect(find.byKey(HeroSection.bannerKey));

      expect(textRect.overlaps(bannerRect), isFalse);
    });

    testWidgets('desktop: el reparto se mantiene entre alturas de pantalla',
        (WidgetTester tester) async {
      setSurface(tester, const Size(1440, 768));
      await pumpHero(tester);
      final short = tester.getRect(find.byKey(HeroSection.bannerKey)).height /
          (768 * 0.85);

      setSurface(tester, const Size(1440, 1440));
      await pumpHero(tester);
      final tall = tester.getRect(find.byKey(HeroSection.bannerKey)).height /
          (1440 * 0.85);

      expect(short, closeTo(tall, 0.01),
          reason: 'la proporcion entre bandas no depende de la altura');
    });

    testWidgets('desktop: la imagen se muestra completa, sin recorte',
        (WidgetTester tester) async {
      setSurface(tester, const Size(1920, 1080));
      await pumpHero(tester);

      final image = tester.widget<Image>(find.byKey(HeroSection.bannerKey));
      expect(image.fit, BoxFit.contain,
          reason: 'cover recortaria las tarjetas de metrica de las esquinas');
      expect(image.alignment, Alignment.bottomCenter);
    });

    testWidgets('movil: la imagen va a sangre con recorte centrado',
        (WidgetTester tester) async {
      setSurface(tester, const Size(390, 844));
      await pumpHero(tester);

      final image = tester.widget<Image>(find.byKey(HeroSection.bannerKey));
      expect(image.fit, BoxFit.cover);
      expect(image.alignment, Alignment.center,
          reason: 'el recorte conserva a los atletas, que son el sujeto');

      final bannerRect = tester.getRect(find.byKey(HeroSection.bannerKey));
      expect(bannerRect.width, 390);
      expect(bannerRect.height, closeTo(844 * 0.7, 0.5));
    });

    testWidgets('la imagen es decorativa y no genera nodo semantico',
        (WidgetTester tester) async {
      final handle = tester.ensureSemantics();
      setSurface(tester, const Size(1440, 900));
      await pumpHero(tester);

      final image = tester.widget<Image>(find.byKey(HeroSection.bannerKey));
      expect(image.excludeFromSemantics, isTrue);

      expect(
          find.bySemanticsLabel('Transforma tu cuerpo, transforma tu vida'),
          findsOneWidget);
      expect(find.bySemanticsLabel(AppConstants.ctaText), findsWidgets);

      handle.dispose();
    });

    testWidgets('un fallo de carga del asset deja el hero con texto y CTA',
        (WidgetTester tester) async {
      setSurface(tester, const Size(1440, 900));
      await pumpHero(tester, bundle: _FailingAssetBundle());
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull,
          reason: 'el fallo de carga no puede propagarse a la pantalla');
      expect(find.text(AppConstants.tagline), findsOneWidget);
      expect(find.text(AppConstants.heroSubtitle), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, AppConstants.ctaText),
          findsOneWidget);
    });
  });

  group('reticula de features', () {
    // 1024 es el peor caso y el ancho reportado: es el piso de la rama
    // desktop, donde el ancho se reparte de golpe en 4 columnas. 1024x600 (PC
    // pequena) y 1024x1366 (iPad Pro vertical) son el mismo caso, porque la
    // seccion vive en un SingleChildScrollView y su alto de viewport no cuenta.
    const List<double> anchos = [360, 599, 600, 1023, 1024, 1280, 1920];

    testWidgets('ningun ancho desborda las tarjetas',
        (WidgetTester tester) async {
      for (final double ancho in anchos) {
        setSurface(tester, Size(ancho, 900));
        await pumpFeatures(tester);

        expect(tester.takeException(), isNull,
            reason: 'la reticula desborda a $ancho px de ancho');
      }
    });

    testWidgets('el texto completo de las tarjetas queda visible',
        (WidgetTester tester) async {
      for (final double ancho in anchos) {
        setSurface(tester, Size(ancho, 900));
        await pumpFeatures(tester);

        for (final feature in AppConstants.features) {
          expect(find.text(feature['title']!), findsOneWidget,
              reason: 'falta el titulo a $ancho px');
          expect(find.text(feature['description']!), findsOneWidget,
              reason: 'falta la descripcion a $ancho px');
        }
      }
    });

    testWidgets('el numero de columnas sigue los breakpoints',
        (WidgetTester tester) async {
      // 4 features: 1 columna -> 4 filas, 2 columnas -> 2 filas, 4 -> 1 fila.
      final Map<double, int> filasEsperadas = {
        360: 4,
        599: 4,
        600: 2,
        1023: 2,
        1024: 1,
        1920: 1,
      };

      for (final entry in filasEsperadas.entries) {
        setSurface(tester, Size(entry.key, 900));
        await pumpFeatures(tester);

        expect(featureRowCount(tester), entry.value,
            reason: 'reparto de columnas incorrecto a ${entry.key} px');
      }
    });

    testWidgets('las tarjetas de una fila comparten alto y ancho',
        (WidgetTester tester) async {
      setSurface(tester, const Size(1024, 900));
      await pumpFeatures(tester);

      final List<Rect> cards = featureCardRects(tester);

      expect(cards.map((r) => r.height).toSet(), hasLength(1),
          reason: 'las descripciones tienen distinto largo, pero las cuatro '
              'tarjetas de la fila tienen que medir lo mismo de alto');
      expect(cards.map((r) => r.bottom).toSet(), hasLength(1),
          reason: 'los bordes inferiores quedan alineados');
      expect(cards.map((r) => r.width).toSet(), hasLength(1),
          reason: 'el ancho se reparte en partes iguales');
    });

    testWidgets('a 1024 px el alto lo fija el contenido, no el ancho',
        (WidgetTester tester) async {
      setSurface(tester, const Size(1024, 900));
      await pumpFeatures(tester);

      final Rect card = featureCardRects(tester).first;

      // El bug era exactamente esto: childAspectRatio: 1 imponia alto == ancho
      // (206 px) a un contenido que necesitaba ~215. Si el alto volviera a
      // derivarse del ancho, esta comparacion se rompe.
      expect(card.height, greaterThan(card.width),
          reason: 'el contenido necesita mas alto del que daba una celda '
              'cuadrada de ${card.width.toStringAsFixed(0)} px');
    });

    testWidgets('la separacion entre tarjetas se mantiene en 24 px',
        (WidgetTester tester) async {
      setSurface(tester, const Size(1024, 900));
      await pumpFeatures(tester);
      final List<Rect> fila = featureCardRects(tester);
      expect(fila[1].left - fila[0].right, closeTo(24, 0.01));

      setSurface(tester, const Size(800, 900));
      await pumpFeatures(tester);
      final List<Rect> dosFilas = featureCardRects(tester);
      expect(dosFilas[1].left - dosFilas[0].right, closeTo(24, 0.01),
          reason: 'separacion horizontal');
      expect(dosFilas[2].top - dosFilas[0].bottom, closeTo(24, 0.01),
          reason: 'separacion vertical entre filas');
    });

    testWidgets('un contenido mas alto agranda la tarjeta en vez de desbordar',
        (WidgetTester tester) async {
      // Sustituto de "el copy crece": el texto de AppConstants es const y no
      // se puede inyectar desde una prueba, pero escalar la tipografia somete
      // al layout a la misma exigencia — mas alto de contenido en el mismo
      // ancho de columna.
      setSurface(tester, const Size(1024, 900));
      await pumpFeatures(tester);
      final double normal = featureCardRects(tester).first.height;

      await pumpFeatures(tester, textScaler: const TextScaler.linear(1.6));

      expect(tester.takeException(), isNull,
          reason: 'un contenido mas alto no puede desbordar la tarjeta');
      expect(featureCardRects(tester).first.height, greaterThan(normal),
          reason: 'la tarjeta tiene que crecer para acomodarlo');
    });
  });

  group('navegacion por secciones', () {
    test('cada link del navbar tiene una seccion registrada', () {
      // El destino no resoluble falla en silencio por diseno, asi que un
      // identificador nuevo en las constantes sin su key correspondiente
      // pasaria inadvertido en tiempo de ejecucion. Este test lo vuelve rojo.
      for (final link in AppConstants.navLinks) {
        expect(LandingScreen.sectionIds, contains(link['section']),
            reason:
                'el link "${link['label']}" apunta a "${link['section']}", '
                'que no esta registrada en LandingScreen.sectionIds');
      }
    });

    testWidgets('desktop: tocar un link desplaza la vista',
        (WidgetTester tester) async {
      // 1440 de ancho: por debajo de ~1160 el navbar y el footer desbordan
      // horizontalmente, un problema de layout preexistente y ajeno a esta
      // capability que haria fallar el test por motivos equivocados.
      setSurface(tester, const Size(1440, 900));
      await tester.pumpWidget(const LandingGymApp());
      await tester.pumpAndSettle();

      expect(landingScrollOffset(tester), 0.0,
          reason: 'la landing arranca en el tope');

      await tester.tap(navbarLink(tester, 'features'));
      await tester.pumpAndSettle();

      expect(landingScrollOffset(tester), greaterThan(0.0),
          reason: 'el tap tiene que haber desplazado la vista');
    });

    testWidgets('desktop: Inicio devuelve la vista al hero',
        (WidgetTester tester) async {
      setSurface(tester, const Size(1440, 900));
      await tester.pumpWidget(const LandingGymApp());
      await tester.pumpAndSettle();

      await tester.tap(navbarLink(tester, 'testimonials'));
      await tester.pumpAndSettle();
      expect(landingScrollOffset(tester), greaterThan(0.0));

      await tester.tap(navbarLink(tester, 'hero'));
      await tester.pumpAndSettle();

      expect(landingScrollOffset(tester), 0.0,
          reason: '"Inicio" vuelve al comienzo del hero');
    });

    testWidgets('desktop: los cuatro links llegan a secciones distintas',
        (WidgetTester tester) async {
      setSurface(tester, const Size(1440, 900));
      await tester.pumpWidget(const LandingGymApp());
      await tester.pumpAndSettle();

      final List<double> offsets = [];
      for (final link in AppConstants.navLinks) {
        await tester.tap(navbarLink(tester, link['section']!));
        await tester.pumpAndSettle();
        offsets.add(landingScrollOffset(tester));
      }

      // Las secciones se declaran en el mismo orden en que se apilan, asi que
      // cada destino queda estrictamente mas abajo que el anterior. Comparar
      // offsets distintos y crecientes descarta que varios links caigan por
      // error en el mismo lugar.
      expect(offsets.toSet(), hasLength(offsets.length),
          reason: 'dos links no pueden compartir destino');
      for (int i = 1; i < offsets.length; i++) {
        expect(offsets[i], greaterThan(offsets[i - 1]),
            reason: '"${AppConstants.navLinks[i]['label']}" tiene que quedar '
                'mas abajo que "${AppConstants.navLinks[i - 1]['label']}"');
      }
    });

    testWidgets('movil: el menu se cierra y la vista se desplaza',
        (WidgetTester tester) async {
      // 540 sigue por debajo del breakpoint de 600, asi que ejercita la rama
      // movil y su menu desplegable. Por debajo de ~450 el `_InfoRow` del
      // footer desborda: otro problema de layout preexistente que no tiene que
      // ver con la navegacion.
      setSurface(tester, const Size(540, 900));
      await tester.pumpWidget(const LandingGymApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      final String label = labelForSection('testimonials');
      expect(find.widgetWithText(ListTile, label), findsOneWidget,
          reason: 'el menu movil esta abierto');

      await tester.tap(find.widgetWithText(ListTile, label));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, label), findsNothing,
          reason: 'el menu se cierra al elegir una seccion');
      expect(landingScrollOffset(tester), greaterThan(0.0));
    });
  });
}

/// Offset del scroll de la landing. El `SingleChildScrollView` de la pantalla
/// es el primero en recorrido de profundidad, por encima de cualquier scroll
/// interno de las secciones.
double landingScrollOffset(WidgetTester tester) {
  final SingleChildScrollView scrollView = tester.widget<SingleChildScrollView>(
    find
        .descendant(
          of: find.byType(LandingScreen),
          matching: find.byType(SingleChildScrollView),
        )
        .first,
  );
  return scrollView.controller!.offset;
}

String labelForSection(String section) =>
    AppConstants.navLinks.firstWhere((l) => l['section'] == section)['label']!;

/// Acota la busqueda al navbar: las etiquetas pueden repetirse en el footer.
Finder navbarLink(WidgetTester tester, String section) => find.descendant(
      of: find.byType(Navbar),
      matching: find.text(labelForSection(section)),
    );
