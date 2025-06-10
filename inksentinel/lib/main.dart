import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'generated/l10n.dart';
import 'components/screens/Forget password/forgetpage.dart';
import 'components/screens/Home/bar.dart';
import 'components/screens/LogIn/log_in.dart';
import 'components/screens/Sign up/sign_up.dart';
import 'components/screens/splash/splash_content.dart';
import 'firebase_options.dart';
import 'theme_manager.dart';
import 'locale_manager.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("🔥 Firebase Initialization Error: $e");
  }
  
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeManager()),
        ChangeNotifierProvider(create: (context) => LocaleManager()),
      ],
      child: Consumer2<ThemeManager, LocaleManager>(
        builder: (context, themeManager, localeManager, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'InkSentinel',
            // Localization delegates
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Supported locales
            supportedLocales: S.delegate.supportedLocales,
            // Current locale
            locale: localeManager.currentLocale,
            // Locale resolution callback
            localeResolutionCallback: (locale, supportedLocales) {
              // Check if the current device locale is supported
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              // Return English as fallback
              // return supportedLocales.first;
              return localeManager.currentLocale ?? supportedLocales.first;
            },
            // Use dynamic themes based on theme manager
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeManager.themeMode,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LogIn(),
              '/signup': (context) => const SignUp(),
              '/forgot': (context) => const Forgetpage(),
              '/splash': (context) => const SplashScreen(),
              '/home': (context) => const BasePageLayout(),
            },
          );
        },
      ),
    );
  }
}