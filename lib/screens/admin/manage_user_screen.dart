import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/candidate_provider.dart';
import '../../services/local_storage_service.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({super.key});

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cp = Provider.of<CandidateProvider>(context, listen: false);
    await LocalStorageService.saveAllData(
      users: auth.usersForSave,
      passwords: auth.passwordsForSave,
      bujangCandidates: cp.bujangForSave,
      gadisCandidates: cp.gadisForSave,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    var users = auth.allUsers.where((u) => u.role == 'mahasiswa').toList();

    if (_search.isNotEmpty) {
      users = users.where((u) =>
          u.nama.toLowerCase().contains(_search.toLowerCase()) ||
          u.nim.contains(_search) ||
          u.email.toLowerCase().contains(_search)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Cari mahasiswa...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); })
                    : null,
                filled: true,
                fillColor: AppColors.white.withOpacity(0.15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              ),
            ),
          ),
        ),
      ),
      // ✅ TOMBOL TAMBAH USER
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(auth),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.person_add, color: AppColors.black),
      ),
      body: users.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.people_outline, size: 70, color: AppColors.grey.withOpacity(0.4)),
                const SizedBox(height: 12),
                Text(_search.isNotEmpty ? 'User tidak ditemukan' : 'Belum ada mahasiswa', style: const TextStyle(color: AppColors.grey)),
              ]),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                return _buildUserCard(u, auth);
              },
            ),
    );
  }

  // ✅ CARD USER
  Widget _buildUserCard(u, AuthProvider auth) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(u.nama[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(u.nama, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(u.nim, style: const TextStyle(fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status Vote
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: u.sudahVote ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                u.sudahVote ? 'Voted' : 'Belum',
                style: TextStyle(fontSize: 10, color: u.sudahVote ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w600),
              ),
            ),
            // ✅ Popup Menu (Detail, Edit, Hapus)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'detail') _showDetailDialog(u);
                if (value == 'edit') _showEditUserDialog(u, auth);
                if (value == 'delete') _showDeleteDialog(u, auth);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'detail', child: Row(children: [Icon(Icons.visibility, size: 18), SizedBox(width: 8), Text('Detail')])),
                const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit')])),
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: AppColors.error), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: AppColors.error))])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============ DIALOG DETAIL ============
  void _showDetailDialog(u) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(u.nama[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Text(u.nama, style: const TextStyle(fontSize: 16)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          _detailRow('Email', u.email),
          _detailRow('NIM', u.nim),

          _detailRow('Status Vote', u.sudahVote ? '✅ Sudah Vote' : '⏳ Belum Vote'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
      ),
    );
  }

  // ============ DIALOG TAMBAH ============
  void _showAddUserDialog(AuthProvider auth) {
    final namaCtrl = TextEditingController();
    final nimCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tambah Mahasiswa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: nimCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'NIM', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (namaCtrl.text.isEmpty || nimCtrl.text.isEmpty || emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi'), backgroundColor: AppColors.warning));
                  return;
                }
                // Cek email & NIM
                if (auth.allUsers.any((u) => u.email == emailCtrl.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email sudah terdaftar'), backgroundColor: AppColors.error));
                  return;
                }
                if (auth.allUsers.any((u) => u.nim == nimCtrl.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('NIM sudah terdaftar'), backgroundColor: AppColors.error));
                  return;
                }

                // Tambah user via register
                final ok = await auth.register(
                  nama: namaCtrl.text.trim(),
                  nim: nimCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  password: passCtrl.text,
                );
                if (ok) {
                  await _save();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ ${namaCtrl.text} berhasil ditambahkan'), backgroundColor: AppColors.success));
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // ============ DIALOG EDIT ============
  void _showEditUserDialog(u, AuthProvider auth) {
    final namaCtrl = TextEditingController(text: u.nama);
    final emailCtrl = TextEditingController(text: u.email);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit ${u.nama}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (namaCtrl.text.isEmpty) return;
                auth.updateUser(
                  u.id,
                  nama: namaCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                );
                await _save();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Data user diupdate'), backgroundColor: AppColors.success));
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  // ============ DIALOG HAPUS ============
  void _showDeleteDialog(u, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin ingin menghapus ${u.nama}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              auth.deleteUser(u.id);
              await _save();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ ${u.nama} dihapus'), backgroundColor: AppColors.error));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13))),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
      ]),
    );
  }
}