import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/candidate_provider.dart';
import '../../services/local_storage_service.dart';
import '../../models/candidate_model.dart';
import '../../widgets/candidate_image.dart';

class ManageCandidateScreen extends StatefulWidget {
  const ManageCandidateScreen({super.key});

  @override
  State<ManageCandidateScreen> createState() => _ManageCandidateScreenState();
}

class _ManageCandidateScreenState extends State<ManageCandidateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cp = Provider.of<CandidateProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await LocalStorageService.saveAllData(
      users: auth.usersForSave, passwords: auth.passwordsForSave,
      bujangCandidates: cp.bujangForSave, gadisCandidates: cp.gadisForSave,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<CandidateProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Kandidat'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.6),
          tabs: const [Tab(text: 'Bujang'), Tab(text: 'Gadis')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(cp),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.black),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildGrid(cp.bujangCandidates, cp),
          _buildGrid(cp.gadisCandidates, cp),
        ],
      ),
    );
  }

  // ✅ GRID FOTO BESAR + NAMA, KLIK = DETAIL
  Widget _buildGrid(List<CandidateModel> candidates, CandidateProvider cp) {
    if (candidates.isEmpty) {
      return const Center(child: Text('Belum ada kandidat', style: TextStyle(color: AppColors.grey)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final c = candidates[index];
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 6)],
          ),
          child: Stack(
            children: [
              // ✅ FOTO + NAMA (KLIK = DETAIL)
              GestureDetector(
                onTap: () => _showDetailDialog(c),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    // Foto Besar
                    Builder(builder: (context) {
                      final image = candidateImageProvider(c);
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: AppColors.primary.withOpacity(0.1),
                          image: image != null ? DecorationImage(image: image, fit: BoxFit.cover) : null,
                        ),
                        child: image == null
                            ? Center(child: Text(c.nama[0].toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)))
                            : null,
                      );
                    }),
                    const SizedBox(height: 10),
                    // Nama & Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(c.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 2),
                    Text('#${c.nomorUrut} • ${c.jumlahSuara} suara', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                  ],
                ),
              ),

              // ✅ ICON EDIT & HAPUS (POJOK KANAN ATAS)
              Positioned(
                top: 4,
                right: 4,
                child: Row(
                  children: [
                    // Edit
                    GestureDetector(
                      onTap: () => _showEditDialog(c, cp),
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: AppColors.info.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.edit, size: 14, color: AppColors.white),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Hapus
                    GestureDetector(
                      onTap: () => _showDeleteDialog(c, cp),
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.8), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.delete, size: 14, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============ DIALOG DETAIL ============
  void _showDetailDialog(CandidateModel c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: candidateImageProvider(c),
              child: candidateImageProvider(c) == null ? Text(c.nama[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(c.nama, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            _row('Nomor Urut', '#${c.nomorUrut}'),
            _row('Kategori', c.kategori == 'bujang' ? '👨 Bujang' : '👩 Gadis'),
            _row('Jumlah Suara', '${c.jumlahSuara}'),
            const Divider(),
            const Text('VISI', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)), const SizedBox(height: 4),
            Text(c.visi, style: const TextStyle(fontSize: 12)), const SizedBox(height: 10),
            const Text('MISI', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info, fontSize: 13)), const SizedBox(height: 4),
            Text(c.misi, style: const TextStyle(fontSize: 12)), const SizedBox(height: 10),
            const Text('PROGRAM KERJA', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13)), const SizedBox(height: 4),
            Text(c.programKerja, style: const TextStyle(fontSize: 12)),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
    ]));
  }

  // ============ DELETE ============
  void _showDeleteDialog(CandidateModel c, CandidateProvider cp) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Hapus Kandidat'), content: Text('Yakin hapus ${c.nama}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ElevatedButton(onPressed: () async { cp.deleteCandidate(c.id); await _save(); Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Hapus')),
      ],
    ));
  }

  // ============ ADD ============
  void _showAddDialog(CandidateProvider cp) {
    final namaCtrl = TextEditingController(), visiCtrl = TextEditingController(), misiCtrl = TextEditingController(), prokerCtrl = TextEditingController();
    String kategori = 'bujang';
    String? fotoBase64;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (_, setDialogState) => AlertDialog(
      title: const Text('Tambah Kandidat'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 500);
            if (image != null) { final bytes = await image.readAsBytes(); setDialogState(() => fotoBase64 = base64Encode(bytes)); }
          },
          child: Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(40), image: fotoBase64 != null ? DecorationImage(image: MemoryImage(base64Decode(fotoBase64!)), fit: BoxFit.cover) : null), child: fotoBase64 == null ? const Icon(Icons.camera_alt, color: AppColors.grey) : null),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ChoiceChip(label: const Text('Bujang'), selected: kategori == 'bujang', onSelected: (_) => setDialogState(() => kategori = 'bujang'))),
          const SizedBox(width: 8),
          Expanded(child: ChoiceChip(label: const Text('Gadis'), selected: kategori == 'gadis', onSelected: (_) => setDialogState(() => kategori = 'gadis'))),
        ]),
        const SizedBox(height: 12),
        TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: visiCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Visi', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: misiCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Misi', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: prokerCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Program Kerja', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ElevatedButton(onPressed: () async {
          if (namaCtrl.text.isEmpty) return;
          final nomor = kategori == 'bujang' ? cp.bujangCandidates.length + 1 : cp.gadisCandidates.length + 1;
          cp.addCandidate(CandidateModel(id: '${kategori}_${DateTime.now().millisecondsSinceEpoch}', nama: namaCtrl.text, nomorUrut: nomor, visi: visiCtrl.text, misi: misiCtrl.text, programKerja: prokerCtrl.text, kategori: kategori, fotoBase64: fotoBase64));
          await _save(); Navigator.pop(ctx);
        }, child: const Text('Simpan')),
      ],
    )));
  }

  // ============ EDIT ============
  void _showEditDialog(CandidateModel c, CandidateProvider cp) {
    final namaCtrl = TextEditingController(text: c.nama), visiCtrl = TextEditingController(text: c.visi), misiCtrl = TextEditingController(text: c.misi), prokerCtrl = TextEditingController(text: c.programKerja);
    String? fotoBase64 = c.fotoBase64;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (_, setDialogState) => AlertDialog(
      title: const Text('Edit Kandidat'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          onTap: () async {
            final picker = ImagePicker();
            final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 500);
            if (image != null) { final bytes = await image.readAsBytes(); setDialogState(() => fotoBase64 = base64Encode(bytes)); }
          },
          child: Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(40), image: fotoBase64 != null ? DecorationImage(image: MemoryImage(base64Decode(fotoBase64!)), fit: BoxFit.cover) : null), child: fotoBase64 == null ? const Icon(Icons.camera_alt, color: AppColors.grey) : null),
        ),
        const SizedBox(height: 12),
        TextField(controller: namaCtrl, decoration: const InputDecoration(labelText: 'Nama', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: visiCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Visi', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: misiCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Misi', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        TextField(controller: prokerCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Program Kerja', border: OutlineInputBorder())),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
        ElevatedButton(onPressed: () async {
          if (namaCtrl.text.isEmpty) return;
          c.nama = namaCtrl.text; c.visi = visiCtrl.text; c.misi = misiCtrl.text; c.programKerja = prokerCtrl.text; c.fotoBase64 = fotoBase64;
          cp.refreshData(); await _save(); Navigator.pop(ctx);
        }, child: const Text('Simpan')),
      ],
    )));
  }
}