import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> apiResponse =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    // Extract decision data from new structure
    final Map<String, dynamic> decision = apiResponse['decision'] ?? {};
    final List<dynamic> ingredients = decision['ingredients'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wynik analizy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall risk summary card at top
            _buildOverallRiskCard(decision),
            const SizedBox(height: 16),
            const Text(
              'Wykryte składniki',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredients[index];
                  return _buildIngredientCard(ingredient);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskIndicator(String? riskLevel) {
    Color color;
    IconData icon;
    String label;

    switch (riskLevel?.toUpperCase()) {
      case 'CRITICAL':
        color = Colors.red[900]!;
        icon = Icons.dangerous;
        label = 'KRYTYCZNE';
        break;
      case 'HIGH':
        color = Colors.red;
        icon = Icons.warning_amber_rounded;
        label = 'WYSOKIE';
        break;
      case 'MODERATE':
        color = Colors.orange;
        icon = Icons.info_outline;
        label = 'UMIARKOWANE';
        break;
      case 'LOW':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        label = 'NISKIE';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
        label = 'NIEZNANE';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOverallRiskCard(Map<String, dynamic> decision) {
    final String overallRisk = decision['overall_risk'] ?? 'UNKNOWN';
    final int riskScore = (decision['risk_score'] ?? 0).round();
    final String recommendation = decision['recommendation'] ?? 'Brak rekomendacji';

    Color cardColor;
    switch (overallRisk.toUpperCase()) {
      case 'CRITICAL':
        cardColor = Colors.red[50]!;
        break;
      case 'HIGH':
        cardColor = Colors.orange[50]!;
        break;
      case 'MODERATE':
        cardColor = Colors.yellow[50]!;
        break;
      case 'LOW':
        cardColor = Colors.green[50]!;
        break;
      default:
        cardColor = Colors.grey[50]!;
    }

    return Card(
      color: cardColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Ogólna ocena ryzyka: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                _buildRiskIndicator(overallRisk),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Wynik: $riskScore/100',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              recommendation,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientCard(Map<String, dynamic> ingredient) {
    final String inci = ingredient['inci'] ?? 'Nieznany';
    final double riskScoreDouble = (ingredient['risk_score'] ?? 0).toDouble();
    final int riskScore = riskScoreDouble.round();
    final String riskLevel = ingredient['risk_level'] ?? 'UNKNOWN';
    final List<dynamic> reasons = ingredient['reasons'] ?? [];
    final Map<String, dynamic>? scoreBreakdown = ingredient['score_breakdown'];
    final Map<String, dynamic>? hedAssessment = ingredient['hed_assessment'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          inci.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Ryzyko: $riskScore/100'),
        trailing: _buildRiskIndicator(riskLevel),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (reasons.isNotEmpty) ...[
                  const Text(
                    'Powody oceny:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...reasons.map((reason) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• '),
                        Expanded(child: Text(reason.toString())),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),
                ],
                if (scoreBreakdown != null) ...[
                  const Text(
                    'Rozbicie wyniku:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildScoreBreakdown(scoreBreakdown),
                  const SizedBox(height: 12),
                ],
                if (hedAssessment != null) ...[
                  const Text(
                    'Ocena toksykologiczna (HED):',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildHedAssessment(hedAssessment),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdown(Map<String, dynamic> breakdown) {
    final Map<String, String> labels = {
      'blacklist': 'Czarna lista',
      'hed': 'Toksyczność (HED)',
      'profile_match': 'Dopasowanie profilu',
      'medication': 'Interakcje lekowe',
      'preference': 'Preferencje użytkownika',
      'environmental': 'Czynniki środowiskowe',
    };

    return Column(
      children: breakdown.entries.map((entry) {
        final int value = (entry.value ?? 0).round();
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(labels[entry.key] ?? entry.key),
              ),
              Expanded(
                flex: 2,
                child: LinearProgressIndicator(
                  value: value / 100,
                  backgroundColor: Colors.grey[300],
                  color: value > 60 ? Colors.red : (value > 30 ? Colors.orange : Colors.green),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text('$value', textAlign: TextAlign.right),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHedAssessment(Map<String, dynamic> hed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hed['hed_mg_kg'] != null)
            Text('HED: ${hed['hed_mg_kg']?.toStringAsFixed(2)} mg/kg'),
          if (hed['safe_concentration_percent'] != null)
            Text('Bezpieczne stężenie: ${hed['safe_concentration_percent']?.toStringAsFixed(2)}%'),
          if (hed['risk_assessment'] != null)
            Text('Ocena: ${hed['risk_assessment']}'),
          if (hed['recommendation'] != null)
            Text('Rekomendacja: ${hed['recommendation']}'),
          if (hed['source_species'] != null)
            Text('Źródło: ${hed['source_species']} (${hed['source_type'] ?? 'N/A'})'),
        ],
      ),
    );
  }

  // Removed old _buildSummaryCard - now using _buildOverallRiskCard
}