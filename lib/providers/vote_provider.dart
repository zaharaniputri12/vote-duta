import 'package:flutter/material.dart';

class VoteProvider extends ChangeNotifier {
  bool _hasVotedBujang = false;
  bool _hasVotedGadis = false;
  bool _isLoading = false;
  String? _error;

  bool get hasVotedBujang => _hasVotedBujang;
  bool get hasVotedGadis => _hasVotedGadis;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> submitVote({required String kategori, required String candidateId}) async {
    _isLoading = true; _error = null; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    if (kategori == 'bujang' && _hasVotedBujang) { _error = 'Anda sudah memilih Bujang'; _isLoading = false; notifyListeners(); return false; }
    if (kategori == 'gadis' && _hasVotedGadis) { _error = 'Anda sudah memilih Gadis'; _isLoading = false; notifyListeners(); return false; }
    kategori == 'bujang' ? _hasVotedBujang = true : _hasVotedGadis = true;
    _isLoading = false; notifyListeners();
    return true;
  }

  void resetVotes() { _hasVotedBujang = false; _hasVotedGadis = false; notifyListeners(); }
  void clearError() { _error = null; notifyListeners(); }
}