import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vote_provider.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  bool _isEditing = false;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final u = auth.user;
    if (u != null) {
      _namaCtrl.text = u.nama;
      _emailCtrl.text = u.email;
      _nimCtrl.text = u.nim;
      print('DEBUG: User photoPath di initState = ${u.photoPath}');
      if (u.photoPath != null && u.photoPath!.isNotEmpty) {
        final file = File(u.photoPath!);
        print('DEBUG: File exists = ${file.existsSync()}');
        if (file.existsSync()) {
          _pickedImage = file;
        }
      }
    }
  }

  void _loadData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final u = auth.user;
    if (u != null) {
      _namaCtrl.text = u.nama;
      _emailCtrl.text = u.email;
      _nimCtrl.text = u.nim;
      print('DEBUG: User photoPath = ${u.photoPath}');
      if (u.photoPath != null && u.photoPath!.isNotEmpty) {
        final file = File(u.photoPath!);
        print('DEBUG: File exists = ${file.existsSync()}');
        if (file.existsSync()) {
          _pickedImage = file;
        } else {
          _pickedImage = null;
        }
      } else {
        _pickedImage = null;
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

Widget _buildAvatarImage(UserModel u) {
    try {
      // Saat editing: gunakan _pickedImage (yang baru dipilih)
      if (_isEditing && _pickedImage != null) {
        return Image.file(
          _pickedImage!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackAvatar(u);
          },
        );
      }

      // Saat tidak editing: gunakan photoPath dari auth.user
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final photoPath = auth.user?.photoPath;
      if (!_isEditing && photoPath != null && photoPath.isNotEmpty) {
        final file = File(photoPath);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackAvatar(u);
            },
          );
        }
      }
    } catch (e) {
      debugPrint('Error building avatar image: $e');
    }

    // Fallback: tampilkan inisial nama
    return _buildFallbackAvatar(u);
  }

  Widget _buildFallbackAvatar(UserModel u) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Center(
        child: Text(
          u.nama[0].toUpperCase(),
          style: const TextStyle(color: AppColors.white, fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _nimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final vp = Provider.of<VoteProvider>(context);
    final u = auth.user;
    if (u == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_isEditing) {
                // Batal edit - reload data lama
                _loadData();
              }
              setState(() => _isEditing = !_isEditing);
            },
            icon: Icon(_isEditing ? Icons.close : Icons.edit, size: 18, color: AppColors.white),
            label: Text(_isEditing ? 'Batal' : 'Edit', style: const TextStyle(color: AppColors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: _buildAvatarImage(u),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _isEditing
                        ? GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                          )
                        : Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: u.sudahVote ? AppColors.success : AppColors.warning,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.white, width: 2),
                            ),
                            child: Icon(
                              u.sudahVote ? Icons.check : Icons.access_time,
                              color: AppColors.white,
                              size: 16,
                            ),
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(u.nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

              const SizedBox(height: 4),

              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('👨‍🎓 MAHASISWA', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
              ),

              const SizedBox(height: 24),

              // ✅ FORM EDIT
              _buildField('Nama Lengkap', _namaCtrl, Icons.person),
              const SizedBox(height: 16),
              _buildField('Email', _emailCtrl, Icons.email),
              const SizedBox(height: 16),

              // NIM (readonly)
              _buildField('NIM', _nimCtrl, Icons.badge),

              const SizedBox(height: 24),

              // Status Voting
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status Voting', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          vp.hasVotedBujang ? Icons.check_circle : Icons.circle_outlined,
                          color: vp.hasVotedBujang ? AppColors.success : AppColors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(vp.hasVotedBujang ? 'Bujang: Sudah memilih' : 'Bujang: Belum memilih',
                            style: TextStyle(color: vp.hasVotedBujang ? AppColors.success : AppColors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          vp.hasVotedGadis ? Icons.check_circle : Icons.circle_outlined,
                          color: vp.hasVotedGadis ? AppColors.success : AppColors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(vp.hasVotedGadis ? 'Gadis: Sudah memilih' : 'Gadis: Belum memilih',
                            style: TextStyle(color: vp.hasVotedGadis ? AppColors.success : AppColors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ✅ Tombol Simpan (muncul saat edit)
              if (_isEditing)
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await auth.updateCurrentUser(
                        nama: _namaCtrl.text.trim(),
                        email: _emailCtrl.text.trim(),
                        photoPath: _pickedImage?.path,
                      );
                      setState(() => _isEditing = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ Profil berhasil diupdate'), backgroundColor: AppColors.success),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('SIMPAN PERUBAHAN'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                ),

              const SizedBox(height: 12),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // ignore: use_build_context_synchronously
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Yakin ingin keluar?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(c, true),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true || !mounted) return;
                    await auth.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (r) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('LOGOUT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon) {
    return TextFormField(
      controller: ctrl,
      readOnly: !_isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v == null || v.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }
}