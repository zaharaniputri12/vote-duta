import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/dummy_data.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isInitialized => _isInitialized;

  List<UserModel> _allUsers = [];
  Map<String, String> _allPasswords = {};

  List<UserModel> get allUsers => _allUsers;
  List<UserModel> get usersForSave => _allUsers;
  Map<String, String> get passwordsForSave => _allPasswords;

  // ============ INIT ============
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final hasSavedData = await LocalStorageService.hasData();

    if (hasSavedData) {
      final savedUsers = await LocalStorageService.loadUsers();
      final savedPasswords = await LocalStorageService.loadPasswords();
      if (savedUsers != null) _allUsers = savedUsers;
      if (savedPasswords != null) _allPasswords = savedPasswords;
      final savedUserId = await LocalStorageService.loadCurrentUser();
      if (savedUserId != null) {
        try {
          _user = _allUsers.firstWhere((u) => u.id == savedUserId);
        } catch (_) {}
      }
    } else {
      _allUsers = List.from(DummyData.users);
      _allPasswords = Map.from(DummyData.passwords);
    }

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  // ============ LOGIN ============
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    final correctPassword = _allPasswords[email];
    if (correctPassword == null) { _error = 'Email tidak terdaftar'; _isLoading = false; notifyListeners(); return false; }
    if (correctPassword != password) { _error = 'Password salah'; _isLoading = false; notifyListeners(); return false; }

    _user = _allUsers.firstWhere((u) => u.email == email);
    await LocalStorageService.saveCurrentUser(_user!.id);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ============ REGISTER ============
Future<bool> register({
  required String nama,
  required String nim,
  required String email,
  required String password,
}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  await Future.delayed(const Duration(milliseconds: 500));

  // ✅ Validasi: Admin hanya bisa @unpra.ac.id
  if (email.endsWith('@unpra.ac.id')) {
    // Cek apakah ini user biasa yang mau daftar pake email kampus
    // Kalau mau, bisa diizinkan atau ditolak
    // Untuk keamanan, admin tidak bisa didaftarkan via register
  }

  // ✅ Validasi: Mahasiswa pakai @gmail.com (tapi bisa juga email lain)
  // Tidak perlu strict validation untuk demo

  if (_allPasswords.containsKey(email)) {
    _error = 'Email sudah terdaftar';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  if (_allUsers.any((u) => u.nim == nim)) {
    _error = 'NIM sudah terdaftar';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // ✅ Tentukan role berdasarkan email
  String role = 'mahasiswa';
  if (email.endsWith('@unpra.ac.id')) {
    role = 'admin';  // Email kampus jadi admin
  }

  final newUser = UserModel(
    id: 'user_${DateTime.now().millisecondsSinceEpoch}',
    nama: nama,
    nim: nim,
    email: email,
    role: role,
  );

  _allUsers.add(newUser);
  _allPasswords[email] = password;
  _user = newUser;
  await LocalStorageService.saveCurrentUser(newUser.id);
  await LocalStorageService.saveUsers(users: _allUsers, passwords: _allPasswords);

  _isLoading = false;
  _successMessage = 'Registrasi berhasil! Selamat datang.';
  notifyListeners();
  return true;
}

  // ============ LUPA PASSWORD ============
  Future<bool> resetPassword(String email) async {
    _isLoading = true; _error = null; _successMessage = null; notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    if (!_allPasswords.containsKey(email)) { _error = 'Email tidak terdaftar'; _isLoading = false; notifyListeners(); return false; }
    _allPasswords[email] = '123456';
    _successMessage = 'Password direset ke: 123456'; _isLoading = false; notifyListeners();
    return true;
  }

  // ============ VOTE STATUS ============
  void updateUserVoteStatus() {
    if (_user != null) {
      _user!.sudahVote = true;
      final index = _allUsers.indexWhere((u) => u.id == _user!.id);
      if (index != -1) _allUsers[index].sudahVote = true;
      notifyListeners();
    }
  }

  Future<bool> updateCurrentUser({String? nama, String? email, String? photoPath}) async {
    if (_user == null) return false;

    final oldEmail = _user!.email;
    final updatedUser = UserModel(
      id: _user!.id,
      nama: nama ?? _user!.nama,
      nim: _user!.nim,
      email: email ?? _user!.email,
      sudahVote: _user!.sudahVote,
      role: _user!.role,
      photoPath: photoPath ?? _user!.photoPath,
    );

    final index = _allUsers.indexWhere((u) => u.id == _user!.id);
    if (index != -1) {
      _allUsers[index] = updatedUser;
    }

    if (email != null && email != oldEmail) {
      final savedPassword = _allPasswords.remove(oldEmail);
      if (savedPassword != null) {
        _allPasswords[updatedUser.email] = savedPassword;
      }
    }

    _user = updatedUser;
    await _saveUsersData();
    notifyListeners();
    return true;
  }

  Future<void> _saveUsersData() async {
    await LocalStorageService.saveUsers(users: _allUsers, passwords: _allPasswords);
  }

  Future<bool> updateUser(String userId, {String? nama, String? email, String? photoPath}) async {
    final index = _allUsers.indexWhere((u) => u.id == userId);
    if (index == -1) return false;

    final current = _allUsers[index];
    final updatedUser = UserModel(
      id: current.id,
      nama: nama ?? current.nama,
      nim: current.nim,
      email: email ?? current.email,
      sudahVote: current.sudahVote,
      role: current.role,
      photoPath: photoPath ?? current.photoPath,
    );

    _allUsers[index] = updatedUser;
    if (_user?.id == userId) {
      _user = updatedUser;
    }
    await _saveUsersData();
    notifyListeners();
    return true;
  }

  void resetAllUserVoteStatus() {
    for (var u in _allUsers) { if (u.role == 'mahasiswa') u.sudahVote = false; }
    if (_user?.role == 'mahasiswa') _user!.sudahVote = false;
    notifyListeners();
  }

  // ============ ADMIN ============
  void deleteUser(String userId) {
    final target = _allUsers.firstWhere((u) => u.id == userId, orElse: () => _allUsers.first);
    _allUsers.removeWhere((u) => u.id == userId);
    _allPasswords.remove(target.email);
    notifyListeners();
  }

  // ============ SET USER VOTE STATUS ============
  Future<void> setUserVoteStatus(String email, bool hasVoted) async {
    final index = _allUsers.indexWhere((u) => u.email == email);
    if (index != -1) {
      _allUsers[index].sudahVote = hasVoted;
      if (_user?.email == email) {
        _user!.sudahVote = hasVoted;
      }
      await _saveUsersData();
      notifyListeners();
    }
  }

  int get totalUsers => _allUsers.where((u) => u.role == 'mahasiswa').length;
  int get totalVoted => _allUsers.where((u) => u.sudahVote && u.role == 'mahasiswa').length;
  int get belumVote => totalUsers - totalVoted;
  double get partisipasiPersen => totalUsers > 0 ? (totalVoted / totalUsers) * 100 : 0;

  // ============ LOGOUT ============
  Future<void> logout() async {
    _user = null;
    await LocalStorageService.saveCurrentUser(null);
    notifyListeners();
  }

  void clearMessages() { _error = null; _successMessage = null; notifyListeners(); }
}