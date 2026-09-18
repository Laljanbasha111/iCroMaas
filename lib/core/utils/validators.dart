import 'package:intl/intl.dart';

class Validators {
  // -----------------------------
  // EMAIL VALIDATORS
  // -----------------------------

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter an email address';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Please enter a valid email address';
    return null;
  }

  static String? validateEmailNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    return validateEmail(value);
  }

  // -----------------------------
  // PASSWORD VALIDATORS
  // -----------------------------

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters long';
    return null;
  }

  static String? validatePasswordStrength(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    if (!regex.hasMatch(value)) {
      return 'Password must include upper, lower, number, and special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) return 'Please confirm your password';
    if (password != confirmPassword) return 'Passwords do not match';
    return null;
  }

  // -----------------------------
  // PHONE VALIDATORS
  // -----------------------------

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter a phone number';
    final regex = RegExp(r'^\+?[\d\s]{7,15}$');
    if (!regex.hasMatch(value.trim())) return 'Please enter a valid phone number';
    return null;
  }

  static String? validatePhoneNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    return validatePhone(value);
  }

  // -----------------------------
  // NAME VALIDATORS
  // -----------------------------

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter a name';
    if (value.trim().length < 2) return 'Name must be at least 2 characters long';
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your full name';
    final parts = value.trim().split(' ');
    if (parts.length < 2) return 'Please enter both first and last name';
    return null;
  }

  // -----------------------------
  // TEXT VALIDATORS
  // -----------------------------

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    if (value.trim().length < minLength) return '$fieldName must be at least $minLength characters';
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    return null;
  }

  static String? validateAlphabetic(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final regex = RegExp(r'^[a-zA-Z\s]+$');
    if (!regex.hasMatch(value.trim())) return '$fieldName must contain only letters';
    return null;
  }

  static String? validateAlphanumeric(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final regex = RegExp(r'^[a-zA-Z0-9\s]+$');
    if (!regex.hasMatch(value.trim())) return '$fieldName must contain only letters and numbers';
    return null;
  }

  // -----------------------------
  // NUMBER VALIDATORS
  // -----------------------------

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    if (double.tryParse(value.trim()) == null) return '$fieldName must be a valid number';
    return null;
  }

  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final number = double.tryParse(value.trim());
    if (number == null) return '$fieldName must be a valid number';
    if (number <= 0) return '$fieldName must be greater than zero';
    return null;
  }

  static String? validateRange(String? value, double min, double max, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    final number = double.tryParse(value.trim());
    if (number == null) return '$fieldName must be a valid number';
    if (number < min || number > max) return '$fieldName must be between $min and $max';
    return null;
  }

  // -----------------------------
  // URL VALIDATORS
  // -----------------------------

  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter a URL';
    final regex = RegExp(r'^(https?:\/\/)?([\w\-]+\.)+[a-zA-Z]{2,}(\/\S*)?$');
    if (!regex.hasMatch(value.trim())) return 'Please enter a valid URL';
    return null;
  }

  // -----------------------------
  // DATE VALIDATORS
  // -----------------------------

  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter a date';
    try {
      DateFormat('yyyy-MM-dd').parseStrict(value.trim());
      return null;
    } catch (_) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
  }

  static String? validateFutureDate(String? value) {
    final error = validateDate(value);
    if (error != null) return error;
    final date = DateFormat('yyyy-MM-dd').parse(value!.trim());
    if (date.isBefore(DateTime.now())) return 'Date must be in the future';
    return null;
  }

  static String? validatePastDate(String? value) {
    final error = validateDate(value);
    if (error != null) return error;
    final date = DateFormat('yyyy-MM-dd').parse(value!.trim());
    if (date.isAfter(DateTime.now())) return 'Date must be in the past';
    return null;
  }

  // -----------------------------
  // CUSTOM VALIDATORS
  // -----------------------------

  static String? validateCropName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter a crop name';
    final regex = RegExp(r'^[a-zA-Z\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Crop name must contain only letters';
    return null;
  }

  static String? validateDiseaseName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter a disease name';
    final regex = RegExp(r'^[a-zA-Z\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Disease name must contain only letters';
    return null;
  }

  static String? validatePercentage(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter a percentage';
    final number = double.tryParse(value.trim());
    if (number == null) return 'Please enter a valid number';
    if (number < 0 || number > 100) return 'Percentage must be between 0 and 100';
    return null;
  }
}