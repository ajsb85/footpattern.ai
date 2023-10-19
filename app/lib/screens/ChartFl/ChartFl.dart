import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartWidget extends StatefulWidget {
  const BarChartWidget({Key? key}) : super(key: key);

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: BarChart(
        BarChartData(
          barGroups: _chartGroups(),
          borderData: FlBorderData(
            border: const Border(bottom: BorderSide(), left: BorderSide()),
          ),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: _bottomTitles),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _chartGroups() {
    final Map<int, int> monthlyAttendance = _generateMonthlyAttendance();

    return List.generate(
      12,
      (index) {
        return BarChartGroupData(
          x: index.toDouble().toInt(),
          barRods: [
            BarChartRodData(
                toY: monthlyAttendance[index + 1]!.toDouble(),
                color: Colors.blue),
          ],
        );
      },
    );
  }

  Map<int, int> _generateMonthlyAttendance() {
    final Map<int, int> monthlyAttendance = {};

    // Generate synthetic attendance data
    final random = Random();
    for (int i = 1; i <= 12; i++) {
      monthlyAttendance[i] = random.nextInt(50) +
          10; // Random attendance numbers (between 10 and 60)
    }

    return monthlyAttendance;
  }

  SideTitles get _bottomTitles => SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String text = '';
          switch (value.toInt()) {
            case 0:
              text = 'Jan';
              break;
            case 2:
              text = 'Mar';
              break;
            case 4:
              text = 'May';
              break;
            case 6:
              text = 'Jul';
              break;
            case 8:
              text = 'Sep';
              break;
            case 10:
              text = 'Nov';
              break;
          }

          return Text(text);
        },
      );
}
