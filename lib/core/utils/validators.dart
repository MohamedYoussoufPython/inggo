class Validators {
  Validators._();

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro de téléphone requis';
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 8) {
      return 'Le numéro doit contenir 8 chiffres';
    }
    if (!cleaned.startsWith(RegExp(r'^7[0-9]'))) {
      return 'Numéro invalide (commence par 77, 78...)';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nom requis';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Code requis';
    }
    if (value.length != 6) {
      return 'Le code doit contenir 6 chiffres';
    }
    return null;
  }

  static String? validatePlateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Numéro de plaque requis';
    }
    return null;
  }

  static String? validateRequired(String? value, [String field = 'Ce champ']) {
    if (value == null || value.trim().isEmpty) {
      return '$field est requis';
    }
    return null;
  }
}
