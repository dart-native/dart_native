/// Annotation for available API on native platforms.
///
/// You can add `NativeAvailable` above your interface:
/// ```
/// @NativeAvailable(ios: '11.0')
/// ```
class NativeAvailable {
  final String? ios;
  final String? macos;
  final String? tvos;
  final String? watchos;
  final String? android;
  const NativeAvailable(
      {this.ios, this.macos, this.tvos, this.watchos, this.android});
}

/// Type for unavailable platforms.
class NativePlatform {
  const NativePlatform();
}

const NativePlatform ios = NativePlatform();
const NativePlatform macos = NativePlatform();
const NativePlatform tvos = NativePlatform();
const NativePlatform watchos = NativePlatform();
const NativePlatform android = NativePlatform();

/// Annotation for unavailable API on native platforms.
///
/// You can mark three [NativePlatform] at most.
class NativeUnavailable {
  const NativeUnavailable(NativePlatform p0,
      [NativePlatform? p1, NativePlatform? p2]);
}

/// Annotation for deprecated API on native platforms.
///
/// When you make some API deprecated, scope of available versions on each
/// platform is required. For example:
/// ```
/// @NativeDeprecated(ios: ['10.0', '10.4'])
/// ```
class NativeDeprecated {
  final List<String>? ios;
  final List<String>? macos;
  final List<String>? tvos;
  final List<String>? watchos;
  final List<String>? android;
  const NativeDeprecated(String message,
      {this.ios, this.macos, this.tvos, this.watchos, this.android});
}

// ignore: constant_identifier_names
const String API_TO_BE_DEPRECATED = 'API_TO_BE_DEPRECATED';

typedef NativeDeprecatedReplacement = NativeDeprecated;
