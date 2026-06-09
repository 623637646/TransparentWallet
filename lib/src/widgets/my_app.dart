import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../rust/api/app_mode.dart';
import '../rust/utils/never.dart';
import '../utils/app_context.dart';
import '../utils/design_tokens.dart';
import 'common/rust_stream_builder.dart';
import 'onboarding_screen.dart';
import 'cold_wallet_home.dart';
import 'hot_wallet_home.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(appContextProvider);
    final initialTokens = DesignTokens.of(AppMode.init);

    return contextAsync.when(
      skipLoadingOnRefresh: false,
      loading: () => _buildApp(
        tokens: initialTokens,
        home: Scaffold(
          backgroundColor: initialTokens.colors.canvas,
          body: Center(
            child: CircularProgressIndicator(
              color: initialTokens.colors.primary,
            ),
          ),
        ),
      ),
      error: (error, stack) => _buildApp(
        tokens: initialTokens,
        home: Scaffold(
          backgroundColor: initialTokens.colors.canvas,
          body: Center(
            child: Text(
              'Failed to initialize app: $error',
              style: DesignTokens.typography.body.copyWith(
                color: initialTokens.colors.ink,
              ),
            ),
          ),
        ),
      ),
      data: (rustContext) {
        return RustStreamBuilder<AppMode, BridgeNever>(
          subscriptionBuilder: (rustContext, onNext, onTermination) =>
              rustContext.appModeStream(
                onNext: onNext,
                onTermination: onTermination,
              ),
          loadingBuilder: (context) => _buildApp(
            tokens: initialTokens,
            home: Scaffold(
              backgroundColor: initialTokens.colors.canvas,
              body: Center(
                child: CircularProgressIndicator(
                  color: initialTokens.colors.primary,
                ),
              ),
            ),
          ),
          errorBuilder: (context, error) => _buildApp(
            tokens: initialTokens,
            home: Scaffold(
              backgroundColor: initialTokens.colors.canvas,
              body: Center(
                child: Text(
                  'Error: $error',
                  style: DesignTokens.typography.body.copyWith(
                    color: initialTokens.colors.ink,
                  ),
                ),
              ),
            ),
          ),
          builder: (context, mode) {
            final tokens = DesignTokens.of(mode);

            return _buildApp(
              tokens: tokens,
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
            );
          },
        );
      },
    );
  }

  Widget _buildApp({required DesignTokens tokens, required Widget home}) {
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
        home: home,
      ),
    );
  }
}
