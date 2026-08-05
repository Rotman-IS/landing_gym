## Why

Los links del navbar ("Inicio", "Servicios", "Testimonios", "Contacto") ya emiten el callback `onSectionTap`, pero el handler en `landing_screen.dart:21` está vacío: hacer click no lleva a ninguna parte. En una landing de una sola página, la navegación por secciones es la única navegación que existe, así que hoy el navbar es decorativo.

## What Changes

- `LandingScreen` pasa de `StatelessWidget` a `StatefulWidget` para poder sostener estado de scroll entre rebuilds.
- Se agrega un mapa `Map<String, GlobalKey>` cuyas claves son exactamente los identificadores de `AppConstants.navLinks` (`hero`, `features`, `testimonials`, `cta`).
- Cada sección navegable se envuelve en un `KeyedSubtree` con su `GlobalKey`, preservando el `const` de los widgets de sección.
- `onSectionTap` se implementa resolviendo `section → GlobalKey → BuildContext` y llamando a `Scrollable.ensureVisible` con animación y `alignment: 0.0` (la sección queda alineada al tope del viewport).
- Si la clave no existe o el contexto todavía no está montado, el tap se ignora sin lanzar excepción.
- Bonus de higiene: el `ScrollController` deja de crearse dentro de `build()` y pasa a `initState`/`dispose`, cerrando la fuga actual en `landing_screen.dart:14`.

Sin cambios en `navbar.dart`, `constants.dart` ni en los widgets de sección — el contrato `onSectionTap(String)` ya existente se respeta tal cual, tanto en el camino desktop (`_NavLink`) como en el mobile (`_MobileMenu`).

## Capabilities

### New Capabilities
- `navbar-section-navigation`: navegación por scroll animado desde los links del navbar hacia cada sección del landing, en desktop y mobile.

### Modified Capabilities
<!-- Ninguna: no existen specs previas en openspec/specs/. -->

## Impact

- **Código afectado**: [lib/screens/landing_screen.dart](lib/screens/landing_screen.dart) (único archivo modificado).
- **Dependencias**: ninguna nueva; `Scrollable.ensureVisible` es parte de Flutter.
- **Tests**: `test/widget_test.dart` verifica que la landing renderiza; el cambio de Stateless a Stateful no altera el árbol visible, pero conviene sumar cobertura del tap → scroll.
- **Efecto colateral conocido**: el `Column` de secciones deja de ser `const` porque los `GlobalKey` no son constantes. Cada sección individual sigue siendo `const` gracias a `KeyedSubtree`.
- **Fuera de alcance**: indicador de sección activa en el navbar, y URL fragments (`#servicios`) para web — ambos requieren infraestructura adicional y se dejan para una propuesta futura.
