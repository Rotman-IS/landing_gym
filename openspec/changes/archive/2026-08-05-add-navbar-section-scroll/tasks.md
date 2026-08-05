## 1. Convertir LandingScreen a StatefulWidget

- [x] 1.1 Convertir `LandingScreen` de `StatelessWidget` a `StatefulWidget` en [lib/screens/landing_screen.dart](lib/screens/landing_screen.dart), manteniendo el árbol de widgets renderizado idéntico
- [x] 1.2 Mover la creación del `ScrollController` de `build()` a un campo `final` del `State` inicializado en `initState`
- [x] 1.3 Liberar el `ScrollController` en `dispose()`
- [x] 1.4 Verificar con `flutter test` que la landing sigue renderizando y con `flutter analyze` que no hay warnings nuevos

## 2. Registrar las secciones navegables

- [x] 2.1 Declarar en el `State` un campo `final Map<String, GlobalKey>` con una entrada por cada identificador de `AppConstants.navLinks`: `hero`, `features`, `testimonials`, `cta`
- [x] 2.2 Envolver `HeroSection`, `FeaturesSection`, `TestimonialsSection` y `CtaSection` en `KeyedSubtree` con su key correspondiente, conservando el constructor `const` de cada sección
- [x] 2.3 Quitar el `const` del `Column` contenedor de secciones y dejar `Footer` sin key

## 3. Implementar el desplazamiento

- [x] 3.1 Escribir el método `_scrollTo(String section)` que resuelve la key en el mapa y obtiene su `currentContext`
- [x] 3.2 Retornar sin efecto cuando la key no existe o el `currentContext` es nulo, sin lanzar excepción
- [x] 3.3 Llamar a `Scrollable.ensureVisible` con `alignment: 0.0`, duración y curva de animación definidas como constantes del archivo
- [x] 3.4 Conectar `_scrollTo` al parámetro `onSectionTap` del `Navbar`, reemplazando el handler vacío actual

## 4. Verificación

- [x] 4.1 Agregar un test que recorra `AppConstants.navLinks` y verifique que cada identificador de sección tiene una key registrada en el mapa, para que una constante nueva sin destino falle en rojo
- [x] 4.2 Agregar un test de widget que, en viewport desktop, haga tap en un link del navbar y verifique que la posición de scroll cambió
- [x] 4.3 Agregar un test de widget que, en viewport mobile (ancho menor a 600), abra el menú, haga tap en un link y verifique que el menú se cierra y la posición de scroll cambió
- [ ] 4.4 Verificar manualmente con `flutter run -d chrome` que los cuatro links desplazan a la sección correcta y que "Inicio" regresa al hero — **pendiente del usuario**; cubierto automáticamente por el test "los cuatro links llegan a secciones distintas", que recorre las cuatro entradas de `navLinks` y verifica destinos distintos y crecientes
- [x] 4.5 Ejecutar `flutter analyze` y `flutter test` y confirmar que ambos pasan limpios — `analyze` limpio; `test` da 12 verdes y 1 rojo **pre-existente** (`App renders landing screen`), verificado como fallo previo a este cambio
