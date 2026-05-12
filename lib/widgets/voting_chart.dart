import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/app_colors.dart';
import '../models/candidate_model.dart';

class VotingChart extends StatelessWidget {
  final List<CandidateModel> candidates;
  final Map<String, double> percentages;
  final int totalVotes;

  const VotingChart({
    super.key,
    required this.candidates,
    required this.percentages,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 260,
          child: PieChart(
            PieChartData(
              sections: _getPieChartSections(),
              centerSpaceRadius: 60,
              sectionsSpace: 3,
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...candidates.map((candidate) {
          final percentage = percentages[candidate.id] ?? 0;
          return _VoteProgressItem(
            candidate: candidate,
            percentage: percentage,
            totalVotes: totalVotes,
            isDark: isDark,
          );
        }),
      ],
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.success,
      AppColors.info,
      AppColors.warning,
      AppColors.error,
      Colors.purple,
      Colors.teal,
    ];

    return candidates.asMap().entries.map((entry) {
      final index = entry.key;
      final candidate = entry.value;
      final percentage = percentages[candidate.id] ?? 0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: percentage > 0 ? percentage : 0.1,
        title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 90,
        titleStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }
}

class _VoteProgressItem extends StatelessWidget {
  final CandidateModel candidate;
  final double percentage;
  final int totalVotes;
  final bool isDark;

  const _VoteProgressItem({
    required this.candidate,
    required this.percentage,
    required this.totalVotes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '#${candidate.nomorUrut} ${candidate.nama}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}% (${candidate.jumlahSuara} suara)',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: (AppColors.grey).withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}