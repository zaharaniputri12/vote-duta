import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/candidate_provider.dart';
import '../../providers/vote_provider.dart';
import '../../services/local_storage_service.dart';

class ManageVotingScreen extends StatelessWidget {
  const ManageVotingScreen({super.key});

  Future<void> _save(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cp = Provider.of<CandidateProvider>(context, listen: false);
    await LocalStorageService.saveAllData(
      users: auth.usersForSave, passwords: auth.passwordsForSave,
      bujangCandidates: cp.bujangForSave, gadisCandidates: cp.gadisForSave,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cp = Provider.of<CandidateProvider>(context);
    final vp = Provider.of<VoteProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(Icons.how_to_vote, color: AppColors.accent, size: 50),
                SizedBox(height: 8),
                Text('VOTING AKTIF', style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Statistik Vote
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 Statistik Voting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _statRow('Total Mahasiswa', '${auth.totalUsers}'),
                  _statRow('Sudah Memilih', '${auth.totalVoted}'),
                  _statRow('Belum Memilih', '${auth.belumVote}'),
                  _statRow('Suara Bujang', '${cp.totalVotesBujang}'),
                  _statRow('Suara Gadis', '${cp.totalVotesGadis}'),
                  _statRow('Total Suara', '${cp.totalVotesBujang + cp.totalVotesGadis}'),
                  const Divider(),
                  _statRow('Partisipasi', '${auth.partisipasiPersen.toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Daftar User yang Sudah Vote
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ Sudah Memilih (${auth.totalVoted})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...auth.allUsers.where((u) => u.sudahVote && u.role == 'mahasiswa').map((u) => ListTile(
                    dense: true,
                    leading: CircleAvatar(radius: 18, backgroundColor: AppColors.success.withOpacity(0.2), child: Text(u.nama[0], style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12))),
                    title: Text(u.nama, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(u.nim, style: const TextStyle(fontSize: 11)),
                  )),

                  if (auth.totalVoted == 0) const Text('Belum ada yang memilih', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Daftar User yang Belum Vote
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⏳ Belum Memilih (${auth.belumVote})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...auth.allUsers.where((u) => !u.sudahVote && u.role == 'mahasiswa').take(10).map((u) => ListTile(
                    dense: true,
                    leading: CircleAvatar(radius: 18, backgroundColor: AppColors.warning.withOpacity(0.2), child: Text(u.nama[0], style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 12))),
                    title: Text(u.nama, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(u.nim, style: const TextStyle(fontSize: 11)),
                  )),

                  if (auth.belumVote == 0) const Text('Semua sudah memilih 🎉', style: TextStyle(color: AppColors.success)),
                  if (auth.belumVote > 10) Text('... dan ${auth.belumVote - 10} lainnya', style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reset Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Reset Voting?'),
                    content: const Text('Semua suara dan status vote akan dihapus!'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Batal')),
                      ElevatedButton(onPressed: () => Navigator.pop(c, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Reset')),
                    ],
                  ),
                );
                if (ok == true) {
                  cp.resetVotes();
                  vp.resetVotes();
                  auth.resetAllUserVoteStatus();
                  await _save(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Voting direset'), backgroundColor: AppColors.success));
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('RESET SEMUA VOTE'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}