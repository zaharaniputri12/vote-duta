import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/candidate_provider.dart';
import '../../widgets/candidate_card.dart';
import 'candidate_detail_screen.dart';

class CandidateListScreen extends StatefulWidget {
  final String kategori;
  const CandidateListScreen({super.key, required this.kategori});

  @override
  State<CandidateListScreen> createState() => _CandidateListScreenState();
}

class _CandidateListScreenState extends State<CandidateListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() { super.initState(); _tabCtrl = TabController(length: 2, vsync: this, initialIndex: widget.kategori == 'bujang' ? 0 : 1); }
  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<CandidateProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kandidat'), bottom: TabBar(controller: _tabCtrl, indicatorColor: AppColors.accent, labelColor: AppColors.white, tabs: const [Tab(text: 'Bujang'), Tab(text: 'Gadis')])),
      body: TabBarView(controller: _tabCtrl, children: [_buildGrid(cp.bujangCandidates), _buildGrid(cp.gadisCandidates)]),
    );
  }

  Widget _buildGrid(List candidates) {
    if (candidates.isEmpty) return const Center(child: Text('Belum ada kandidat', style: TextStyle(color: AppColors.grey)));
    return GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: candidates.length, itemBuilder: (_, i) => CandidateCard(candidate: candidates[i], onTap: () { Provider.of<CandidateProvider>(context, listen: false).selectCandidate(candidates[i].id); Navigator.push(context, MaterialPageRoute(builder: (_) => CandidateDetailScreen(candidateId: candidates[i].id))); }, showVoteButton: true));
  }
}