## 1. Tokens en AppTheme

- [x] 1.1 Reemplazar los valores de los 8 tokens existentes en `lib/theme/app_theme.dart:6-13`: `primary #C9A24D`, `secondary #AEB6BF`, `accent #2C4B78`, `dark #101822`, `darker #08090B`, `surface #1B2A42`, `textPrimary #F2F4F6`, `textSecondary #9AA5B1`. Eliminar los comentarios con los hex antiguos.
- [x] 1.2 Añadir los tokens `onPrimary = Color(0xFF0A0F16)` y `primaryHover = Color(0xFFE4C982)`.
- [x] 1.3 Añadir los getters derivados `cardBorder` (`secondary` @0.35), `glow` (`accent` @0.28) y `glowSoft` (`primary` @0.10).
- [x] 1.4 Añadir sobre las declaraciones un comentario que agrupe los tokens por rol (superficies / acento de marca / estructura y texto) y advierta que los de superficie no se usan como color de primer plano.
- [x] 1.5 Añadir el comentario del contrato de contraste con los cinco pares y sus umbrales (`primary` vs superficies ≥4.5:1, `onPrimary` vs `primary` ≥4.5:1, `textPrimary` y `textSecondary` vs superficies ≥4.5:1, `secondary` vs `surface` ≥3:1).
- [x] 1.6 Cambiar `foregroundColor: Colors.white` por `onPrimary` en el `elevatedButtonTheme` (`app_theme.dart:76`). Verificar que `backgroundColor` sigue siendo `primary` (correcto sin cambios).
- [x] 1.7 Revisar el `ColorScheme.dark` (`app_theme.dart:20-27`): `onPrimary` pasa de `Colors.white` al token `onPrimary`; `onSecondary` pasa de `Colors.black` a `darker`.

## 2. Reasignación de callsites

- [x] 2.1 `hero_section.dart:33` — el círculo grande pasa de `primary.withOpacity(0.1)` a `AppTheme.glow`.
- [x] 2.2 `hero_section.dart:45` — el círculo pequeño pasa de `accent.withOpacity(0.05)` a `AppTheme.glowSoft`.
- [x] 2.3 `cta_section.dart:22` — el gradiente pasa de `[primary, accent]` a `[AppTheme.dark, AppTheme.accent]`.
- [x] 2.4 `cta_section.dart:47-48` — el botón pasa de `backgroundColor: Colors.white` / `foregroundColor: primary` a `backgroundColor: AppTheme.primary` / `foregroundColor: AppTheme.onPrimary`.
- [x] 2.5 `features_section.dart:74` — el borde de tarjeta pasa de `primary.withOpacity(0.3)` a `AppTheme.cardBorder`.
- [x] 2.6 `testimonials_section.dart:73` — el borde de tarjeta pasa de `secondary.withOpacity(0.2)` a `AppTheme.cardBorder`.
- [x] 2.7 `testimonials_section.dart:96` — el nombre de la persona pasa de `primary` a `AppTheme.textPrimary`.
- [x] 2.8 `footer.dart:93` — los iconos de contacto pasan de `primary` a `AppTheme.secondary`.
- [x] 2.9 `footer.dart:117` — el borde del botón social pasa de `primary.withOpacity(0.5)` a `AppTheme.cardBorder`.

## 3. Confirmación de callsites sin cambio

- [x] 3.1 Verificar que estos siete siguen usando `AppTheme.primary` y quedan correctos al haber cambiado el valor del token: `navbar.dart:27` (logo), `footer.dart:25` (logo), `footer.dart:120` (icono social), `features_section.dart:84` (icono de feature), `testimonials_section.dart:81` (comilla), `app_theme.dart:75` (relleno del botón).
- [x] 3.2 Verificar que `hero_section.dart:20` sigue usando `[darker, dark, surface]` sin cambios y que el gradiente resultante mantiene luminancia creciente.

## 4. Verificación

- [x] 4.1 Buscar `.withOpacity(` en `lib/widgets/` y confirmar que no queda ninguna aplicada sobre una constante de `AppTheme`.
- [x] 4.2 Buscar `Colors.white`, `Colors.black` y literales `Color(0x` en `lib/widgets/` y confirmar que no queda ningún color fuera de `AppTheme` (excepto los usos de blanco sobre gradiente en `cta_section.dart:32,40`, que deben pasar a `textPrimary` y `textSecondary`).
- [x] 4.3 Confirmar que no queda ningún naranja ni rojo en `lib/`.
- [x] 4.4 Ejecutar `flutter analyze` y dejarlo sin warnings.
- [x] 4.5 Ejecutar `flutter test`. NOTA: falla por un overflow horizontal de layout PREEXISTENTE (verificado contra baseline con `git stash`), ajeno a este cambio. Requiere un cambio aparte.
- [x] 4.6 Ejecutar `flutter run -d chrome` y revisar las seis secciones: logo del navbar legible, iconos de features dorados, bordes de tarjeta visibles en features y testimonios, estrellas doradas, gradiente del CTA con botón dorado y texto oscuro, glows del hero perceptibles.
- [x] 4.7 Comprobar el punto abierto del diseño: decidir si las opacidades de `cardBorder` (0.35) y `glow` (0.28) son suficientes sin fotografía, y ajustarlas en `app_theme.dart` si el resultado se ve plano.
- [x] 4.8 Revisar la vista móvil (<600px) para confirmar que los contrastes y bordes se mantienen en el layout de una columna.
