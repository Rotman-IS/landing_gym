class AppConstants {
  AppConstants._();

  static const String appName = 'Iron Gym';
  static const String tagline = 'Transforma tu cuerpo, transforma tu vida';
  static const String heroSubtitle =
      'Entrenamiento de alto rendimiento con coaches profesionales y equipamiento de última generación.';
  static const String ctaText = 'Empieza hoy';
  static const String ctaSubtitle =
      'Únete a la mejor comunidad de fitness de la ciudad. Tu primera clase es gratis.';
  static const String ctaButton = 'Agenda tu visita';

  static const String heroBannerAsset = 'assets/images/heroBanner.webp';

  static const List<Map<String, String>> features = [
    {
      'icon': 'fitness_center',
      'title': 'Equipamiento Premium',
      'description':
          'Máquinas de última generación y peso libre para todos los niveles.',
    },
    {
      'icon': 'group',
      'title': 'Clases en Grupo',
      'description':
          'CrossFit, Yoga, Spinning y más con instructores certificados.',
    },
    {
      'icon': 'personal_video',
      'title': 'Entrenadores Personales',
      'description':
          'Programas personalizados diseñados para alcanzar tus metas.',
    },
    {
      'icon': 'restaurant',
      'title': 'Nutrición',
      'description':
          'Planes de alimentación y asesoría nutricional incluida.',
    },
  ];

  static const List<Map<String, String>> testimonials = [
    {
      'name': 'Carlos M.',
      'text':
          'En 3 meses bajé 12 kg. El ambiente y los coaches son increíbles.',
    },
    {
      'name': 'Ana G.',
      'text':
          'Nunca pensé que disfrutaría hacer ejercicio. Iron Gym cambió mi vida.',
    },
    {
      'name': 'Pedro R.',
      'text':
          'Equipamiento de primera y el mejor personal training de la ciudad.',
    },
  ];

  static const List<Map<String, String>> navLinks = [
    {'label': 'Inicio', 'section': 'hero'},
    {'label': 'Servicios', 'section': 'features'},
    {'label': 'Testimonios', 'section': 'testimonials'},
    {'label': 'Contacto', 'section': 'cta'},
  ];

  static const Map<String, String> socialLinks = {
    'instagram': 'https://instagram.com/irongym',
    'facebook': 'https://facebook.com/irongym',
    'twitter': 'https://twitter.com/irongym',
  };

  static const String phone = '+52 55 1234 5678';
  static const String email = 'info@irongym.com';
  static const String address = 'Av. Principal 123, CDMX';

  static const double paddingMobile = 16.0;
  static const double paddingTablet = 32.0;
  static const double paddingDesktop = 64.0;
  static const double sectionSpacing = 60.0;
}
