class NativeAvailable {
  final String ios;
  final String macos;
  final String tvos;
  final String watchos;
  final String android;
  const NativeAvailable({this.ios, this.macos, this.tvos, this.watchos, this.android});
}

class NativePlatform {
  const NativePlatform();
}

const NativePlatform ios = const NativePlatform();
const NativePlatform macos = const NativePlatform();
const NativePlatform tvos = const NativePlatform();
const NativePlatform watchos = const NativePlatform();
const NativePlatform android = const NativePlatform();

class NativeUnavailable {
  const NativeUnavailable(NativePlatform p0, [NativePlatform p1, NativePlatform p2]);
}

class NativeDeprecated {
  final List<String> ios;
  final List<String> macos;
  final List<String> tvos;
  final List<String> watchos;
  final List<String> android;
  const NativeDeprecated(String message, {this.ios, this.macos, this.tvos, this.watchos, this.android});
}