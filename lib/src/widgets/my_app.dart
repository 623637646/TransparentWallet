import 'package:flutter/material.dart';
import '../rust/api/app_mode.dart';
import '../rust/utils/never.dart';
import '../utils/app_context.dart';
import '../utils/bridge_helper.dart';
import '../utils/design_tokens.dart';
import 'onboarding_screen.dart';
import 'cold_wallet_home.dart';
import 'hot_wallet_home.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<AppMode> _appModeStream;

  @override
  void initState() {
    super.initState();
    _appModeStream = convertSubscriptionToStream<AppMode, BridgeNever>((
      onNext,
      onTermination,
    ) {
      return appContext.appModeStream(
        onNext: onNext,
        onTermination: onTermination,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppMode>(
      stream: _appModeStream,
      builder: (context, snapshot) {
        final mode = snapshot.data ?? AppMode.init;
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
                if (snapshot.hasError) {
                  return Scaffold(
                    backgroundColor: tokens.colors.canvas,
                    body: Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          color: tokens.colors.ink,
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  // Loading/Splash state
                  return Scaffold(
                    backgroundColor: tokens.colors.canvas,
                    body: Center(
                      child: CircularProgressIndicator(
                        color: tokens.colors.primary,
                      ),
                    ),
                  );
                }

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

