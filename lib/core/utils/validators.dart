class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _hasLetter = RegExp(r'[A-Za-z]');
  static final RegExp _hasDigit = RegExp(r'\d');

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!_emailPattern.hasMatch(text)) return 'Enter a valid email address';
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Use at least 8 characters';
    if (!_hasLetter.hasMatch(value) || !_hasDigit.hasMatch(value)) {
      return 'Include both letters and numbers';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) {
      if (value == null || value.isEmpty) return 'Please confirm your password';
      if (value != original()) return "Passwords don't match";
      return null;
    };
  }

  static String? fullName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Full name is required';
    if (text.length < 2) return 'Name is too short';
    return null;
  }

  static String? department(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Department or programme is required';
    return null;
  }

  static String? title(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Give your report a title';
    if (text.length < 5) return 'Title should be at least 5 characters';
    if (text.length > 80) return 'Keep the title under 80 characters';
    return null;
  }

  static String? description(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Describe the issue';
    if (text.length < 15) return 'Add a bit more detail (at least 15 characters)';
    if (text.length > 1000) return 'Keep the description under 1000 characters';
    return null;
  }
}
