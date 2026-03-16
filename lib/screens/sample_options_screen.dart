import 'package:flutter/material.dart';
import '../models/portfolio_sample.dart';
import 'sample_details_screen.dart';

class SampleOptionsScreen extends StatelessWidget {
  const SampleOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose a Portfolio"),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24.0),
        itemCount: portfolioSamples.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final sample = portfolioSamples[index];
          return _PortfolioOptionCard(
            sample: sample,
            index: index,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SampleDetailsScreen(initialPage: index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PortfolioOptionCard extends StatelessWidget {
  final PortfolioSample sample;
  final int index;
  final VoidCallback onTap;

  const _PortfolioOptionCard({
    required this.sample,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withAlpha(20),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sample.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sample.riskLevel.split(',').first,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
