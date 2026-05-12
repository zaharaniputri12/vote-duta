import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/candidate_provider.dart';
import '../../providers/vote_provider.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/candidate_image.dart';
import '../../widgets/confirm_dialog.dart';

class CandidateDetailScreen extends StatelessWidget {
  final String candidateId;
  const CandidateDetailScreen({super.key, required this.candidateId});

  Future<void> _saveData(BuildContext context) async {
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
    final cp = Provider.of<CandidateProvider>(context);
    final c = cp.selectedCandidate;
    if (c == null) return const Scaffold(body: Center(child: Text('Data tidak ditemukan')));
    final image = candidateImageProvider(c);

    final vp = Provider.of<VoteProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final hasVoted = c.kategori == 'bujang' ? vp.hasVotedBujang : vp.hasVotedGadis;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header dengan Foto
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              // Nomor Urut di pojok kanan atas
              Container(
                margin: const EdgeInsets.only(right: 12, top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  'No. Urut #${c.nomorUrut}',
                  style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // ✅ FOTO / INISIAL
                      Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(55),
                              border: Border.all(
                                color: AppColors.accent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              // Jika ada foto, tampilkan foto
                              image: image != null
                                  ? DecorationImage(
                                      image: image,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            // Jika tidak ada foto, tampilkan inisial
                            child: image == null
                                ? Center(
                                    child: Text(
                                      c.nama[0].toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 45,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          // Badge kategori
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: c.kategori == 'bujang'
                                    ? Colors.blue
                                    : Colors.pink,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.white, width: 2),
                              ),
                              child: Icon(
                                c.kategori == 'bujang'
                                    ? Icons.person
                                    : Icons.person_2,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Nama Kandidat
                      Text(
                        c.nama,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Jumlah suara
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite,
                                color: AppColors.accent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${c.jumlahSuara} Suara',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: c.kategori == 'bujang'
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.pink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: c.kategori == 'bujang'
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.pink.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        c.kategori == 'bujang'
                            ? '👨 KANDIDAT BUJANG'
                            : '👩 KANDIDAT GADIS',
                        style: TextStyle(
                          color: c.kategori == 'bujang'
                              ? Colors.blue
                              : Colors.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Vote Button atau Status
                  if (!hasVoted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.how_to_vote,
                              color: AppColors.accent, size: 50),
                          const SizedBox(height: 12),
                          const Text(
                            'Pilih kandidat ini?',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: vp.isLoading
                                ? null
                                : () async {
                                    final ok = await ConfirmDialog.show(
                                      context: context,
                                      title: 'Konfirmasi Voting',
                                      message:
                                          'Apakah Anda yakin ingin memilih ${c.nama}?\n\nVoting tidak dapat diubah setelah dikonfirmasi.',
                                    );
                                    if (ok == true && context.mounted) {
                                      final success = await vp.submitVote(
                                        kategori: c.kategori,
                                        candidateId: c.id,
                                      );
                                      if (success && context.mounted) {
                                        cp.addVote(c.id);
                                        auth.updateUserVoteStatus();
                                        await _saveData(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                '✅ Voting berhasil! Terima kasih telah berpartisipasi.'),
                                            backgroundColor:
                                                AppColors.success,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.how_to_vote, size: 22),
                            label: const Text(
                              'PILIH KANDIDAT INI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.black,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          if (vp.isLoading) ...[
                            const SizedBox(height: 12),
                            const CircularProgressIndicator(
                                color: AppColors.accent),
                          ],
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle,
                              size: 50, color: AppColors.success),
                          SizedBox(height: 12),
                          Text(
                            'Anda sudah memilih kandidat ini',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Terima kasih telah berpartisipasi!',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Visi
                  _sectionCard(
                    context: context,
                    icon: Icons.visibility,
                    title: 'VISI',
                    content: c.visi,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 14),

                  // Misi
                  _sectionCard(
                    context: context,
                    icon: Icons.assignment,
                    title: 'MISI',
                    content: c.misi,
                    color: AppColors.info,
                  ),
                  const SizedBox(height: 14),

                  // Program Kerja
                  _sectionCard(
                    context: context,
                    icon: Icons.work_outline,
                    title: 'PROGRAM KERJA',
                    content: c.programKerja,
                    color: AppColors.success,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}