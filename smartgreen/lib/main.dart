import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smartgreen/homepage.dart';

import 'firebase_options.dart';
import 'services/cart_service.dart';
import 'screens/login_screen.dart';
import 'screens/catalog_page.dart';
import 'theme/app_colors.dart';

void
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (
                _,
              ) =>
                  CartService(),
        ),
      ],
      child:
          const MyApp(),
    ),
  );
}

class MyApp
    extends
        StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor:
          AppColors.green,
      brightness:
          Brightness.light,
    ).copyWith(
      primary:
          AppColors.green,
      secondary:
          AppColors.green,
      tertiary:
          AppColors.blue, // <- azul padronizado (botões secundários)
      surface:
          AppColors.surface,
    );

    final theme = ThemeData(
      useMaterial3:
          true,
      colorScheme:
          colorScheme,
      scaffoldBackgroundColor:
          AppColors.background,

      appBarTheme: const AppBarTheme(
        backgroundColor:
            AppColors.green,
        foregroundColor:
            Colors.white,
        elevation:
            0,
        centerTitle:
            true,
      ),

      cardTheme: CardThemeData(
        color:
            AppColors.surfaceAlt,
        elevation:
            3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12,
          ),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:
            AppColors.surfaceAlt,
        selectedItemColor:
            AppColors.green,
        unselectedItemColor:
            Colors.black54,
        type:
            BottomNavigationBarType.fixed,
        elevation:
            2,
        showUnselectedLabels:
            true,
      ),

      dividerTheme: const DividerThemeData(
        color:
            AppColors.divider,
        thickness:
            1,
      ),

      // Padrão verde para ElevatedButton (os azuis usamos passando
      // backgroundColor: AppColors.blue onde necessário)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.green,
          foregroundColor:
              Colors.white,
          minimumSize: const Size.fromHeight(
            48,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),

      // Campos de formulário padrão com borda discreta
      inputDecorationTheme: InputDecorationTheme(
        filled:
            true,
        fillColor:
            AppColors.surface,
        isDense:
            true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal:
              12,
          vertical:
              12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12,
          ),
          borderSide: const BorderSide(
            color:
                Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12,
          ),
          borderSide: const BorderSide(
            color:
                Colors.black12,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(
              12,
            ),
          ),
          borderSide: BorderSide(
            color:
                AppColors.green,
            width:
                2,
          ),
        ),
      ),
    );

    return MaterialApp(
      title:
          'SmartGreen',
      debugShowCheckedModeBanner:
          false,
      theme:
          theme,
      home:
          const LoginScreen(),
      routes: {
        '/catalog':
            (
              _,
            ) =>
                const CatalogPage(),
        '/homepage':
            (
              _,
            ) =>
                const HomePage(),
      },
    );
  }
}
