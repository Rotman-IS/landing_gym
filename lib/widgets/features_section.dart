import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  /// Key de la tarjeta que ocupa la posicion [index] de
  /// `AppConstants.features`. Existe para que las pruebas puedan medir cada
  /// tarjeta sin exponer `_FeatureCard`.
  static Key cardKey(int index) => ValueKey('feature-card-$index');

  /// Separacion entre tarjetas, tanto horizontal como vertical.
  static const double _gap = 24;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;
    final columns = isMobile ? 1 : (isTablet ? 2 : 4);

    return Container(
      color: AppTheme.dark,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: 60,
      ),
      child: Column(
        children: [
          Text(
            '¿Por qué elegirnos?',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: isMobile ? 28 : 36,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Todo lo que necesitas para alcanzar tus metas',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 48),
          ..._buildRows(columns),
        ],
      ),
    );
  }

  /// Reparte las features en filas de [columns] tarjetas.
  ///
  /// La altura de cada fila la fija su tarjeta mas alta, no el ancho de la
  /// celda. Es lo contrario de lo que hacia `GridView.childAspectRatio`, que
  /// derivaba el alto del ancho: a 1024 px el ancho se repartia en 4 columnas
  /// de 206 px y el alto resultante dejaba ~57 px menos de los que el texto
  /// necesitaba. Midiendo desde el contenido, cambiar el copy o el tamano de
  /// fuente no puede volver a desbordar.
  List<Widget> _buildRows(int columns) {
    final rows = <Widget>[];
    for (var start = 0;
        start < AppConstants.features.length;
        start += columns) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: _gap));
      rows.add(_buildRow(start, columns));
    }
    return rows;
  }

  Widget _buildRow(int start, int columns) {
    final children = <Widget>[];
    for (var col = 0; col < columns; col++) {
      if (col > 0) children.add(const SizedBox(width: _gap));

      final index = start + col;
      if (index >= AppConstants.features.length) {
        // Ranura de relleno de una ultima fila incompleta: conserva el ancho
        // de las tarjetas presentes en vez de dejar que se estiren.
        children.add(const Expanded(child: SizedBox.shrink()));
        continue;
      }

      final feature = AppConstants.features[index];
      children.add(
        Expanded(
          child: _FeatureCard(
            key: cardKey(index),
            icon: feature['icon']!,
            title: feature['title']!,
            description: feature['description']!,
          ),
        ),
      );
    }

    // IntrinsicHeight fuerza un pase de medicion extra sobre la fila. Aqui son
    // como mucho cuatro filas de contenido estatico (un icono y dos textos),
    // asi que el coste es despreciable. No replicar el patron en listas largas
    // ni en contenido que se reconstruya en cada frame.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // Sin alto propio: lo recibe de la fila via CrossAxisAlignment.stretch.
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.cardBorder,
          width: 1,
        ),
      ),
      child: Column(
        // Centra el contenido cuando la tarjeta se estira para igualar a una
        // hermana mas alta de su fila.
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIcon(icon),
            size: 48,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'group':
        return Icons.group;
      case 'personal_video':
        return Icons.personal_video;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.star;
    }
  }
}
