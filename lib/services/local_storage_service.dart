import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/candidate_model.dart';

class LocalStorageService {
  static const String _usersKey = 'vote_users';
  static const String _passwordsKey = 'vote_passwords';
  static const String _bujangKey = 'vote_bujang';
  static const String _gadisKey = 'vote_gadis';
  static const String _currentUserKey = 'vote_current_user';

  static Future<void> saveAllData({
    required List<UserModel> users,
    required Map<String, String> passwords,
    required List<CandidateModel> bujangCandidates,
    required List<CandidateModel> gadisCandidates,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final userMaps = users.map((u) => {
          'id': u.id, 'nama': u.nama, 'nim': u.nim,
          'email': u.email, 'sudahVote': u.sudahVote, 'role': u.role,
          'photoPath': u.photoPath,
        }).toList();
    await prefs.setString(_usersKey, jsonEncode(userMaps));
    await prefs.setString(_passwordsKey, jsonEncode(passwords));

    final bMaps = bujangCandidates.map((c) => {
      'id': c.id,
      'nama': c.nama,
      'nomorUrut': c.nomorUrut,
      'visi': c.visi,
      'misi': c.misi,
      'programKerja': c.programKerja,
      'kategori': c.kategori,
      'jumlahSuara': c.jumlahSuara,
      'fotoUrl': c.fotoUrl,
      'fotoBase64': c.fotoBase64,
    }).toList();

    final gMaps = gadisCandidates.map((c) => {
      'id': c.id,
      'nama': c.nama,
      'nomorUrut': c.nomorUrut,
      'visi': c.visi,
      'misi': c.misi,
      'programKerja': c.programKerja,
      'kategori': c.kategori,
      'jumlahSuara': c.jumlahSuara,
      'fotoUrl': c.fotoUrl,
      'fotoBase64': c.fotoBase64,
    }).toList();

    await prefs.setString(_bujangKey, jsonEncode(bMaps));
    await prefs.setString(_gadisKey, jsonEncode(gMaps));
  }

  static Future<List<UserModel>?> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_usersKey);
    if (data == null) return null;
    final List<dynamic> list = jsonDecode(data);
    return list.map((u) => UserModel(
          id: u['id'], nama: u['nama'], nim: u['nim'],
          email: u['email'], sudahVote: u['sudahVote'] ?? false,
          role: u['role'] ?? 'mahasiswa',
          photoPath: u['photoPath'],
        )).toList();
  }

  static Future<Map<String, String>?> loadPasswords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_passwordsKey);
    if (data == null) return null;
    final Map<String, dynamic> map = jsonDecode(data);
    return map.map((k, v) => MapEntry(k, v.toString()));
  }

  static Future<List<CandidateModel>?> loadBujang() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_bujangKey);
    if (data == null) return null;
    final List<dynamic> list = jsonDecode(data);
    return list.map((c) {
      final rawFoto = c['fotoBase64'];
      return CandidateModel(
        id: c['id'], nama: c['nama'], nomorUrut: c['nomorUrut'],
        visi: c['visi'], misi: c['misi'], programKerja: c['programKerja'],
        kategori: c['kategori'], fotoUrl: c['fotoUrl'] ?? '', jumlahSuara: c['jumlahSuara'] ?? 0,
        fotoBase64: rawFoto is String && rawFoto.isNotEmpty ? rawFoto : null,
      );
    }).toList();
  }

  static Future<List<CandidateModel>?> loadGadis() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_gadisKey);
    if (data == null) return null;
    final List<dynamic> list = jsonDecode(data);
    return list.map((c) {
      final rawFoto = c['fotoBase64'];
      return CandidateModel(
        id: c['id'], nama: c['nama'], nomorUrut: c['nomorUrut'],
        visi: c['visi'], misi: c['misi'], programKerja: c['programKerja'],
        kategori: c['kategori'], fotoUrl: c['fotoUrl'] ?? '', jumlahSuara: c['jumlahSuara'] ?? 0,
        fotoBase64: rawFoto is String && rawFoto.isNotEmpty ? rawFoto : null,
      );
    }).toList();
  }

  static Future<void> saveCurrentUser(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setString(_currentUserKey, userId);
    } else {
      await prefs.remove(_currentUserKey);
    }
  }

  static Future<String?> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  static Future<bool> hasData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_usersKey) && prefs.containsKey(_bujangKey) && prefs.containsKey(_gadisKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveUsers({
    required List<UserModel> users,
    required Map<String, String> passwords,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final userMaps = users.map((u) => {
          'id': u.id, 'nama': u.nama, 'nim': u.nim,
          'email': u.email, 'sudahVote': u.sudahVote, 'role': u.role,
          'photoPath': u.photoPath,
        }).toList();
    
    print('DEBUG LocalStorage: Saving ${users.length} users');
    for (var u in users) {
      print('  - ${u.nama}: photoPath=${u.photoPath}');
    }
    
    await prefs.setString(_usersKey, jsonEncode(userMaps));
    await prefs.setString(_passwordsKey, jsonEncode(passwords));
    print('DEBUG LocalStorage: Save completed');
  }
}