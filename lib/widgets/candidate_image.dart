import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/candidate_model.dart';

ImageProvider? candidateImageProvider(CandidateModel candidate) {
  if (candidate.fotoBase64 != null && candidate.fotoBase64!.isNotEmpty) {
    final data = candidate.fotoBase64!;
    final base64Data = data.startsWith('data:image/')
        ? data.substring(data.indexOf('base64,') + 7)
        : data;
    try {
      return MemoryImage(base64Decode(base64Data));
    } catch (_) {
      // Jika base64 tidak bisa didecode (misal SVG data URL), coba fallback ke asset.
    }
  }

  if (candidate.fotoUrl.isNotEmpty) {
    return AssetImage(candidate.fotoUrl);
  }

  return null;
}
