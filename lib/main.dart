import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import Providers
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/study_provider.dart';

// Import Screens
import 'screens/auth/welcome_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool initSuccess = false;
  String initError = '';

  try {
    // Warm up local storage (SharedPreferences)
    await SharedPreferences.getInstance();

    // Load the environment variables
    await dotenv.load(fileName: ".env");
    initSuccess = true;
  } catch (e, stack) {
    debugPrint("Failed to initialize app: $e");
    debugPrint(stack.toString());
    initError = e.toString();
  }

  // Set system bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  if (!initSuccess) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.light,
          ),
        ),
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Startup Error',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'StudyCards was unable to start because of a configuration issue:\n\n$initError',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Attempt recovery by restarting main
                        main();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
      ],
      child: const StudyCardsApp(),
    ),
  );
}

class StudyCardsApp extends StatelessWidget {
  const StudyCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'StudyCards',
      debugShowCheckedModeBanner: false,
      theme: themeProv.getThemeData(false),
      darkTheme: themeProv.getThemeData(true),
      themeMode: themeProv.themeMode,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // If auth session loading is not complete or not logged in, show Welcome Screen
          if (auth.isLoggedIn) {
            return const MainNavigationScreen();
          } else {
            return const WelcomeScreen();
          }
        },
      ),
    );
  }
}
