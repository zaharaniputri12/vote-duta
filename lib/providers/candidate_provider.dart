import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/candidate_model.dart';
import '../services/dummy_data.dart';
import '../services/local_storage_service.dart';

class CandidateProvider extends ChangeNotifier {
  List<CandidateModel> _bujang = [];
  List<CandidateModel> _gadis = [];
  CandidateModel? _selected;

  List<CandidateModel> get bujangCandidates => _bujang;
  List<CandidateModel> get gadisCandidates => _gadis;
  CandidateModel? get selectedCandidate => _selected;
  List<CandidateModel> get bujangForSave => _bujang;
  List<CandidateModel> get gadisForSave => _gadis;

  int get totalVotesBujang => _bujang.fold(0, (s, c) => s + c.jumlahSuara);
  int get totalVotesGadis => _gadis.fold(0, (s, c) => s + c.jumlahSuara);
  int get totalKandidat => _bujang.length + _gadis.length;

  // ============ INIT ============
  Future<void> init() async {
    final hasData = await LocalStorageService.hasData();
    if (hasData) {
      final b = await LocalStorageService.loadBujang();
      final g = await LocalStorageService.loadGadis();
      if (b != null && g != null) {
        _bujang = b;
        _gadis = g;
      } else {
        _bujang = List.from(DummyData.bujangCandidates);
        _gadis = List.from(DummyData.gadisCandidates);
      }
    } else {
      _bujang = List.from(DummyData.bujangCandidates);
      _gadis = List.from(DummyData.gadisCandidates);
    }
    await _generateDefaultPhotos();
    notifyListeners();
  }

  // ============ GENERATE FOTO (WEB COMPATIBLE) ============
  Future<void> _generateDefaultPhotos() async {
    final bujangColors = [
      const Color(0xFF1A237E),
      const Color(0xFF2E7D32),
      const Color(0xFF6A1B9A),
    ];
    final gadisColors = [
      const Color(0xFFE91E63),
      const Color(0xFFFF6F00),
      const Color(0xFFC62828),
    ];

    for (int i = 0; i < _bujang.length; i++) {
      if ((_bujang[i].fotoBase64 == null || _bujang[i].fotoBase64!.isEmpty) && _bujang[i].fotoUrl.isEmpty) {
        _bujang[i].fotoBase64 = await _generateAvatar(
          _bujang[i].nama[0].toUpperCase(),
          bujangColors[i % bujangColors.length],
        );
      }
    }

    for (int i = 0; i < _gadis.length; i++) {
      if ((_gadis[i].fotoBase64 == null || _gadis[i].fotoBase64!.isEmpty) && _gadis[i].fotoUrl.isEmpty) {
        _gadis[i].fotoBase64 = await _generateAvatar(
          _gadis[i].nama[0].toUpperCase(),
          gadisColors[i % gadisColors.length],
        );
      }
    }
  }

  // ============ GENERATE AVATAR (WEB COMPATIBLE) ============
  Future<String> _generateAvatar(String letter, Color color) async {
    try {
      final GlobalKey key = GlobalKey();
      final widget = RepaintBoundary(
        key: key,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 90,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      // Render ke gambar
      final renderObject = key.currentContext?.findRenderObject();
      if (renderObject is RenderRepaintBoundary) {
        // Tidak bisa pakai ini di background
      }

      // Fallback: Buat manual dengan pixel data sederhana
      return _createSimpleAvatar(letter, color);
    } catch (e) {
      return _createSimpleAvatar(letter, color);
    }
  }

  // ============ SIMPLE AVATAR GENERATOR ============
  String _createSimpleAvatar(String letter, Color color) {
    // Buat SVG string sederhana lalu encode ke base64
    final r = color.red;
    final g = color.green;
    final b = color.blue;
    final colorHex = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

    final svgString = '''
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" viewBox="0 0 200 200">
  <circle cx="100" cy="100" r="100" fill="$colorHex"/>
  <text x="100" y="100" text-anchor="middle" dy="0.35em" fill="white" font-size="90" font-weight="bold" font-family="Arial">$letter</text>
</svg>
''';

    final bytes = utf8.encode(svgString);
    // Kembalikan sebagai data URL SVG
    return 'data:image/svg+xml;base64,${base64Encode(bytes)}';
  }

  // ============ SELECT ============
  void selectCandidate(String id) {
    _selected = [..._bujang, ..._gadis].firstWhere((c) => c.id == id);
    notifyListeners();
  }

  void addVote(String id) {
    int bi = _bujang.indexWhere((c) => c.id == id);
    if (bi != -1) { _bujang[bi].jumlahSuara++; notifyListeners(); return; }
    int gi = _gadis.indexWhere((c) => c.id == id);
    if (gi != -1) { _gadis[gi].jumlahSuara++; notifyListeners(); }
  }

  Map<String, double> getPercentages(String kat) {
    final list = kat == 'bujang' ? _bujang : _gadis;
    final total = kat == 'bujang' ? totalVotesBujang : totalVotesGadis;
    Map<String, double> p = {};
    for (var c in list) { p[c.id] = total > 0 ? (c.jumlahSuara / total) * 100 : 0; }
    return p;
  }

  List<CandidateModel> getSorted(String kat) {
    final list = List<CandidateModel>.from(kat == 'bujang' ? _bujang : _gadis);
    list.sort((a, b) => b.jumlahSuara.compareTo(a.jumlahSuara));
    return list;
  }

  void addCandidate(CandidateModel c) {
    c.kategori == 'bujang' ? _bujang.add(c) : _gadis.add(c);
    notifyListeners();
  }

  void deleteCandidate(String id) {
    _bujang.removeWhere((c) => c.id == id);
    _gadis.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void resetVotes() {
    for (var c in _bujang) c.jumlahSuara = 0;
    for (var c in _gadis) c.jumlahSuara = 0;
    notifyListeners();
  }

  void refreshData() => notifyListeners();
}