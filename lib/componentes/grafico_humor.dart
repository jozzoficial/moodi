import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'tema.dart';

class GraficoHumor extends StatelessWidget {
  final Map<String, double> dadosHumor;

  const GraficoHumor({
    super.key,
    required this.dadosHumor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _gerarSecoes(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _gerarSecoes() {
    final List<Color> cores = [
      TemaMoodi.primarioContainer,
      TemaMoodi.secundario,
      TemaMoodi.secundarioContainer,
      TemaMoodi.contorno,
    ];

    int index = 0;
    return dadosHumor.entries.map((entrada) {
      final cor = cores[index % cores.length];
      index++;
      return PieChartSectionData(
        color: cor,
        value: entrada.value,
        title: '${entrada.value.toInt()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
