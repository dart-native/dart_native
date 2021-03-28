class Class extends Comparable<dynamic> {
  String _className;

  Class(this._className);
  String get className => _className;

  @override
  int compareTo(other) {
    if (other is Class && other._className == _className) {
      return 0;
    }
    return 1;
  }
}
