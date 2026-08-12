## ADDED Requirements

### Requirement: Las tarjetas de features nunca desbordan verticalmente

La retícula de la sección "¿Por qué elegirnos?" SHALL dimensionar la altura de cada tarjeta a partir de la altura que su contenido requiere. Ninguna tarjeta SHALL imponer a su contenido una altura máxima menor que la altura intrínseca de ese contenido, en ningún ancho de viewport.

#### Scenario: Ancho de 1024 px (PC pequeña y iPad Pro vertical)

- **WHEN** la sección se renderiza en un viewport de 1024 px de ancho
- **THEN** no se emite ningún error de overflow de renderizado
- **AND** el texto descriptivo completo de cada tarjeta es visible, sin recorte ni elipsis

#### Scenario: Barrido de anchos representativos

- **WHEN** la sección se renderiza a 360, 599, 600, 1023, 1024, 1280 y 1920 px de ancho
- **THEN** en ninguno de esos anchos se emite un error de overflow
- **AND** el título y la descripción completos de las cuatro tarjetas son visibles en todos ellos

#### Scenario: El copy de una feature crece

- **WHEN** la descripción de una feature en `AppConstants.features` se sustituye por un texto notablemente más largo
- **THEN** la tarjeta crece en altura para acomodarlo
- **AND** no se emite ningún error de overflow

### Requirement: Conteo de columnas por breakpoint

La retícula SHALL disponer las tarjetas en 1 columna cuando el ancho del viewport es menor que 600 px, en 2 columnas cuando está entre 600 px inclusive y 1024 px exclusive, y en 4 columnas cuando es mayor o igual a 1024 px.

#### Scenario: Móvil

- **WHEN** el ancho del viewport es menor que 600 px
- **THEN** las tarjetas se apilan en una sola columna

#### Scenario: Tablet

- **WHEN** el ancho del viewport está entre 600 px inclusive y 1024 px exclusive
- **THEN** las tarjetas se disponen en 2 columnas

#### Scenario: Escritorio

- **WHEN** el ancho del viewport es mayor o igual a 1024 px
- **THEN** las cuatro tarjetas se disponen en 4 columnas en una sola fila

### Requirement: Tarjetas de igual altura y ancho dentro de una fila

Las tarjetas que comparten una fila SHALL tener la misma altura, igual a la altura del contenido más alto de esa fila, y SHALL repartirse el ancho disponible en partes iguales. Filas distintas MAY tener alturas distintas.

#### Scenario: Descripciones de distinta longitud en la misma fila

- **WHEN** dos tarjetas de la misma fila tienen descripciones que ocupan distinto número de líneas
- **THEN** ambas tarjetas se renderizan con idéntica altura
- **AND** el borde inferior de ambas queda alineado

#### Scenario: Fila incompleta

- **WHEN** el número de features no es múltiplo del número de columnas y la última fila queda incompleta
- **THEN** las tarjetas de esa fila conservan el mismo ancho que las de las filas completas
- **AND** el espacio sobrante queda vacío en lugar de estirar las tarjetas presentes

### Requirement: La apariencia de la tarjeta se conserva

El cambio de layout SHALL preservar la presentación visual existente de la tarjeta: color de superficie, borde, radio de esquina, padding interno, tamaños e iconografía, y las separaciones horizontal y vertical entre tarjetas.

#### Scenario: Separación entre tarjetas

- **WHEN** la retícula se renderiza con más de una tarjeta por fila o más de una fila
- **THEN** la separación horizontal entre tarjetas adyacentes es de 24 px
- **AND** la separación vertical entre filas adyacentes es de 24 px

#### Scenario: Contenido centrado en una tarjeta más alta que su contenido

- **WHEN** una tarjeta se estira para igualar la altura de otra más alta de su fila
- **THEN** su icono, título y descripción quedan centrados verticalmente dentro de la tarjeta
