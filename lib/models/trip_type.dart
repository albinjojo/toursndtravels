enum TripType {
  first,
  second;

  String get label {
    switch (this) {
      case TripType.first:
        return 'FIRST';
      case TripType.second:
        return 'SECOND';
    }
  }

  static TripType? fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'FIRST':
        return TripType.first;
      case 'SECOND':
        return TripType.second;
      default:
        return null;
    }
  }
}
