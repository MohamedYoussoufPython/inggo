class Validators {
  Validators._();

  static String? validatePhone(String? value, {String? requiredMsg, String? lengthMsg, String? formatMsg}) {
    if (value == null || value.isEmpty) {
      return requiredMsg ?? 'Numéro de téléphone requis';
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 8) {
      return lengthMsg ?? 'Le numéro doit contenir 8 chiffres';
    }
    if (!cleaned.startsWith(RegExp(r'^7[0-9]'))) {
      return formatMsg ?? 'Numéro invalide (commence par 77, 78...)';
    }
    return null;
  }

  static String? validateName(String? value, {String? requiredMsg, String? lengthMsg}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? 'Nom requis';
    }
    if (value.trim().length < 2) {
      return lengthMsg ?? 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  static String? validateOtp(String? value, {String? requiredMsg, String? lengthMsg}) {
    if (value == null || value.isEmpty) {
      return requiredMsg ?? 'Code requis';
    }
    if (value.length != 6) {
      return lengthMsg ?? 'Le code doit contenir 6 chiffres';
    }
    return null;
  }

  static String? validatePlateNumber(String? value, {String? requiredMsg}) {
    if (value == null || value.trim().isEmpty) {
      return requiredMsg ?? 'Numéro de plaque requis';
    }
    return null;
  }

  static String? validateRequired(String? value, {String? field, String? requiredMsg}) {
    if (value == null || value.trim().isEmpty) {
      final fieldName = field ?? 'Ce champ';
      return requiredMsg ?? '$fieldName est requis';
    }
    return null;
  }
}
