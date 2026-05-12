import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/candidate_provider.dart';
import '../../providers/vote_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/candidate_card.dart';
import '../../widgets/bottom_nav.dart';
import '../candidate/candidate_list_screen.dart';
import '../candidate/candidate_detail_screen.dart';
import '../result/result_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.isAdmin) return const AdminDashboardScreen();

    final screens = [_buildHomeContent(), const CandidateListScreen(kategori: 'bujang'), const ResultScreen(), const ProfileScreen()];
    return Scaffold(
      appBar: _currentIndex == 0 ? AppBar(title: const Text('VOTE DUTA')) : null,
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
    );
  }

  Widget _buildHomeContent() {
    final auth = Provider.of<AuthProvider>(context);
    final cp = Provider.of<CandidateProvider>(context);
    final vp = Provider.of<VoteProvider>(context);

    return RefreshIndicator(
      onRefresh: () async => cp.refreshData(),
      child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(margin: const EdgeInsets.all(16), height: 160, decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(20)), child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.how_to_vote, color: AppColors.accent, size: 50), SizedBox(height: 8), Text('PEMILIHAN BUJANG GADIS INFORMATIKA 2024', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text('Universitas Prabumulih', style: TextStyle(color: AppColors.white70, fontSize: 13))]))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Halo, ${auth.user?.nama ?? 'User'}! 👋', style: Theme.of(context).textTheme.titleLarge)),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [Expanded(child: StatCard(title: 'Kandidat', value: '${cp.totalKandidat}', icon: Icons.people, color: AppColors.primary)), const SizedBox(width: 12), Expanded(child: StatCard(title: 'Total Suara', value: '${cp.totalVotesBujang + cp.totalVotesGadis}', icon: Icons.how_to_vote, color: AppColors.success))])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: (vp.hasVotedBujang && vp.hasVotedGadis) ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon((vp.hasVotedBujang && vp.hasVotedGadis) ? Icons.check_circle : Icons.info, color: (vp.hasVotedBujang && vp.hasVotedGadis) ? AppColors.success : AppColors.warning), const SizedBox(width: 8), Text((vp.hasVotedBujang && vp.hasVotedGadis) ? 'Anda sudah melakukan voting' : 'Silakan pilih kandidat terbaik', style: TextStyle(fontWeight: FontWeight.bold, color: (vp.hasVotedBujang && vp.hasVotedGadis) ? AppColors.success : AppColors.warning))]))),
        const SizedBox(height: 16),
        if (cp.bujangCandidates.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Kandidat Bujang', style: Theme.of(context).textTheme.titleLarge), TextButton(onPressed: () => setState(() => _currentIndex = 1), child: const Text('Lihat Semua'))])),
          SizedBox(height: 250, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: cp.bujangCandidates.length, itemBuilder: (_, i) => CandidateCard(candidate: cp.bujangCandidates[i], onTap: () { cp.selectCandidate(cp.bujangCandidates[i].id); Navigator.push(context, MaterialPageRoute(builder: (_) => CandidateDetailScreen(candidateId: cp.bujangCandidates[i].id))); }))),
        ],
        const SizedBox(height: 16),
        if (cp.gadisCandidates.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Kandidat Gadis', style: Theme.of(context).textTheme.titleLarge), TextButton(onPressed: () => setState(() => _currentIndex = 1), child: const Text('Lihat Semua'))])),
          SizedBox(height: 250, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: cp.gadisCandidates.length, itemBuilder: (_, i) => CandidateCard(candidate: cp.gadisCandidates[i], onTap: () { cp.selectCandidate(cp.gadisCandidates[i].id); Navigator.push(context, MaterialPageRoute(builder: (_) => CandidateDetailScreen(candidateId: cp.gadisCandidates[i].id))); }))),
        ],
        const SizedBox(height: 100),
      ])),
    );
  }
}