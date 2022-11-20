// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/trading_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trading/app/colors.dart';
import 'package:trading/app/home.dart';
import 'package:trading/app/login.dart';
import 'package:trading/app/models.dart';
import 'package:trading/app/routes.dart' as routes;
import 'package:trading/data/gallery_options.dart';
import 'package:trading/layout/letter_spacing.dart';

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  static const String loginRoute = routes.loginRoute;
  static const String homeRoute = routes.homeRoute;

  final sharedZAxisTransitionBuilder = const SharedAxisPageTransitionsBuilder(
    fillColor: TradingColors.primaryBackground,
    transitionType: SharedAxisTransitionType.scaled,
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserModel(),
      child: MaterialApp(
        restorationScopeId: 'trading_app',
        title: 'Trading',
        debugShowCheckedModeBanner: false,
        theme: _buildTradingTheme().copyWith(
          platform: GalleryOptions.of(context).platform,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              for (var type in TargetPlatform.values)
                type: sharedZAxisTransitionBuilder,
            },
          ),
        ),
        localizationsDelegates: TradingLocalizations.localizationsDelegates,
        supportedLocales: TradingLocalizations.supportedLocales,
        locale: GalleryOptions.of(context).locale,
        initialRoute: loginRoute,
        routes: <String, WidgetBuilder>{
          homeRoute: (context) => Consumer<UserModel>(
            builder: (context, user, child) {
              return HomePage(user: user);
            }
          ),
          loginRoute: (context) => const LoginPage(),
        },
      ),
    );
  }

  ThemeData _buildTradingTheme() {
    final base = ThemeData.dark();
    return ThemeData(
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: TradingColors.primaryBackground,
        elevation: 0,
      ),
      scaffoldBackgroundColor: TradingColors.primaryBackground,
      focusColor: TradingColors.focusColor,
      textTheme: _buildTradingTextTheme(base.textTheme),
      inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(
          color: TradingColors.gray,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: TradingColors.inputBackground,
        focusedBorder: InputBorder.none,
      ),
      visualDensity: VisualDensity.standard,
      colorScheme: base.colorScheme.copyWith(
        primary: TradingColors.primaryBackground,
      ),
    );
  }

  TextTheme _buildTradingTextTheme(TextTheme base) {
    return base
        .copyWith(
          bodyMedium: GoogleFonts.robotoCondensed(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: letterSpacingOrNone(0.5),
          ),
          bodyLarge: GoogleFonts.eczar(
            fontSize: 40,
            fontWeight: FontWeight.w400,
            letterSpacing: letterSpacingOrNone(1.4),
          ),
          labelLarge: GoogleFonts.robotoCondensed(
            fontWeight: FontWeight.w700,
            letterSpacing: letterSpacingOrNone(2.8),
          ),
          headlineSmall: GoogleFonts.eczar(
            fontSize: 40,
            fontWeight: FontWeight.w600,
            letterSpacing: letterSpacingOrNone(1.4),
          ),
        )
        .apply(
          displayColor: Colors.black,
          bodyColor: Colors.black,
        );
  }
}
