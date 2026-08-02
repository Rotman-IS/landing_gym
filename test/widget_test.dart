import 'package:flutter_test/flutter_test.dart';
import 'package:landing_gym/main.dart';

void main() {
  testWidgets('App renders landing screen', (WidgetTester tester) async {
    await tester.pumpWidget(const LandingGymApp());

    expect(find.text('Iron Gym'), findsWidgets);
    expect(find.text('Transforma tu cuerpo, transforma tu vida'), findsOneWidget);
  });
}
