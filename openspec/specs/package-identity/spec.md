# package-identity

## Purpose

Define la identidad del proyecto: el nombre canonico del paquete Dart, la descripcion que lo distingue de cualquier otro scaffold de Flutter, y las cadenas de identidad visibles en la build web. Fija tambien el limite del contrato: los identificadores de las plataformas nativas quedan deliberadamente fuera de su alcance.

## Requirements

### Requirement: Nombre canonico del paquete

El paquete Dart SHALL llamarse `basic_landing`. Ese nombre es la unica fuente de verdad de la identidad del proyecto y SHALL declararse en el campo `name` de `pubspec.yaml`.

El nombre describe lo que el proyecto **es** —una plantilla de landing estatica— y no el contenido de demostracion que la puebla. Ningun nombre de paquete PUEDE derivarse del dominio del copy de ejemplo (gimnasio, fitness, Iron Gym): ese contenido es reemplazable y su nombre no puede quedar fijado en la identidad del paquete.

#### Scenario: El pubspec declara el nombre canonico

- **WHEN** se lee el campo `name` de `pubspec.yaml`
- **THEN** su valor es `basic_landing`

#### Scenario: No sobrevive ninguna referencia al nombre anterior en codigo Dart

- **WHEN** se busca la cadena `landing_gym` en `lib/` y en `test/`
- **THEN** no aparece ninguna ocurrencia

### Requirement: Los imports absolutos resuelven contra el nombre canonico

Todo import de la forma `package:<nombre>/...` dentro del proyecto SHALL usar el nombre canonico del paquete. Un import que apunte a un nombre obsoleto no resuelve y rompe la compilacion de la suite de tests.

Los widgets de `lib/` usan imports relativos y no se ven afectados; el cambio recae sobre `test/`.

#### Scenario: La suite de tests compila tras el renombrado

- **WHEN** se ejecuta `flutter test`
- **THEN** todos los imports resuelven
- **AND** la suite se ejecuta sin errores de compilacion

#### Scenario: El analizador no reporta imports rotos

- **WHEN** se ejecuta `flutter analyze`
- **THEN** no se reporta ningun error de URI no resuelta

### Requirement: Descripcion informativa del paquete

El campo `description` de `pubspec.yaml` SHALL describir en una frase que es el proyecto: una landing page de una sola pantalla construida en Flutter, con contenido en espanol, pensada como plantilla reutilizable.

NO PUEDE conservarse el texto generado por `flutter create` (*"A new Flutter project."*), que no distingue este repositorio de ningun otro.

#### Scenario: La descripcion no es la del scaffold

- **WHEN** se lee el campo `description` de `pubspec.yaml`
- **THEN** su valor no es `A new Flutter project.`
- **AND** menciona que se trata de una landing page

### Requirement: Consistencia de la identidad visible en la build web

Las cadenas de identidad que el navegador muestra al usuario final SHALL reflejar la identidad del proyecto y no el nombre por defecto del scaffold. Cubre el `<title>` y el `apple-mobile-web-app-title` de `web/index.html`, y los campos `name` y `short_name` de `web/manifest.json`.

Estas cadenas son visibles en la pestana del navegador y en el icono de aplicacion instalada, por lo que forman parte del producto y no de su andamiaje.

#### Scenario: El titulo de la pestana no es el nombre del scaffold

- **WHEN** se sirve la build web y se inspecciona el titulo del documento
- **THEN** no contiene `landing_gym`

#### Scenario: El manifest declara la identidad actual

- **WHEN** se leen los campos `name` y `short_name` de `web/manifest.json`
- **THEN** ninguno contiene `landing_gym`

### Requirement: Los identificadores nativos quedan fuera del contrato

Los identificadores de las plataformas nativas —`applicationId` y `namespace` de Android, el directorio del paquete Kotlin, `PRODUCT_BUNDLE_IDENTIFIER` y `PRODUCT_NAME` de macOS, `BINARY_NAME` de Linux y Windows— NO ESTAN cubiertos por esta capability y PUEDEN seguir conteniendo el nombre anterior.

Renombrarlos exige mover directorios de codigo fuente y editar proyectos Xcode y Gradle, con riesgo de romper builds nativas, a cambio de ningun beneficio para un proyecto cuyo destino de despliegue es web. La divergencia es deliberada y SHALL quedar registrada en la documentacion del proyecto para que no se lea como un renombrado incompleto.

#### Scenario: Una referencia nativa al nombre anterior no es un defecto

- **WHEN** se encuentra `landing_gym` en `android/`, `ios/`, `macos/`, `linux/` o `windows/`
- **THEN** no se considera un incumplimiento de esta especificacion

#### Scenario: La divergencia esta documentada

- **WHEN** se consulta la documentacion del proyecto
- **THEN** se explica que los identificadores nativos conservan el nombre anterior y por que
