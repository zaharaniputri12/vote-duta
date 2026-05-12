class Validators {
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email tidak boleh kosong';
    if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
    return null;
  }
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
    if (v.length < 6) return 'Minimal 6 karakter';
    return null;
  }
  static String? required(String? v, String name) {
    if (v == null || v.isEmpty) return '$name tidak boleh kosong';
    return null;
  }
  static String? nim(String? v) {
    if (v == null || v.isEmpty) return 'NIM tidak boleh kosong';
    if (v.length < 8) return 'NIM minimal 8 digit';
    return null;
  }
}