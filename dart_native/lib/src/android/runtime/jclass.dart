class JClass extends Comparable<dynamic> {
  String _className;

  JClass(this._className);
  String get className => _className;

  @override
  int compareTo(other) {
    if (other is JClass && other._className == _className) {
      return 0;
    }
    return 1;
  }
}
