import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/booker_refresh_controller.dart';
import 'package:flutter_app/routes/login_page.dart';
import 'package:flutter_app/routes/onboarding_page.dart';
import 'package:flutter_app/widgets/main_page.dart';
import 'package:flutter_app/routes/registration_page.dart';
import 'package:flutter_app/themes/themes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/login_controller.dart';
import 'controllers/cart_controller.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ThemeChangerProvider().loadTheme();
  var prefs = await SharedPreferences.getInstance();
  var firstBoot = prefs.getBool('firstBoot') ?? true;
  await LoginController().checkLogin();
  if (LoginController().status == AutehticationStatus.authenticated) {
    await CartController().loadCart();
  }
  runApp(PrivateLessonBooker(firstBoot: firstBoot));
}

// Important: this file should only contain the main function and the MyApp class
// DO NOT put any other code here
class PrivateLessonBooker extends StatelessWidget {
  final bool firstBoot;
  const PrivateLessonBooker({Key? key, required this.firstBoot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeChangerProvider()),
        ChangeNotifierProvider(create: (context) => LoginController()),
        ChangeNotifierProvider(create: (context) => CartController()),
        ChangeNotifierProvider(create: (context) => BookerRefreshController()),
      ],
      child: Consumer2<ThemeChangerProvider, LoginController>(
        builder: (context, theme, login, child) {
          return MaterialApp(
            title: 'Private Lesson Booker',
            theme: theme.darkTheme ? darkTheme : lightTheme,
            routes: {
              '/login': (context) => const LoginPage(),
              '/main': (context) => const MainPage(),
              '/register': (context) => const RegistrationPage(),
            },
            home: firstBoot
                ? const OnboardingScreen()
                : login.status == AutehticationStatus.authenticated
                    ? const MainPage()
                    : const LoginPage(),
            debugShowCheckedModeBanner: false,
            // set supported locales
            supportedLocales: const [Locale('it'), Locale('en')],
            // set localizations delegates
            localizationsDelegates: const [
              // ... app-specific localization delegate[s] here
              // built-in localization delegates
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
