import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final u = auth.user;
    if (u != null) {
      _namaCtrl.text = u.nama;
      _emailCtrl.text = u.email;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final u = auth.user;
    if (u == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
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
                  child: Center(
                    child: Text(
                      u.nama[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.white, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: AppColors.black, size: 20),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Nama
            Text(u.nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 4),

            // Role Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: const Text('👑 ADMINISTRATOR', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12)),
            ),

            const SizedBox(height: 24),

            // Edit Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() => _isEditing = !_isEditing);
                    if (!_isEditing) _loadData();
                  },
                  icon: Icon(_isEditing ? Icons.close : Icons.edit, size: 18),
                  label: Text(_isEditing ? 'Batal' : 'Edit Profil'),
                ),
              ],
            ),

            // ✅ Hanya Nama & Email
            _buildField('Nama Lengkap', _namaCtrl, Icons.person, false),
            const SizedBox(height: 16),
            _buildField('Email', _emailCtrl, Icons.email, false),

            const SizedBox(height: 32),

            // Save Button
            if (_isEditing)
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    auth.updateCurrentUser(
                      nama: _namaCtrl.text.trim(),
                      email: _emailCtrl.text.trim(),
                    );
                    setState(() => _isEditing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ Profil berhasil diupdate'), backgroundColor: AppColors.success),
                    );
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
                      content: const Text('Yakin ingin keluar dari admin?'),
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
                  final navigatorContext = context;
                  await auth.logout();
                  Navigator.pushAndRemoveUntil(
                    navigatorContext,
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
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, bool readOnly) {
    return TextFormField(
      controller: ctrl,
      readOnly: !_isEditing || readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v == null || v.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }
}