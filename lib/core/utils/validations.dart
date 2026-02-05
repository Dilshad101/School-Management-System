class Validations {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validateOptionalEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Contact number is required';
    }

    /// indian phone number regex
    final phoneRegExp = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid contact number';
    }
    return null;
  }

  static String? validateOptionalPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    /// indian phone number regex
    final phoneRegExp = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid contact number';
    }
    return null;
  }

  static String? validateNumber(
    String? value,
    String fieldName, [
    bool decimal = false,
  ]) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final numberRegExp = RegExp(decimal ? r'^[0-9]+(\.[0-9]+)?$' : r'^[0-9]+$');
    if (!numberRegExp.hasMatch(value)) {
      return 'Please enter a valid number for $fieldName';
    }
    return null;
  }

  static String? validateOptionalNumber(
    String? value,
    String fieldName, [
    bool decimal = false,
  ]) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final numberRegExp = RegExp(decimal ? r'^[0-9]+(\.[0-9]+)?$' : r'^[0-9]+$');
    if (!numberRegExp.hasMatch(value)) {
      return 'Please enter a valid number for $fieldName';
    }
    return null;
  }

  static String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
