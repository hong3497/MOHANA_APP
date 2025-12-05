import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  double weeklyCompletion = 0.76;
  final List<int> dailyTasks = [2, 3, 5, 1, 4, 6, 3];
  final double collabPercent = 0.6;
  final double focusHours = 4.2;
  final double routineSuccess = 0.83;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: AppBar(
        title: const Text('분석 / 통계'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /* ✅ 주간 완료율 */
            _buildSectionTitle('이번 주 완료율'),
            const SizedBox(height: 12),
            _buildWeeklyChart(),

            const SizedBox(height: 28),

            /* 📊 일별 완료 개수 */
            _buildSectionTitle('일별 완료 개수'),
            const SizedBox(height: 8),
            _buildBarChart(),

            const SizedBox(height: 28),

            /* 👥 협업 vs 개인 비중 */
            _buildSectionTitle('협업 vs 개인 비중'),
            const SizedBox(height: 8),
            _buildDonutChart(),

            const SizedBox(height: 28),

            /* 🔥 집중시간 / 루틴 달성률 */
            _buildSectionTitle('집중 시간 & 루틴 달성률'),
            const SizedBox(height: 8),
            _buildProgressRow(
              title: '집중 시간',
              value: focusHours,
              maxValue: 6,
              unit: '시간',
              color: Colors.indigo,
            ),
            const SizedBox(height: 16),
            _buildProgressRow(
              title: '루틴 달성률',
              value: routineSuccess * 100,
              maxValue: 100,
              unit: '%',
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  /* ------------------------- 섹션 타이틀 ------------------------- */
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  /* ------------------------- 주간 완료율 (원형) ------------------------- */
  Widget _buildWeeklyChart() {
    return SizedBox(
      height: 160,
      width: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: weeklyCompletion,
            strokeWidth: 12,
            backgroundColor: Colors.grey.shade200,
            color: Colors.indigo,
          ),
          Text(
            '${(weeklyCompletion * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  /* ------------------------- 일별 완료 막대그래프 ------------------------- */
  Widget _buildBarChart() {
    final bars = List.generate(
      dailyTasks.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: dailyTasks[index].toDouble(),
            color: Colors.indigo,
            width: 14,
            borderRadius: BorderRadius.circular(6),
          )
        ],
      ),
    );

    return Container(
      height: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            leftTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['월', '화', '수', '목', '금', '토', '일'];
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: bars,
        ),
      ),
    );
  }

  /* ------------------------- 협업 vs 개인 비율 ------------------------- */
  Widget _buildDonutChart() {
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.indigo,
                  value: collabPercent * 100,
                  title: '${(collabPercent * 100).toInt()}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                PieChartSectionData(
                  color: Colors.teal.shade200,
                  value: (1 - collabPercent) * 100,
                  title:
                      '${((1 - collabPercent) * 100).toInt()}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 35,
            ),
          ),
          const Text(
            '팀 / 개인',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /* ------------------------- 집중/루틴 진행바 ------------------------- */
  Widget _buildProgressRow({
    required String title,
    required double value,
    required double maxValue,
    required String unit,
    required Color color,
  }) {
    final ratio = value / maxValue;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(1)}$unit',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              color: color,
              backgroundColor: Colors.grey.shade200,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}