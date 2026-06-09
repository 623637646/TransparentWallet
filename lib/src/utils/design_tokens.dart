import 'package:flutter/material.dart';
import 'package:janus_wallet/src/rust/api/app_mode.dart';

/// Centralized design tokens governing colors, spacing, typography,
/// border radius, and component-specific styling matching DESIGN.md.
class DesignTokens {
  final AppMode mode;
  final ColorTokens colors;
  final ComponentTokens components;

  DesignTokens._(this.mode, this.colors) : components = ComponentTokens(colors);

  /// Resolves the design tokens configuration for the given [AppMode].
  ///
  /// [AppMode.hotWallet] maps to the warm Airbnb Rausch palette.
  /// [AppMode.coldWallet] and [AppMode.init] map to the cosmic monochrome xAI palette.
  factory DesignTokens.of(AppMode mode) {
    switch (mode) {
      case AppMode.hotWallet:
        return DesignTokens._(mode, ColorTokens.hot);
      case AppMode.coldWallet:
      case AppMode.init:
        return DesignTokens._(mode, ColorTokens.cold);
    }
  }

  // Constant design tokens independent of application mode
  static const SpacingTokens spacing = SpacingTokens();
  static const RoundedTokens rounded = RoundedTokens();
  static const TypographyTokens typography = TypographyTokens();
}

/// Constant spacing tokens following the 8px base grid system.
class SpacingTokens {
  const SpacingTokens();

  final double xxs = 4.0;
  final double xs = 8.0;
  final double sm = 12.0;
  final double md = 17.0;
  final double lg = 24.0;
  final double xl = 32.0;
  final double xxl = 48.0;
  final double section = 80.0;
}

/// Constant border radius tokens.
class RoundedTokens {
  const RoundedTokens();

  final BorderRadius none = BorderRadius.zero;
  final BorderRadius xs = const BorderRadius.all(Radius.circular(5.0));
  final BorderRadius sm = const BorderRadius.all(Radius.circular(8.0));
  final BorderRadius md = const BorderRadius.all(Radius.circular(11.0));
  final BorderRadius lg = const BorderRadius.all(Radius.circular(18.0));
  final BorderRadius pill = const BorderRadius.all(Radius.circular(9999.0));
  final BorderRadius full = const BorderRadius.all(Radius.circular(9999.0));
}

/// Color tokens resolved dynamically based on wallet mode.
class ColorTokens {
  // Hot Wallet (Airbnb Rausch)
  static const ColorTokens hot = ColorTokens(
    primary: Color(0xFFFF385C),
    primaryFocus: Color(0xFFE00B41),
    primaryOnDark: Color(0xFFFF385C),
    ink: Color(0xFF222222),
    body: Color(0xFF3F3F3F),
    bodyOnDark: Color(0xFFFFFFFF),
    bodyMuted: Color(0xFF6A6A6A),
    inkMuted80: Color(0xFF3F3F3F),
    inkMuted48: Color(0xFF929292),
    dividerSoft: Color(0xFFEBEBEB),
    hairline: Color(0xFFDDDDDD),
    canvas: Color(0xFFFFFFFF),
    canvasParchment: Color(0xFFF7F7F7),
    surfacePearl: Color(0xFFFAFAFC),
    surfaceTile1: Color(0xFFF7F7F7),
    surfaceTile2: Color(0xFFF2F2F2),
    surfaceTile3: Color(0xFFEBEBEB),
    surfaceBlack: Color(0xFF222222),
    surfaceChipTranslucent: Color(0xFFDDDDDD),
    onPrimary: Color(0xFFFFFFFF),
    onDark: Color(0xFFFFFFFF),
  );

  // Cold / Unselected (xAI Cosmic Monochrome)
  static const ColorTokens cold = ColorTokens(
    primary: Color(0xFFFFFFFF),
    primaryFocus: Color(0xFFFAFAF7),
    primaryOnDark: Color(0xFFFFFFFF),
    ink: Color(0xFFFFFFFF),
    body: Color(0xFFDADBDF),
    bodyOnDark: Color(0xFFFFFFFF),
    bodyMuted: Color(0xFF7D8187),
    inkMuted80: Color(0xFFDADBDF),
    inkMuted48: Color(0xFF7D8187),
    dividerSoft: Color(0xFF212327),
    hairline: Color(0xFF212327),
    canvas: Color(0xFF0A0A0A),
    canvasParchment: Color(0xFF1A1C20),
    surfacePearl: Color(0xFF191919),
    surfaceTile1: Color(0xFF191919),
    surfaceTile2: Color(0xFF1A1C20),
    surfaceTile3: Color(0xFF0D1726),
    surfaceBlack: Color(0xFF0A0A0A),
    surfaceChipTranslucent: Color(0xFF363A3F),
    onPrimary: Color(0xFF0A0A0A),
    onDark: Color(0xFFFFFFFF),
  );

  final Color primary;
  final Color primaryFocus;
  final Color primaryOnDark;
  final Color ink;
  final Color body;
  final Color bodyOnDark;
  final Color bodyMuted;
  final Color inkMuted80;
  final Color inkMuted48;
  final Color dividerSoft;
  final Color hairline;
  final Color canvas;
  final Color canvasParchment;
  final Color surfacePearl;
  final Color surfaceTile1;
  final Color surfaceTile2;
  final Color surfaceTile3;
  final Color surfaceBlack;
  final Color surfaceChipTranslucent;
  final Color onPrimary;
  final Color onDark;

  const ColorTokens({
    required this.primary,
    required this.primaryFocus,
    required this.primaryOnDark,
    required this.ink,
    required this.body,
    required this.bodyOnDark,
    required this.bodyMuted,
    required this.inkMuted80,
    required this.inkMuted48,
    required this.dividerSoft,
    required this.hairline,
    required this.canvas,
    required this.canvasParchment,
    required this.surfacePearl,
    required this.surfaceTile1,
    required this.surfaceTile2,
    required this.surfaceTile3,
    required this.surfaceBlack,
    required this.surfaceChipTranslucent,
    required this.onPrimary,
    required this.onDark,
  });
}

/// Constant typography tokens based on SF Pro Display and SF Pro Text.
class TypographyTokens {
  const TypographyTokens();

  static const List<String> sfProFallback = [
    'system-ui',
    '-apple-system',
    'sans-serif',
  ];

  final TextStyle heroDisplay = const TextStyle(
    fontFamily: 'SF Pro Display',
    fontFamilyFallback: sfProFallback,
    fontSize: 56.0,
    fontWeight: FontWeight.w600,
    height: 1.07,
    letterSpacing: -0.28,
  );

  final TextStyle displayLg = const TextStyle(
    fontFamily: 'SF Pro Display',
    fontFamilyFallback: sfProFallback,
    fontSize: 40.0,
    fontWeight: FontWeight.w600,
    height: 1.10,
    letterSpacing: 0.0,
  );

  final TextStyle displayMd = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 34.0,
    fontWeight: FontWeight.w600,
    height: 1.47,
    letterSpacing: -0.374,
  );

  final TextStyle lead = const TextStyle(
    fontFamily: 'SF Pro Display',
    fontFamilyFallback: sfProFallback,
    fontSize: 28.0,
    fontWeight: FontWeight.w400,
    height: 1.14,
    letterSpacing: 0.196,
  );

  final TextStyle leadAiry = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 24.0,
    fontWeight: FontWeight.w300,
    height: 1.50,
    letterSpacing: 0.0,
  );

  final TextStyle tagline = const TextStyle(
    fontFamily: 'SF Pro Display',
    fontFamilyFallback: sfProFallback,
    fontSize: 21.0,
    fontWeight: FontWeight.w600,
    height: 1.19,
    letterSpacing: 0.231,
  );

  final TextStyle bodyStrong = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 17.0,
    fontWeight: FontWeight.w600,
    height: 1.24,
    letterSpacing: -0.374,
  );

  final TextStyle body = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    height: 1.47,
    letterSpacing: -0.374,
  );

  final TextStyle denseLink = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 17.0,
    fontWeight: FontWeight.w400,
    height: 2.41,
    letterSpacing: 0.0,
  );

  final TextStyle caption = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: -0.224,
  );

  final TextStyle captionStrong = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: -0.224,
  );

  final TextStyle buttonLarge = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 18.0,
    fontWeight: FontWeight.w300,
    height: 1.00,
    letterSpacing: 0.0,
  );

  final TextStyle buttonUtility = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 1.29,
    letterSpacing: -0.224,
  );

  final TextStyle finePrint = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.00,
    letterSpacing: -0.12,
  );

  final TextStyle microLegal = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 10.0,
    fontWeight: FontWeight.w400,
    height: 1.30,
    letterSpacing: -0.08,
  );

  final TextStyle navLink = const TextStyle(
    fontFamily: 'SF Pro Text',
    fontFamilyFallback: sfProFallback,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    height: 1.00,
    letterSpacing: -0.12,
  );
}

/// Button-specific style tokens.
class ButtonStyleTokens {
  final Color backgroundColor;
  final Color textColor;
  final TextStyle typography;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double? size;
  final BorderSide? border;

  const ButtonStyleTokens({
    required this.backgroundColor,
    required this.textColor,
    required this.typography,
    required this.borderRadius,
    required this.padding,
    this.size,
    this.border,
  });
}

/// Text link-specific style tokens.
class TextLinkTokens {
  final Color backgroundColor;
  final Color textColor;
  final TextStyle typography;

  const TextLinkTokens({
    required this.backgroundColor,
    required this.textColor,
    required this.typography,
  });
}

/// Global navigation bar style tokens.
class GlobalNavTokens {
  final Color backgroundColor;
  final Color textColor;
  final TextStyle typography;
  final double height;

  const GlobalNavTokens({
    required this.backgroundColor,
    required this.textColor,
    required this.typography,
    required this.height,
  });
}

/// Product-specific frosted sub-navigation style tokens.
class SubNavFrostedTokens {
  final Color backgroundColor;
  final Color textColor;
  final TextStyle typography;
  final double height;

  const SubNavFrostedTokens({
    required this.backgroundColor,
    required this.textColor,
    required this.typography,
    required this.height,
  });
}

/// Product tile section style tokens.
class ProductTileTokens {
  final Color backgroundColor;
  final Color textColor;
  final TextStyle? typography;
  final BorderRadius borderRadius;
  final EdgeInsets padding;

  const ProductTileTokens({
    required this.backgroundColor,
    required this.textColor,
    this.typography,
    required this.borderRadius,
    required this.padding,
  });
}

/// Store grid utility card style tokens.
class StoreUtilityCardTokens {
  final Color backgroundColor;
  final Color textColor;
  final TextStyle typography;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final BorderSide border;

  const StoreUtilityCardTokens({
    required this.backgroundColor,
    required this.textColor,
    required this.typography,
    required this.borderRadius,
    required this.padding,
    required this.border,
  });
}

/// Configurator option chip style tokens.
class ConfiguratorOptionChipTokens {
  final Color backgroundColor;
  final Color textColor;
  final TextStyle typography;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final BorderSide? border;

  const ConfiguratorOptionChipTokens({
    required this.backgroundColor,
    required this.textColor,
    required this.typography,
    required this.borderRadius,
    required this.padding,
    this.border,
  });
}

/// Search input style tokens.
class SearchInputTokens {
  final Color backgroundColor;
  final Color textColor;
  final TextStyle typography;
  final BorderRadius borderRadius;
  final EdgeInsets padding;
  final double height;
  final BorderSide border;

  const SearchInputTokens({
    required this.backgroundColor,
    required this.textColor,
    required this.typography,
    required this.borderRadius,
    required this.padding,
    required this.height,
    required this.border,
  });
}

/// Scroll-activated floating sticky bar style tokens.
class FloatingStickyBarTokens {
  final Color backgroundColor;
  final Color textColor;
  final TextStyle typography;
  final double height;
  final EdgeInsets padding;

  const FloatingStickyBarTokens({
    required this.backgroundColor,
    required this.textColor,
    required this.typography,
    required this.height,
    required this.padding,
  });
}

/// Footer area style tokens.
class FooterTokens {
  final Color backgroundColor;
  final Color textColor;
  final TextStyle typography;
  final EdgeInsets padding;

  const FooterTokens({
    required this.backgroundColor,
    required this.textColor,
    required this.typography,
    required this.padding,
  });
}

/// Component tokens resolved dynamically based on color tokens.
class ComponentTokens {
  final ColorTokens colors;

  const ComponentTokens(this.colors);

  ButtonStyleTokens get buttonPrimary => ButtonStyleTokens(
    backgroundColor: colors.primary,
    textColor: colors.onPrimary,
    typography: DesignTokens.typography.body,
    borderRadius: DesignTokens.rounded.pill,
    padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 22.0),
  );

  ButtonStyleTokens get buttonPrimaryFocus => ButtonStyleTokens(
    backgroundColor: colors.primary,
    textColor: colors.onPrimary,
    typography: DesignTokens.typography.body,
    borderRadius: DesignTokens.rounded.pill,
    padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 22.0),
    border: BorderSide(color: colors.primaryFocus, width: 2.0),
  );

  ButtonStyleTokens get buttonPrimaryActive => ButtonStyleTokens(
    backgroundColor: colors.primary,
    textColor: colors.onPrimary,
    typography: DesignTokens.typography.body,
    borderRadius: DesignTokens.rounded.pill,
    padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 22.0),
  );

  ButtonStyleTokens get buttonSecondaryPill => ButtonStyleTokens(
    backgroundColor: Colors.transparent,
    textColor: colors.primary,
    typography: DesignTokens.typography.body,
    borderRadius: DesignTokens.rounded.pill,
    padding: const EdgeInsets.symmetric(vertical: 11.0, horizontal: 22.0),
    border: BorderSide(color: colors.primary, width: 1.0),
  );

  ButtonStyleTokens get buttonDarkUtility => ButtonStyleTokens(
    backgroundColor: colors.ink,
    textColor: colors.onDark,
    typography: DesignTokens.typography.buttonUtility,
    borderRadius: DesignTokens.rounded.sm,
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
  );

  ButtonStyleTokens get buttonPearlCapsule => ButtonStyleTokens(
    backgroundColor: colors.surfacePearl,
    textColor: colors.inkMuted80,
    typography: DesignTokens.typography.caption,
    borderRadius: DesignTokens.rounded.md,
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
    border: BorderSide(color: colors.dividerSoft, width: 3.0),
  );

  ButtonStyleTokens get buttonStoreHero => ButtonStyleTokens(
    backgroundColor: colors.primary,
    textColor: colors.onPrimary,
    typography: DesignTokens.typography.buttonLarge,
    borderRadius: DesignTokens.rounded.pill,
    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
  );

  ButtonStyleTokens get buttonIconCircular => ButtonStyleTokens(
    backgroundColor: colors.surfaceChipTranslucent,
    textColor: colors.ink,
    typography: DesignTokens.typography.caption,
    borderRadius: DesignTokens.rounded.full,
    padding: EdgeInsets.zero,
    size: 44.0,
  );

  TextLinkTokens get textLink => TextLinkTokens(
    backgroundColor: Colors.transparent,
    textColor: colors.primary,
    typography: DesignTokens.typography.body,
  );

  TextLinkTokens get textLinkOnDark => TextLinkTokens(
    backgroundColor: Colors.transparent,
    textColor: colors.primaryOnDark,
    typography: DesignTokens.typography.body,
  );

  GlobalNavTokens get globalNav => GlobalNavTokens(
    backgroundColor: colors.surfaceBlack,
    textColor: colors.onDark,
    typography: DesignTokens.typography.navLink,
    height: 44.0,
  );

  SubNavFrostedTokens get subNavFrosted => SubNavFrostedTokens(
    backgroundColor: colors.canvasParchment.withValues(alpha: 0.80),
    textColor: colors.ink,
    typography: DesignTokens.typography.tagline,
    height: 52.0,
  );

  ProductTileTokens get productTileLight => ProductTileTokens(
    backgroundColor: colors.canvas,
    textColor: colors.ink,
    typography: DesignTokens.typography.displayLg,
    borderRadius: DesignTokens.rounded.none,
    padding: const EdgeInsets.symmetric(vertical: 80.0),
  );

  ProductTileTokens get productTileParchment => ProductTileTokens(
    backgroundColor: colors.canvasParchment,
    textColor: colors.ink,
    typography: DesignTokens.typography.displayLg,
    borderRadius: DesignTokens.rounded.none,
    padding: const EdgeInsets.symmetric(vertical: 80.0),
  );

  ProductTileTokens get productTileDark => ProductTileTokens(
    backgroundColor: colors.surfaceTile1,
    textColor: colors.onDark,
    typography: DesignTokens.typography.displayLg,
    borderRadius: DesignTokens.rounded.none,
    padding: const EdgeInsets.symmetric(vertical: 80.0),
  );

  ProductTileTokens get productTileDark2 => ProductTileTokens(
    backgroundColor: colors.surfaceTile2,
    textColor: colors.onDark,
    borderRadius: DesignTokens.rounded.none,
    padding: const EdgeInsets.symmetric(vertical: 80.0),
  );

  ProductTileTokens get productTileDark3 => ProductTileTokens(
    backgroundColor: colors.surfaceTile3,
    textColor: colors.onDark,
    borderRadius: DesignTokens.rounded.none,
    padding: const EdgeInsets.symmetric(vertical: 80.0),
  );

  StoreUtilityCardTokens get storeUtilityCard => StoreUtilityCardTokens(
    backgroundColor: colors.canvas,
    textColor: colors.ink,
    typography: DesignTokens.typography.bodyStrong,
    borderRadius: DesignTokens.rounded.lg,
    padding: const EdgeInsets.all(24.0),
    border: BorderSide(color: colors.hairline, width: 1.0),
  );

  ConfiguratorOptionChipTokens get configuratorOptionChip =>
      ConfiguratorOptionChipTokens(
        backgroundColor: colors.canvas,
        textColor: colors.ink,
        typography: DesignTokens.typography.caption,
        borderRadius: DesignTokens.rounded.pill,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      );

  ConfiguratorOptionChipTokens get configuratorOptionChipSelected =>
      ConfiguratorOptionChipTokens(
        backgroundColor: colors.canvas,
        textColor: colors.ink,
        typography: DesignTokens.typography.caption,
        borderRadius: DesignTokens.rounded.pill,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        border: BorderSide(color: colors.primaryFocus, width: 2.0),
      );

  SearchInputTokens get searchInput => SearchInputTokens(
    backgroundColor: colors.canvas,
    textColor: colors.ink,
    typography: DesignTokens.typography.body,
    borderRadius: DesignTokens.rounded.pill,
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
    height: 44.0,
    border: BorderSide(color: colors.dividerSoft, width: 1.0),
  );

  FloatingStickyBarTokens get floatingStickyBar => FloatingStickyBarTokens(
    backgroundColor: colors.canvasParchment.withValues(alpha: 0.80),
    textColor: colors.ink,
    typography: DesignTokens.typography.body,
    height: 64.0,
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
  );

  ProductTileTokens get environmentQuoteCard => ProductTileTokens(
    backgroundColor: colors.surfaceTile1,
    textColor: colors.onDark,
    typography: DesignTokens.typography.displayLg,
    borderRadius: DesignTokens.rounded.none,
    padding: const EdgeInsets.symmetric(vertical: 80.0),
  );

  FooterTokens get footer => FooterTokens(
    backgroundColor: colors.canvasParchment,
    textColor: colors.inkMuted80,
    typography: DesignTokens.typography.finePrint,
    padding: const EdgeInsets.all(64.0),
  );
}

class DesignTheme extends InheritedWidget {
  final DesignTokens tokens;

  const DesignTheme({super.key, required this.tokens, required super.child});

  static DesignTokens of(BuildContext context) {
    final DesignTheme? result = context
        .dependOnInheritedWidgetOfExactType<DesignTheme>();
    assert(result != null, 'No DesignTheme found in context');
    return result!.tokens;
  }

  @override
  bool updateShouldNotify(DesignTheme oldWidget) => tokens != oldWidget.tokens;
}
