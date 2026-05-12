class UserModel {
  final String id;
  final String nama;
  final String nim;
  final String email;
  bool sudahVote;
  final String role;
  String? photoPath;

  UserModel({
    required this.id,
    required this.nama,
    required this.nim,
    required this.email,
    this.sudahVote = false,
    this.role = 'mahasiswa',
    this.photoPath,
  });
}