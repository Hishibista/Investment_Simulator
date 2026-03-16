import 'package:flutter/material.dart';

class PortfolioAsset {
  final String label;
  final double percentage;
  final Color color;

  PortfolioAsset({
    required this.label,
    required this.percentage,
    required this.color,
  });
}

class PortfolioSample {
  final String title;
  final String bestFor;
  final String expectedReturn;
  final String riskLevel;
  final List<PortfolioAsset> assets;

  PortfolioSample({
    required this.title,
    required this.bestFor,
    required this.expectedReturn,
    required this.riskLevel,
    required this.assets,
  });
}

final List<PortfolioSample> portfolioSamples = [
  PortfolioSample(
    title: "High Risk / High Return",
    bestFor: "Long time horizons (10–20+ years)",
    expectedReturn: "~9–12% annual return (long-term estimate)",
    riskLevel: "High volatility, Large short-term swings possible.",
    assets: [
      PortfolioAsset(label: "Stocks (growth / tech / global equities)", percentage: 80, color: Colors.green),
      PortfolioAsset(label: "Emerging Markets", percentage: 10, color: Colors.blue),
      PortfolioAsset(label: "Corporate Bonds", percentage: 5, color: Colors.orange),
      PortfolioAsset(label: "Cash", percentage: 5, color: Colors.grey),
    ],
  ),
  PortfolioSample(
    title: "Medium Risk / Medium Return",
    bestFor: "Medium to long time horizons (5–10 years)",
    expectedReturn: "~6–8% annual return (estimated)",
    riskLevel: "Moderate volatility, balanced growth and stability.",
    assets: [
      PortfolioAsset(label: "Stocks (Diversified)", percentage: 60, color: Colors.green),
      PortfolioAsset(label: "Corporate Bonds", percentage: 20, color: Colors.orange),
      PortfolioAsset(label: "Emerging Markets", percentage: 10, color: Colors.blue),
      PortfolioAsset(label: "Real Estate (REITs)", percentage: 5, color: Colors.purple),
      PortfolioAsset(label: "Cash", percentage: 5, color: Colors.grey),
    ],
  ),
  PortfolioSample(
    title: "Low Risk / Low Return",
    bestFor: "Short to medium time horizons (3–5 years)",
    expectedReturn: "~3–5% annual return (estimated)",
    riskLevel: "Low volatility, focuses on capital preservation.",
    assets: [
      PortfolioAsset(label: "Government Bonds", percentage: 50, color: Colors.red),
      PortfolioAsset(label: "Corporate Bonds", percentage: 20, color: Colors.orange),
      PortfolioAsset(label: "Stocks (Defensive)", percentage: 15, color: Colors.green),
      PortfolioAsset(label: "Cash", percentage: 15, color: Colors.grey),
    ],
  ),
  PortfolioSample(
    title: "Conservative (Preservation)",
    bestFor: "Short time horizons (less than 3 years)",
    expectedReturn: "~1–3% annual return (estimated)",
    riskLevel: "Minimal volatility, high liquidity and safety.",
    assets: [
      PortfolioAsset(label: "Government Bonds", percentage: 60, color: Colors.red),
      PortfolioAsset(label: "Cash / Money Market", percentage: 30, color: Colors.grey),
      PortfolioAsset(label: "Stocks (Value/Blue-chip)", percentage: 10, color: Colors.green),
    ],
  ),
];
