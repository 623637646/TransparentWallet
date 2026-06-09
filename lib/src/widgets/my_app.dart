import 'package:flutter/material.dart';
import '../rust/api/app_mode.dart';
import '../rust/utils/never.dart';
import '../utils/design_tokens.dart';
import 'common/rust_stream_builder.dart';
import 'onboarding_screen.dart';
import 'cold_wallet_home.dart';
import 'hot_wallet_home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialTokens = DesignTokens.of(AppMode.init);

    return RustStreamBuilder<AppMode, BridgeNever>(
      subscriptionBuilder: (rustContext, onNext, onTermination) =>
          rustContext.appModeStream(
        onNext: onNext,
        onTermination: onTermination,
      ),
      loadingBuilder: (context) => Scaffold(
        backgroundColor: initialTokens.colors.canvas,
        body: Center(
          child: CircularProgressIndicator(
            color: initialTokens.colors.primary,
          ),
        ),
      ),
      errorBuilder: (context, error) => Scaffold(
        backgroundColor: initialTokens.colors.canvas,
        body: Center(
          child: Text(
            'Error: $error',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              color: initialTokens.colors.ink,
            ),
          ),
        ),
      ),
      builder: (context, mode) {
        final tokens = DesignTokens.of(mode);

        return DesignTheme(
          tokens: tokens,
          child: MaterialApp(
            title: 'Janus Wallet',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Inter',
              colorScheme: ColorScheme.fromSeed(
                seedColor: tokens.colors.primary,
                primary: tokens.colors.primary,
                surface: tokens.colors.canvas,
              ),
              useMaterial3: true,
            ),
            home: Builder(
              builder: (context) {
                switch (mode) {
                  case AppMode.init:
                    return const OnboardingScreen();
                  case AppMode.coldWallet:
                    return const ColdWalletHome();
                  case AppMode.hotWallet:
                    return const HotWalletHome();
                }
              },
            ),
          ),
        );
      },
    );
  }
}

