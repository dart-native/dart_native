class NativeBox<T> {
  final T raw;
  const NativeBox(this.raw);

  @override
  bool operator ==(other) {
    if (other is T) {
      return raw == other;
    }
    if (other is NativeBox) {
      return raw == other.raw;
    }
    return false;
  }

  @override
  int get hashCode => raw.hashCode;

  @override
  String toString() {
    return raw.toString();
  }
}
