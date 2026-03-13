import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/budget_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/budget_model.dart';
import '../../core/theme/app_colors.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BudgetController>();
    final settingsController = context.watch<SettingsController>();
    final colorScheme = Theme.of(context).colorScheme;
    final categories = controller.categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          settingsController.getString('statistics'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              settingsController.getString('allocatedVsSpent'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (categories.isEmpty)
              Center(
                child: Text(
                  settingsController.getString('noBudgetData'),
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              )
            else
              Container(
                height: 300,
                padding: const EdgeInsets.only(top: 24, right: 16, left: 0, bottom: 0),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(categories),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppColors.sagePrimary.withOpacity(0.8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            'Rp ${rod.toY.toStringAsFixed(0)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < categories.length) {
                              final name = categories[value.toInt()].name;
                              // Menyingkat teks jika terlalu panjang
                              final shortName = name.length > 8 ? '${name.substring(0, 6)}..' : name;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  shortName,
                                  style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 32,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('');
                            // Menyingkat nominal jadi format 'K' (ribu) atau 'M' (juta)
                            String text = '';
                            if (value >= 1000000) {
                              text = '${(value / 1000000).toStringAsFixed(1)}M';
                            } else if (value >= 1000) {
                              text = '${(value / 1000).toStringAsFixed(0)}K';
                            } else {
                              text = value.toStringAsFixed(0);
                            }
                            return Text(
                              text,
                              style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(color: AppColors.sageSecondary.withOpacity(0.2), strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(categories.length, (index) {
                      final cat = categories[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                           // Bar untuk Alokasi (Budget Total)
                          BarChartRodData(
                            toY: cat.allocatedAmount,
                            color: AppColors.sageSecondary.withOpacity(0.4),
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          // Bar untuk Terpakai
                          BarChartRodData(
                            toY: cat.spentAmount,
                            color: AppColors.getDynamicColor(cat.percentageSpent), // Warna menyesuaikan tingkat bahaya
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                        showingTooltipIndicators: [],
                      );
                    }),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Text(
              settingsController.getString('legend'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildLegend(
              context: context,
              color: AppColors.sageSecondary.withOpacity(0.4),
              text: settingsController.getString('totalBudgetAllocation'),
            ),
            const SizedBox(height: 8),
            _buildLegend(
              context: context,
              color: AppColors.sagePrimary,
              text: settingsController.getString('spentSafe'),
            ),
            const SizedBox(height: 8),
            _buildLegend(
              context: context,
              color: AppColors.warningRed,
              text: settingsController.getString('spentWarning'),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY(List<BudgetCategory> categories) {
    if (categories.isEmpty) return 1000000;
    double maxVal = 0;
    for (var cat in categories) {
      if (cat.allocatedAmount > maxVal) maxVal = cat.allocatedAmount;
      if (cat.spentAmount > maxVal) maxVal = cat.spentAmount;
    }
    // Tambahkan 20% margin di atas
    return maxVal * 1.2;
  }

  Widget _buildLegend({required BuildContext context, required Color color, required String text}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
      ],
    );
  }
}
