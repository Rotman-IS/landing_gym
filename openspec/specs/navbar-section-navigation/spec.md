# navbar-section-navigation

## Purpose

Define cómo los links del navbar llevan al usuario a cada sección del landing. Al ser una página única sin routing, esta es la única navegación que existe en la aplicación.

El contrato atraviesa tres piezas: `AppConstants.navLinks` declara los pares `label`/`section`, `Navbar` emite `onSectionTap(section)` tanto desde su rama desktop (`_NavLink`) como desde la mobile (`_MobileMenu`), y `LandingScreen` resuelve el identificador de sección a una posición de scroll. El acoplamiento entre los identificadores declarados en las constantes y los destinos registrados por la pantalla es el punto frágil de este diseño, y por eso es materia de un requisito propio.

El navbar se renderiza fuera del área desplazable, como hermano del scroll y no superpuesto a él. Por eso los destinos se alinean al borde superior del viewport sin compensación de altura.

## Requirements

### Requirement: Navegación por scroll desde los links del navbar

El sistema SHALL desplazar la vista del landing hasta la sección correspondiente cuando el usuario activa un link del navbar. El desplazamiento MUST ser animado y MUST dejar la sección destino alineada con el borde superior del área desplazable.

#### Scenario: Tap en un link de sección en desktop

- **WHEN** el usuario, en un viewport de ancho mayor o igual a 600px, hace tap sobre el link "Servicios" del navbar
- **THEN** el contenido se desplaza de forma animada hasta que la sección de features queda alineada al tope del viewport desplazable

#### Scenario: Tap en un link de sección en mobile

- **WHEN** el usuario, en un viewport de ancho menor a 600px, abre el menú del navbar y hace tap sobre "Testimonios"
- **THEN** el menú se cierra y el contenido se desplaza de forma animada hasta que la sección de testimonios queda alineada al tope del viewport desplazable

#### Scenario: Vuelta al inicio

- **WHEN** el usuario hace tap sobre el link "Inicio" estando desplazado hacia abajo en la página
- **THEN** el contenido se desplaza de forma animada hasta el comienzo de la sección hero

### Requirement: Cobertura de todas las secciones declaradas

Cada entrada de `AppConstants.navLinks` MUST tener una sección destino asociada en el landing. El identificador de sección declarado en las constantes MUST coincidir exactamente con el identificador registrado por la pantalla.

#### Scenario: Todos los links declarados navegan

- **WHEN** el usuario activa, uno por uno, cada link declarado en `AppConstants.navLinks`
- **THEN** cada activación produce un desplazamiento hacia una sección distinta del landing y ninguna queda sin destino

### Requirement: Tolerancia a secciones sin destino resoluble

El sistema MUST ignorar de forma silenciosa la solicitud de navegación cuando el identificador de sección no tiene destino registrado o cuando el destino todavía no está montado en el árbol de widgets. La aplicación MUST NOT lanzar una excepción ni interrumpir la interacción del usuario en ese caso.

#### Scenario: Identificador sin destino registrado

- **WHEN** se solicita navegar a un identificador de sección que no está registrado
- **THEN** no ocurre desplazamiento alguno y la aplicación sigue respondiendo con normalidad, sin errores

### Requirement: Ciclo de vida del controlador de scroll

La pantalla del landing MUST crear su controlador de scroll una sola vez durante la inicialización y MUST liberarlo al desmontarse, en lugar de instanciarlo en cada reconstrucción del árbol.

#### Scenario: El controlador sobrevive a las reconstrucciones

- **WHEN** la pantalla del landing se reconstruye, por ejemplo al cambiar el tamaño del viewport entre mobile y desktop
- **THEN** la posición de scroll se conserva y no se crea un controlador nuevo

#### Scenario: El controlador se libera al desmontar

- **WHEN** la pantalla del landing se retira del árbol de widgets
- **THEN** el controlador de scroll queda liberado y no permanecen recursos asociados
