# project-documentation

## Purpose

Define el contrato de la documentacion del proyecto: el papel del `README.md` como puerta de entrada, sus secciones minimas, la forma de la guia de personalizacion orientada a tareas, la convencion de capturas de pantalla y la exigencia de que toda afirmacion tecnica corresponda al codigo vigente.

## Requirements

### Requirement: El README es la puerta de entrada al proyecto

`README.md` SHALL ser un documento propio del proyecto y NO PUEDE conservar el boilerplate generado por `flutter create`, cuyos enlaces genericos a la documentacion de Flutter no dicen nada sobre este repositorio.

El documento SHALL permitir a un lector que nunca vio el codigo responder cuatro preguntas sin abrir un solo archivo fuente: que es el proyecto, como ejecutarlo, como esta organizado y como adaptarlo a otra marca.

El README SHALL estar escrito en espanol, coherente con el copy de la propia landing.

#### Scenario: El boilerplate ha desaparecido

- **WHEN** se lee `README.md`
- **THEN** no contiene la frase `A new Flutter project`
- **AND** no contiene la seccion generica `Getting Started` del scaffold de Flutter

#### Scenario: Un tercero puede arrancar el proyecto

- **WHEN** un lector sin contexto previo sigue unicamente las instrucciones del README
- **THEN** obtiene los comandos necesarios para instalar dependencias y ejecutar la landing en el navegador

### Requirement: Secciones minimas del README

`README.md` SHALL contener, como minimo, las siguientes secciones:

- **Encabezado** con el nombre del proyecto y una descripcion de una linea.
- **Vista previa**, con las referencias a las capturas de pantalla.
- **Que es**, delimitando el alcance: pantalla unica, sin backend, sin routing, sin gestion de estado.
- **Caracteristicas**, con los rasgos reales del proyecto.
- **Stack**, con las versiones efectivamente declaradas en `pubspec.yaml`.
- **Instalacion y ejecucion**, con los comandos de `flutter pub get` y `flutter run`.
- **Personalizacion**, la guia de re-marcado.
- **Estructura del proyecto**, con el arbol de `lib/`.
- **Tests**, indicando que cubre la suite.
- **Build y despliegue**, para web.
- **Flujo OpenSpec**, explicando como se versiona el diseno del proyecto.

#### Scenario: Todas las secciones estan presentes

- **WHEN** se recorren los encabezados de `README.md`
- **THEN** cada una de las secciones minimas esta representada

### Requirement: Guia de personalizacion orientada a la tarea

La seccion de personalizacion SHALL organizarse por **intencion del lector** —"quiero cambiar X"— y no por archivo, y SHALL indicar para cada intencion el archivo o archivos exactos a tocar.

SHALL cubrir al menos: cambiar textos y datos de contacto (`lib/utils/constants.dart`), cambiar los colores de marca (`lib/theme/app_theme.dart`), reemplazar la imagen del hero (`assets/images/`), agregar un servicio y agregar un enlace de navegacion.

Para las tareas que exigen editar **mas de un archivo**, el README SHALL enumerar todos los puntos de edicion. Omitir uno convierte la guia en una trampa: el cambio parece hecho y falla en ejecucion.

Los dos casos multi-archivo conocidos son:
- Agregar un servicio: entrada en `AppConstants.features` **y** un `case` en el mapeo de iconos de `features_section.dart`, porque el icono se almacena como cadena.
- Agregar un enlace de navegacion: entrada en `AppConstants.navLinks`, identificador en `LandingScreen.sectionIds` **y** el `KeyedSubtree` correspondiente en el arbol de la pantalla.

#### Scenario: Agregar un servicio se documenta completo

- **WHEN** se lee la instruccion para agregar un servicio
- **THEN** menciona tanto la entrada en constantes como el mapeo del icono

#### Scenario: Agregar un enlace de navegacion se documenta completo

- **WHEN** se lee la instruccion para agregar un enlace al navbar
- **THEN** menciona los tres puntos de edicion requeridos

### Requirement: Convencion de capturas de pantalla

Las capturas SHALL vivir en `docs/screenshots/`, con nombres prefijados por un ordinal de dos digitos que fija su orden de aparicion (por ejemplo `01-hero-desktop.png`).

El README SHALL declarar las referencias a las capturas **antes** de que las imagenes existan, cada una acompanada de una indicacion de que capturar y a que ancho de viewport, de modo que el autor pueda anadirlas despues sin reestructurar el documento.

Mientras un archivo de captura no exista, su referencia NO PUEDE renderizarse como una imagen rota en la vista del repositorio.

#### Scenario: Las referencias estan declaradas de antemano

- **WHEN** se lee el README antes de que existan las capturas
- **THEN** cada hueco de captura indica que se espera en el y a que ancho tomarlo

#### Scenario: No hay imagenes rotas

- **WHEN** se visualiza el README sin ningun archivo en `docs/screenshots/`
- **THEN** no aparece ningun icono de imagen rota

#### Scenario: Anadir una captura no exige editar la estructura

- **WHEN** el autor coloca un archivo en `docs/screenshots/` con el nombre indicado
- **THEN** la captura aparece en su posicion sin reorganizar las secciones del documento

### Requirement: La documentacion refleja el estado real del codigo

Ninguna afirmacion tecnica del README o de `CLAUDE.md` PUEDE contradecir el codigo vigente. Toda version, comando, ruta y nombre de archivo citado SHALL verificarse contra el repositorio antes de publicarse.

En particular, la nota de `CLAUDE.md` que describe `Navbar.onSectionTap` como un no-op SHALL corregirse: la navegacion por secciones esta implementada mediante `GlobalKey` por seccion y `Scrollable.ensureVisible` desde un `StatefulWidget`.

#### Scenario: Los comandos documentados funcionan

- **WHEN** se ejecuta cada comando citado en el README
- **THEN** ninguno falla por una ruta o un nombre inexistente

#### Scenario: La nota obsoleta de navegacion desaparece

- **WHEN** se lee `CLAUDE.md`
- **THEN** no afirma que los enlaces del navbar no desplazan a ninguna parte

#### Scenario: Las versiones citadas coinciden con el pubspec

- **WHEN** se comparan las versiones de SDK y dependencias del README con `pubspec.yaml`
- **THEN** coinciden
