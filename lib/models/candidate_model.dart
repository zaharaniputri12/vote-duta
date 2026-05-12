class CandidateModel {
  final String id;
  String nama;
  final int nomorUrut;
  String visi;
  String misi;
  String programKerja;
  final String kategori;
  final String fotoUrl;
  int jumlahSuara;
  String? fotoBase64;

  CandidateModel({
    required this.id,
    required this.nama,
    required this.nomorUrut,
    required this.visi,
    required this.misi,
    required this.programKerja,
    required this.kategori,
    this.fotoUrl = '',
    this.jumlahSuara = 0,
    this.fotoBase64,
  });
}