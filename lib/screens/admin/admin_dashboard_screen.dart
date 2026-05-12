import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/candidate_provider.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/candidate_image.dart';
import '../auth/login_screen.dart';
import 'manage_candidate_screen.dart';
import 'manage_user_screen.dart';
import 'manage_voting_screen.dart';
import 'admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Dashboard',
    'Kandidat',
    'User',
    'Voting',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final cp = Provider.of<CandidateProvider>(context);

    final screens = [
      _buildDashboard(auth, cp),
      const ManageCandidateScreen(),
      const ManageUserScreen(),
      const ManageVotingScreen(),
      const AdminProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentIndex])),
      body: screens[_currentIndex],
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // ============ BOTTOM NAV ============
  Widget _buildCustomBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.dashboard_rounded, Icons.dashboard, 'Dashboard', 0),
              _navItem(Icons.people_outline_rounded, Icons.people, 'Kandidat', 1),
              _navItem(Icons.group_outlined, Icons.group, 'User', 2),
              _navItem(Icons.settings_outlined, Icons.settings, 'Voting', 3),
              _navItem(Icons.person_outline, Icons.person, 'Profil', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isActive ? activeIcon : icon, size: 22, color: isActive ? AppColors.white : AppColors.grey),
            if (isActive) ...[const SizedBox(width: 6), Text(label, style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600))],
          ],
        ),
      ),
    );
  }

  // ============ DASHBOARD ============
  Widget _buildDashboard(AuthProvider auth, CandidateProvider cp) {
    final allCandidates = [...cp.bujangCandidates, ...cp.gadisCandidates];
    final totalVotes = cp.totalVotesBujang + cp.totalVotesGadis;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Cards
          Row(
            children: [
              Expanded(child: _statCard('Total User', '${auth.totalUsers}', AppColors.primary, Icons.people)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Sudah Vote', '${auth.totalVoted}', AppColors.success, Icons.how_to_vote)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _statCard('Kandidat', '${cp.totalKandidat}', AppColors.info, Icons.person)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('Total Suara', '$totalVotes', AppColors.warning, Icons.bar_chart)),
            ],
          ),
          const SizedBox(height: 24),

          // ✅ DIAGRAM LINGKARAN (Valid dengan data)
          if (totalVotes > 0)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📊 Hasil Voting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: allCandidates.map((c) {
                            final pct = totalVotes > 0 ? (c.jumlahSuara / totalVotes) * 100 : 0;
                            return PieChartSectionData(
                              color: _getColor(allCandidates.indexOf(c)),
                              value: c.jumlahSuara.toDouble(),
                              title: pct > 5 ? '${pct.toStringAsFixed(1)}%' : '',
                              radius: 70,
                              titleStyle: const TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            );
                          }).toList(),
                          centerSpaceRadius: 35,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Legend
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: allCandidates.map((c) {
                        final pct = totalVotes > 0 ? (c.jumlahSuara / totalVotes) * 100 : 0;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: _getColor(allCandidates.indexOf(c)), borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 4),
                            Text('${c.nama.split(' ')[0]} (${pct.toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 10)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

          if (totalVotes == 0)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: Text('Belum ada data voting', style: TextStyle(color: AppColors.grey))),
              ),
            ),

          const SizedBox(height: 24),

          // ✅ KOTAK-KOTAK FOTO KANDIDAT
          const Text('📷 Daftar Kandidat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: allCandidates.length,
            itemBuilder: (context, index) {
              final c = allCandidates[index];
              return _candidateGridItem(c, cp, context);
            },
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ✅ Kotak Foto Kandidat (klik = detail)
  Widget _candidateGridItem(candidate, CandidateProvider cp, BuildContext context) {
    final image = candidateImageProvider(candidate);
    return GestureDetector(
      onTap: () => _showCandidateDetailDialog(candidate),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Foto / Inisial
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColors.primary.withOpacity(0.1),
                image: image != null ? DecorationImage(image: image, fit: BoxFit.cover) : null,
              ),
              child: image == null
                  ? Center(
                      child: Text(
                        candidate.nama[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(candidate.nama.split(' ')[0], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('#${candidate.nomorUrut} • ${candidate.jumlahSuara} suara', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
          ],
        ),
      ),
    );
  }

  // ✅ Dialog Detail Kandidat
  void _showCandidateDetailDialog(candidate) {
    final image = candidateImageProvider(candidate);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: image,
              child: image == null ? Text(candidate.nama[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(candidate.nama, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Nomor Urut', '#${candidate.nomorUrut}'),
              _detailRow('Kategori', candidate.kategori == 'bujang' ? '👨 Bujang' : '👩 Gadis'),
              _detailRow('Jumlah Suara', '${candidate.jumlahSuara}'),
              const Divider(),
              const Text('VISI', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
              const SizedBox(height: 4),
              Text(candidate.visi, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
              const Text('MISI', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info, fontSize: 13)),
              const SizedBox(height: 4),
              Text(candidate.misi, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
              const Text('PROGRAM KERJA', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13)),
              const SizedBox(height: 4),
              Text(candidate.programKerja, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
      ]),
    );
  }

  // ============ HELPERS ============
  Color _getColor(int index) {
    final colors = [AppColors.primary, AppColors.success, AppColors.info, Colors.orange, Colors.pink, Colors.purple, Colors.teal, Colors.red];
    return colors[index % colors.length];
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
      ]),
    );
  }
}