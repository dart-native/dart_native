class NativeAvailable {
  final String ios;
  final String macos;
  final String tvos;
  final String watchos;
  final String android;
  const NativeAvailable({this.ios, this.macos, this.tvos, this.watchos, this.android});
}

class NativeUnavailable {
  final String ios;
  final String macos;
  final String tvos;
  final String watchos;
  final String android;
  const NativeUnavailable({this.ios, this.macos, this.tvos, this.watchos, this.android});
}

class NativeDeprecated {
  final List<String> ios;
  final List<String> macos;
  final List<String> tvos;
  final List<String> watchos;
  final List<String> android;
  const NativeDeprecated(String message, {this.ios, this.macos, this.tvos, this.watchos, this.android});
}