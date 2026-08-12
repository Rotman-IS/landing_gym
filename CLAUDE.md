# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Single-page Flutter marketing landing page for a fictional gym ("Iron Gym"). All user-facing copy is **Spanish**. No backend, no routing, no state management — one screen composed of static sections. Targets all Flutter platforms; web is the natural target for a landing page.

The Dart package is `basic_landing` — the name describes the reusable template, not the demo brand. Native identifiers still say `landing_gym` (Android `applicationId` and Kotlin package dir, macOS `PRODUCT_NAME` and `pbxproj`, Linux/Windows `BINARY_NAME`); that divergence is deliberate and explained in the README. Don't "fix" it as a stray rename.

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

`main.dart` → `LandingGymApp` (MaterialApp, dark theme only, `debugShowCheckedModeBanner: false`) → [landing_screen.dart](lib/screens/landing_screen.dart), which is a fixed `Navbar` above a `SingleChildScrollView` containing the sections in order: Hero → Features → Testimonials → CTA → Footer. Adding a navigable section takes three edits: an entry in `AppConstants.navLinks`, its id in `LandingScreen.sectionIds`, and a `KeyedSubtree` wrapping the widget in that Column.

Three conventions carry most of the codebase:

- **All content lives in [`AppConstants`](lib/utils/constants.dart)** — copy, feature list, testimonials, nav links, social/contact info, and spacing constants. Widgets read from it rather than hardcoding strings. Feature icons are stored as *strings* in the constants map and mapped to `IconData` by `_getIcon` in [features_section.dart:159](lib/widgets/features_section.dart#L159); a new feature needs both a constants entry and a case in that switch — miss the case and `default` silently renders `Icons.star`.
- **All styling lives in [`AppTheme`](lib/theme/app_theme.dart)** — the color palette (`primary`, `secondary`, `accent`, `dark`/`darker`/`surface`, text colors) and the full `TextTheme`. Widgets pull styles via `Theme.of(context).textTheme.*` and override only size via `copyWith`. Change brand colors in `AppTheme`, not in widgets.
- **Responsive layout is inline `MediaQuery` width checks**, not the `Responsive` helper. Every section widget starts with `final isMobile = MediaQuery.of(context).size.width < 600;` and branches padding/font-size/column-count from there (see [features_section.dart:10-40](lib/widgets/features_section.dart#L10-L40) for the mobile/tablet/desktop grid). [`Responsive`](lib/utils/responsive.dart) exists with the same 600/1024 breakpoints but is currently unused — either adopt it consistently or keep matching the inline pattern; don't mix within a widget.

Section navigation is wired: `_LandingScreenState` holds a `ScrollController` and one `GlobalKey` per section id, and `_scrollTo` calls `Scrollable.ensureVisible` (600ms, `easeInOut`). It **ignores unresolvable destinations silently** — a deliberate choice, since in a static landing the only real cause is a typo, and a dead tap beats a production exception. The cost is that a half-added section fails quietly; the `navegacion por secciones` test group covers the gap between `navLinks` and `sectionIds`, but nothing catches a missing `KeyedSubtree`.

Known gap: `flutter test` is **19/20**. `App renders landing screen` fails on a horizontal `RenderFlex` overflow in [navbar.dart:20](lib/widgets/navbar.dart#L20) and [footer.dart:37](lib/widgets/footer.dart#L37) at `flutter_test`'s default 800×600 viewport — the desktop branch's nav links and footer row don't fit that width. Pre-existing and unrelated to any recent change; the other 19 tests set their viewport explicitly and pass.
