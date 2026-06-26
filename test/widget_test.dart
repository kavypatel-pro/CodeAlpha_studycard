import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:study_cards/main.dart';
import 'package:study_cards/providers/auth_provider.dart';
import 'package:study_cards/providers/theme_provider.dart';
import 'package:study_cards/providers/study_provider.dart';

void main() {
  testWidgets('Welcome screen UI renders properly smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
        ],
        child: const StudyCardsApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the title StudyCards exists on the welcome page.
    expect(find.text('StudyCards'), findsOneWidget);
    
    // Verify that the "Login to Account" button exists on the welcome page.
    expect(find.text('Login to Account'), findsOneWidget);
  });
}

