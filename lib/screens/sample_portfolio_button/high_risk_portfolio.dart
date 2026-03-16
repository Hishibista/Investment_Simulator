import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/portfolio_sample.dart';

class SampleDetailsScreen extends StatelessWidget {
  final int initialPage;
  const SampleDetailsScreen({super.key, this.initialPage = 0});

  @override
  Widget build(BuildContext context) {
    // theme for consistent styling 
    final theme = Theme.of(context);
    // page controller allows horizontal swiping between sa,ple portfolios
    final PageController controller = PageController(initialPage: initialPage);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sample Portfolio"),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: portfolioSamples.length,
        itemBuilder: (context, index) {
          //get portfolio sample for current page.
          final sample = portfolioSamples[index];
          return SingleChildScrollView(
            // adds a bouncing scroll effect 
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                children: [
                  Text(
                    sample.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Just the high-level risk
                    sample.riskLevel.split(',').first, 
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  // Main Attention: Large Pie Chart
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.8,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        //empty space in center of chart 
                        centerSpaceRadius: MediaQuery.of(context).size.width * 0.15,

                        //convert asset allocations into pie slices
                        sections: sample.assets.map((asset) {
                          return PieChartSectionData(
                            color: asset.color,
                            value: asset.percentage,

                            //label shown on slice
                            title: '${asset.percentage.toInt()}%',
                            radius: MediaQuery.of(context).size.width * 0.2,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: sample.assets.map((asset) => _LegendItem(asset: asset)).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final PortfolioAsset asset;

  const _LegendItem({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: asset.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              asset.label,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ),
          Text(
            "${asset.percentage.toInt()}%",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
