/// Annotation for available API on native platforms.
///
/// You can add `NativeAvailable` above your interface:
/// ```
/// @NativeAvailable(ios: '11.0')
/// ```
class NativeAvailable {
  final String ios;
  final String macos;
  final String tvos;
  final String watchos;
  final String android;
  const NativeAvailable(
      {this.ios, this.macos, this.tvos, this.watchos, this.android});
}

/// Type for unavailable platforms.
class NativePlatform {
  const NativePlatform();
}

const NativePlatform ios = const NativePlatform();
const NativePlatform macos = const NativePlatform();
const NativePlatform tvos = const NativePlatform();
const NativePlatform watchos = const NativePlatform();
const NativePlatform android = const NativePlatform();

/// Annotation for unavailable API on native platforms.
///
/// You can mark three [NativePlatform] at most.
class NativeUnavailable {
  const NativeUnavailable(NativePlatform p0,
      [NativePlatform p1, NativePlatform p2]);
}

/// Annotation for deprecated API on native platforms.
///
/// When you make some API deprecated, scope of available versions on each
/// platform is required. For example:
/// ```
/// @NativeDeprecated(ios: ['10.0', '10.4'])
/// ```
class NativeDeprecated {
  final List<String> ios;
  final List<String> macos;
  final List<String> tvos;
  final List<String> watchos;
  final List<String> android;
  const NativeDeprecated(String message,
      {this.ios, this.macos, this.tvos, this.watchos, this.android});
}

mixin _ToAlias {}

const String API_TO_BE_DEPRECATED = 'API_TO_BE_DEPRECATED';

class NativeDeprecatedReplacement = NativeDeprecated with _ToAlias;
