import 'package:flutter/material.dart';

import '../texts/app_texts.dart';

/// Form validators. Each returns an error message, or null when valid.
class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[\w.+\-]+@([\w\-]+\.)+[\w\-]{2,}$',
  );

  static String? name(String? value) {
    if (value == null || value.trim().length < 2) {
      return t('err_name_short');
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return t('err_email_required');
    if (!_emailPattern.hasMatch(text)) return t('err_email_invalid');
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return t('err_password_required');
    if (text.length < 6) return t('err_password_short');
    return null;
  }

  /// Validator that checks the value matches [original].
  static String? Function(String?) confirmPassword(
    TextEditingController original,
  ) {
    return (String? value) {
      if (value == null || value.isEmpty) return t('err_password_required');
      if (value != original.text) return t('err_password_mismatch');
      return null;
    };
  }
}
