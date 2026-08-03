# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Single-page Flutter marketing landing page for a fictional gym ("Iron Gym"). All user-facing copy is **Spanish**. No backend, no routing, no state management — one screen composed of static sections. Targets all Flutter platforms; web is the natural target for a landing page.

## Commands

```bash
flutter pub get                       # install deps
flutter run -d chrome                 # run on web
flutter analyze                       # lint (flutter_lints via analysis_options.yaml)
flutter test                          # all tests
flutter test test/widget_test.dart    # single file
flutter test --plain-name 'App renders landing screen'   # single test by name
flutter build web                     # release build
```

Flutter SDK path is set per-machine in `android/local.properties` (`flutter.sdk=...`) — it is committed and machine-specific, so expect churn there along with `.dart_tool/` and `pubspec.lock`.

## Architecture

`main.dart` → `LandingGymApp` (MaterialApp, dark theme only, `debugShowCheckedModeBanner: false`) → [landing_screen.dart](lib/screens/landing_screen.dart), which is a fixed `Navbar` above a `SingleChildScrollView` containing the sections in order: Hero → Features → Testimonials → CTA → Footer. Adding a section means adding a widget to that Column and, if it should be navigable, an entry in `AppConstants.navLinks`.

Three conventions carry most of the codebase:

- **All content lives in [`AppConstants`](lib/utils/constants.dart)** — copy, feature list, testimonials, nav links, social/contact info, and spacing constants. Widgets read from it rather than hardcoding strings. Feature icons are stored as *strings* in the constants map and mapped to `IconData` by `_getIcon` in [features_section.dart:103](lib/widgets/features_section.dart#L103); a new feature needs both a constants entry and a case in that switch.
- **All styling lives in [`AppTheme`](lib/theme/app_theme.dart)** — the color palette (`primary`, `secondary`, `accent`, `dark`/`darker`/`surface`, text colors) and the full `TextTheme`. Widgets pull styles via `Theme.of(context).textTheme.*` and override only size via `copyWith`. Change brand colors in `AppTheme`, not in widgets.
- **Responsive layout is inline `MediaQuery` width checks**, not the `Responsive` helper. Every section widget starts with `final isMobile = MediaQuery.of(context).size.width < 600;` and branches padding/font-size/column-count from there (see [features_section.dart:10-40](lib/widgets/features_section.dart#L10-L40) for the mobile/tablet/desktop grid). [`Responsive`](lib/utils/responsive.dart) exists with the same 600/1024 breakpoints but is currently unused — either adopt it consistently or keep matching the inline pattern; don't mix within a widget.

Known gap: `Navbar.onSectionTap` in [landing_screen.dart:21](lib/screens/landing_screen.dart#L21) is a no-op — nav links don't scroll anywhere. Wiring it needs `GlobalKey`s on the sections and a `ScrollController` hoisted into a `StatefulWidget` (the current controller is created in `build`).
