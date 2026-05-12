import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/app_colors.dart';
import '../../providers/candidate_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
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

  Color _getColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.info,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<CandidateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Voting'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.accent,
          indicatorWeight: 3,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.6),
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Bujang'),
            Tab(text: 'Gadis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildResultTab(cp, 'bujang'),
          _buildResultTab(cp, 'gadis'),
        ],
      ),
    );
  }

  Widget _buildResultTab(CandidateProvider cp, String kategori) {
    final candidates =
        kategori == 'bujang' ? cp.bujangCandidates : cp.gadisCandidates;
    final totalVotes =
        kategori == 'bujang' ? cp.totalVotesBujang : cp.totalVotesGadis;
    final totalPemilih = cp.totalVotesBujang + cp.totalVotesGadis;

    if (candidates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 80, color: AppColors.grey.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('Belum ada data kandidat',
                style: TextStyle(color: AppColors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ✅ TOTAL SUARA CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.how_to_vote,
                    color: AppColors.accent, size: 50),
                const SizedBox(height: 8),
                Text(
                  '$totalVotes',
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Suara ${kategori == 'bujang' ? 'Bujang' : 'Gadis'}',
                  style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 14),
                ),
                if (totalPemilih > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Total Pemilih: $totalPemilih',
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ✅ DIAGRAM LINGKARAN (SELALU TAMPIL DATA)
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('📊 Diagram Suara',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      if (totalVotes > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Live',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ✅ PIE CHART (selalu tampil meskipun 0 suara)
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieSections(candidates, totalVotes),
                        centerSpaceRadius: 45,
                        sectionsSpace: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ LEGEND (selalu tampil)
                  ...candidates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final c = entry.value;
                    final pct = totalVotes > 0
                        ? (c.jumlahSuara / totalVotes) * 100
                        : 0.0;
                    final color = _getColor(index);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          // Indikator warna
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          const SizedBox(width: 12),

                          // Info kandidat
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.nama,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('#${c.nomorUrut}',
                                    style: const TextStyle(
                                        color: AppColors.grey, fontSize: 11)),
                              ],
                            ),
                          ),

                          // Suara & Progress
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${c.jumlahSuara} suara',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: totalVotes > 0
                                        ? c.jumlahSuara / totalVotes
                                        : 0,
                                    minHeight: 8,
                                    backgroundColor:
                                        color.withOpacity(0.1),
                                    valueColor:
                                        AlwaysStoppedAnimation(color),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  totalVotes > 0
                                      ? '${pct.toStringAsFixed(1)}%'
                                      : '0%',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ✅ RANKING
          if (totalVotes > 0) ...[
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🏆 Ranking',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...cp.getSorted(kategori).asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final c = entry.value;
                      final pct = totalVotes > 0
                          ? (c.jumlahSuara / totalVotes) * 100
                          : 0.0;
                      final medals = ['🥇', '🥈', '🥉'];

                      return ListTile(
                        leading: Text(
                          rank <= 3 ? medals[rank - 1] : '#$rank',
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(c.nama,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${c.jumlahSuara} suara • ${pct.toStringAsFixed(1)}%'),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  // ============ BUILD PIE SECTIONS ============
  List<PieChartSectionData> _buildPieSections(
      List candidates, int totalVotes) {
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.info,
      Colors.orange,
      Colors.pink,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];

    // ✅ Jika totalVotes = 0, tampilkan semua kandidat dengan value sama
    if (totalVotes == 0) {
      return candidates.asMap().entries.map((entry) {
        final index = entry.key;
        final c = entry.value;
        return PieChartSectionData(
          color: colors[index % colors.length],
          value: 1, // ✅ Semua dapat 1 biar terlihat
          title: c.nama.split(' ')[0],
          radius: 80,
          titleStyle: const TextStyle(
            color: AppColors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        );
      }).toList();
    }

    // ✅ Jika ada vote, tampilkan sesuai data
    return candidates.map((c) {
      final pct = (c.jumlahSuara / totalVotes) * 100;
      final index = candidates.indexOf(c);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: c.jumlahSuara.toDouble(),
        title: pct > 8 ? '${pct.toStringAsFixed(1)}%' : '',
        radius: 80,
        titleStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }
}