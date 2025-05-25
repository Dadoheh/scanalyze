import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> analysisResult =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wynik analizy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wykryte składniki',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: analysisResult['ingredients']?.length ?? 0,
                itemBuilder: (context, index) {
                  final ingredient = analysisResult['ingredients'][index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(ingredient['name']),
                      subtitle: Text(ingredient['description'] ?? 'Brak opisu'),
                      trailing: _buildRiskIndicator(ingredient['risk_level']),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(analysisResult),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskIndicator(String? riskLevel) {
    Color color;
    IconData icon;

    switch (riskLevel?.toLowerCase()) {
      case 'high':
        color = Colors.red;
        icon = Icons.warning_amber_rounded;
        break;
      case 'medium':
        color = Colors.orange;
        icon = Icons.info_outline;
        break;
      case 'low':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Icon(icon, color: color);
  }

  Widget _buildSummaryCard(Map<String, dynamic> analysisResult) {
    final compatibility = analysisResult['compatibility_score'] ?? 0;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kompatybilność z twoim profilem: ${(compatibility * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(analysisResult['recommendation'] ?? 'Brak rekomendacji'),
          ],
        ),
      ),
    );
  }
}