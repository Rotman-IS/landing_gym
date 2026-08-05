## Context

`LandingScreen` es hoy un `StatelessWidget` que compone `Navbar` sobre un `SingleChildScrollView` con las cinco secciones en un `Column`. El contrato de navegación ya está tendido de punta a punta: `AppConstants.navLinks` declara pares `label`/`section`, el navbar emite `onSectionTap(section)` tanto desde `_NavLink` (desktop) como desde `_MobileMenu` (mobile), y `LandingScreen` recibe el callback. Lo único que falta es el último salto: traducir el string de sección a una posición de scroll.

Dos rasgos del estado actual condicionan el diseño:

1. **El navbar vive fuera del área desplazable.** Es un hijo del `Column` raíz, con el `SingleChildScrollView` dentro de un `Expanded`. No flota sobre el contenido, así que el destino de scroll no necesita compensar la altura del navbar — cosa que sí haría falta si fuera un `Stack`.
2. **El `ScrollController` se crea dentro de `build()`.** Se instancia uno nuevo en cada reconstrucción y ninguno se libera.

## Goals / Non-Goals

**Goals:**

- Que cada link del navbar desplace la vista hasta su sección, con animación, en desktop y mobile.
- Mantener intacto el contrato `onSectionTap(String)` — sin tocar `navbar.dart`, `constants.dart` ni los widgets de sección.
- Que agregar una sección navegable siga siendo un cambio pequeño y localizado.
- Corregir el ciclo de vida del `ScrollController` como parte del mismo cambio.

**Non-Goals:**

- Indicador de sección activa en el navbar (resaltar el link según la posición de scroll).
- URL fragments tipo `#servicios` para web — requeriría routing, que el proyecto no tiene.
- Adoptar el helper `Responsive` no usado, o cualquier otra refactorización de estilo.

## Decisions

### 1. `Scrollable.ensureVisible` en lugar de aritmética de offsets

Se resuelve el destino con `Scrollable.ensureVisible(context, alignment: 0.0, duration: ..., curve: ...)`.

*Alternativas consideradas:*

- **Offset manual** (`GlobalKey` → `RenderBox.localToGlobal` → `controller.animateTo`): da control fino sobre el offset final, pero implica matemática propia que hay que revisar cada vez que cambia el layout, y multiplica los casos borde entre mobile y desktop.
- **`scrollable_positioned_list`**: pensado para listas largas de índice conocido; agregar una dependencia para cinco secciones fijas no se justifica.

`ensureVisible` con `alignment: 0.0` alinea el destino al borde superior del viewport, que es exactamente el comportamiento que pide la spec, y delega el cálculo al framework. Como el navbar no se superpone al contenido, la alineación al tope ya es la posición correcta y no hay corrección adicional que aplicar.

### 2. Un `Map<String, GlobalKey>` como registro de secciones

Las claves del mapa son los mismos identificadores que declara `AppConstants.navLinks`: `hero`, `features`, `testimonials`, `cta`.

*Alternativa considerada:* una `GlobalKey` por variable más un `switch (section)`. Se descarta porque introduce un segundo lugar que mantener sincronizado con las constantes — el mismo patrón de fricción que ya existe con `_getIcon` en `features_section.dart`, donde una feature nueva exige tocar constantes *y* el switch. El mapa mantiene un único punto de registro y la lectura es un lookup directo.

### 3. `KeyedSubtree` para envolver cada sección

Las `GlobalKey` no son constantes, así que pasarlas como `key:` directa a `HeroSection(...)` obligaría a perder el `const` de cada widget de sección. Envolviendo con `KeyedSubtree(key: ..., child: const HeroSection())` la key vive en el wrapper y cada sección conserva su constructor `const`. El `Column` contenedor sí deja de ser `const`, cosa inevitable.

`Footer` no es destino de ningún link y no lleva key.

### 4. `StatefulWidget` con `initState` / `dispose`

Necesario tanto para sostener el mapa de keys de forma estable entre rebuilds como para mover el `ScrollController` a `initState` y liberarlo en `dispose`. Las dos cosas se resuelven con la misma conversión, por eso la corrección de la fuga entra en este cambio y no en uno aparte.

### 5. Fallo silencioso ante destino no resoluble

`_scrollTo` busca la key en el mapa y luego su `currentContext`. Si alguno es nulo, retorna sin hacer nada. No hay estado de error ni feedback al usuario: en una landing estática el único modo en que esto ocurre es un identificador mal escrito en las constantes, y un tap sin efecto es preferible a una excepción en producción.

### 6. "Contacto" apunta a la sección CTA

`AppConstants.navLinks` ya mapea `Contacto → cta`. El footer también tiene datos de contacto, pero el CTA es el destino accionable y es el mapeo que las constantes ya declaran; se respeta sin cambios.

## Risks / Trade-offs

- **El `Column` de secciones deja de ser `const`** → Impacto de rendimiento despreciable: las secciones hijas siguen siendo `const` gracias a `KeyedSubtree`, así que sus subárboles se siguen reutilizando.
- **`GlobalKey` duplicada si el mapa se instancia mal** → Se declara como campo `final` inicializado una sola vez en el `State`, nunca dentro de `build()`.
- **Desincronización entre `navLinks` y el mapa de keys** → Una entrada nueva en las constantes sin su key correspondiente produce un link muerto, silencioso por diseño. Mitigación: un test que recorra `AppConstants.navLinks` y verifique que cada identificador tiene destino registrado, convirtiendo el fallo silencioso en un test rojo.
- **Animación sobre distancias largas** → `ensureVisible` con duración fija recorre distancias muy distintas al mismo tiempo total. Aceptable para cinco secciones; si se notara brusco, la duración se ajusta en un solo lugar.
- **`ensureVisible` sobre una sección aún no montada** → No aplica aquí: el `SingleChildScrollView` con un `Column` construye todos los hijos de inmediato, así que los `currentContext` están disponibles apenas termina el primer frame. El guard queda igual como red de seguridad.
