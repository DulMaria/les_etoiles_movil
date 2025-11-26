class ValidationResult {
  final bool isValid;
  final String error;

  ValidationResult({required this.isValid, required this.error});
}

class LoginValidations {
  /// Verifica si un texto tiene caracteres repetidos consecutivamente (más de 2 veces)
  static bool _hasExcessiveRepeatedChars(String text) {
    final repeatedPattern = RegExp(r'(.)\1{2,}');
    return repeatedPattern.hasMatch(text);
  }

  /// Verifica si un texto tiene espacios excesivos entre caracteres
  static bool _hasExcessiveSpacing(String text) {
    final spacingPattern = RegExp(r'^[a-zA-Z](\s+[a-zA-Z])+$');
    final multipleSpaces = RegExp(r'\s{2,}');
    
    return spacingPattern.hasMatch(text) || multipleSpaces.hasMatch(text);
  }

/// Verifica si el username tiene un formato válido
/// Permite solo: letras, números y puntos
static bool _isValidUsernameFormat(String username) {
  final validFormat = RegExp(r'^[a-zA-Z0-9.]+$');
  return validFormat.hasMatch(username);
}

  /// Valida que el campo usuario cumpla con todos los requisitos
  static ValidationResult validateUsuario(String usuario) {
    if (usuario.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: "El nombre de usuario es obligatorio",
      );
    }

    if (_hasExcessiveSpacing(usuario)) {
      return ValidationResult(
        isValid: false,
        error: "El nombre de usuario no puede tener espacios excesivos",
      );
    }

    if (usuario.trim().length < 3) {
      return ValidationResult(
        isValid: false,
        error: "El nombre de usuario debe tener al menos 3 caracteres legibles",
      );
    }

    if (usuario.length > 150) {
      return ValidationResult(
        isValid: false,
        error: "El nombre de usuario no puede exceder 150 caracteres",
      );
    }

      if (!_isValidUsernameFormat(usuario)) {
      return ValidationResult(
        isValid: false,
        error: "Solo se permiten letras, números y puntos",
      );
    }

    if (_hasExcessiveRepeatedChars(usuario)) {
      return ValidationResult(
        isValid: false,
        error: "No se permiten más de 2 caracteres iguales consecutivos",
      );
    }

    return ValidationResult(isValid: true, error: "");
  }

  /// Valida que el campo password cumpla con los requisitos
  static ValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return ValidationResult(
        isValid: false,
        error: "La contraseña es obligatoria",
      );
    }

    if (password.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: "La contraseña no puede contener solo espacios",
      );
    }

    if (password.length < 8) {
      return ValidationResult(
        isValid: false,
        error: "La contraseña debe tener al menos 8 caracteres",
      );
    }

    if (_hasExcessiveSpacing(password)) {
      return ValidationResult(
        isValid: false,
        error: "La contraseña no puede tener espacios excesivos",
      );
    }

    return ValidationResult(isValid: true, error: "");
  }

  /// Valida que ambos campos no estén vacíos
  static ValidationResult validateBothFieldsNotEmpty(
      String usuario, String password) {
    if (usuario.trim().isEmpty && password.trim().isEmpty) {
      return ValidationResult(
        isValid: false,
        error: "Debe ingresar su usuario y contraseña",
      );
    }

    return ValidationResult(isValid: true, error: "");
  }
}