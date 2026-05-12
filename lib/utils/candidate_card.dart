import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/candidate_model.dart';

class CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  final VoidCallback onTap;
  final bool showVoteButton;
  const CandidateCard({super.key, required this.candidate, required this.onTap, this.showVoteButton = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.black.withOpacity(0.1), blurRadius: 10)]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16))
              ),
              child: Center(
                child: Text(
                  candidate.nama[0],
                  style: const TextStyle(
                    fontSize: 50,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold
                  )
                )
              )
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      '#${candidate.nomorUrut}',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11
                      )
                    )
                  ),
                  const SizedBox(height: 8),
                  Text(
                    candidate.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 4),
                  Text(
                    candidate.visi,
                    style: TextStyle(color: AppColors.grey, fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis
                  ),
                  if (showVoteButton) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Center(
                        child: Text(
                          'PILIH',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          )
                        )
                      )
                    )
                  ],
                ]
              )
            ),
          ]
        ),
      ),
    );
  }
}