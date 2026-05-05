extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  String get cleanPhone => replaceAll(RegExp(r'[^\d]'), '');

  bool get isValidPhone {
    final cleaned = cleanPhone;
    return cleaned.length == 8 && cleaned.startsWith(RegExp(r'^7[0-9]'));
  }

  bool get isNotEmptyString => trim().isNotEmpty;

  String get truncate {
    if (length <= 30) return this;
    return '${substring(0, 27)}...';
  }
}
