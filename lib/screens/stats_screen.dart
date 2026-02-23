import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/category_provider.dart';
import '../utils/theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedTabIndex = 0;
  bool _isExpense = true;
  String _trendPeriod = 'Daily'; // 'Daily', 'Weekly', 'Monthly'
  DateTime _trendDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // Taller for "smooth" header look
        title: const Text('Statistics', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            // borderRadius removed as per user request
            boxShadow: [
              // Add shadow for depth
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildMainTabs(),
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildOverviewView(context)
                : _buildTrendView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMainTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Overview',
                    style: TextStyle(
                      color: _selectedTabIndex == 0
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Trend',
                    style: TextStyle(
                      color: _selectedTabIndex == 1
                          ? Colors.white
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewView(BuildContext context) {
    return Column(
      children: [
        // Toggle
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isExpense = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isExpense
                          ? AppTheme.expenseColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow:
                          _isExpense &&
                              Theme.of(context).brightness == Brightness.light
                          ? AppTheme.softShadow
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          color: _isExpense ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isExpense = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isExpense
                          ? AppTheme.incomeColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow:
                          !_isExpense &&
                              Theme.of(context).brightness == Brightness.light
                          ? AppTheme.softShadow
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        'Income',
                        style: TextStyle(
                          color: !_isExpense ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildChart(context)),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final settings = Provider.of<SettingsProvider>(context);
        final categoryProvider = Provider.of<CategoryProvider>(context);
        final stats = provider.getCategoryStats(_isExpense);

        if (stats.isEmpty) {
          return Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          );
        }

        final total = stats.values.fold(0.0, (sum, val) => sum + val);

        return Column(
          children: [
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: stats.entries.map((entry) {
                    final percentage = (entry.value / total) * 100;
                    return PieChartSectionData(
                      color: _getColor(entry.key, categoryProvider),
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 80,
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
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: stats.entries.map((entry) {
                  final currencyFormat = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: settings.currencySymbol,
                    decimalDigits: 0,
                  );
                  // Find corresponding CategoryModel to check for budget
                  final catModelList = categoryProvider.categories
                      .where((c) => c.name == entry.key)
                      .toList();
                  final catModel = catModelList.isNotEmpty
                      ? catModelList.first
                      : null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          Theme.of(context).brightness == Brightness.light
                          ? AppTheme.softShadow
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getColor(entry.key, categoryProvider),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              currencyFormat.format(entry.value),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (catModel != null && catModel.budget > 0) ...[
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Budget: ${currencyFormat.format(catModel.budget)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                '${((entry.value / catModel.budget) * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: entry.value > catModel.budget
                                      ? Colors.red
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (entry.value / catModel.budget).clamp(
                                0.0,
                                1.0,
                              ),
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                entry.value > catModel.budget
                                    ? Colors.red
                                    : AppTheme.primaryColor,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getColor(String categoryName, CategoryProvider categoryProvider) {
    final catModelList = categoryProvider.categories
        .where((c) => c.name == categoryName)
        .toList();
    if (catModelList.isNotEmpty) {
      return Color(catModelList.first.color);
    }

    // Fallback if category not found or deleted
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[categoryName.hashCode % colors.length];
  }

  Widget _buildTrendView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildTrendPeriodSelector(),
        _buildTrendDateSelector(),
        Expanded(child: _buildBarChart(context)),
        // Provide legend below the chart
        Padding(
          padding: const EdgeInsets.only(bottom: 20, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppTheme.incomeColor, 'Income'),
              const SizedBox(width: 20),
              _buildLegendItem(AppTheme.expenseColor, 'Expense'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTrendPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['Daily', 'Weekly', 'Monthly'].map((period) {
          final isSelected = _trendPeriod == period;
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(
                period,
                style: TextStyle(
                  color: isSelected
                      ? (isDarkMode ? Colors.black : Colors.black87)
                      : (isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _trendPeriod = period);
              },
              selectedColor: isDarkMode
                  ? Colors.blue.shade200
                  : Colors.blue.shade100,
              backgroundColor: isDarkMode ? Colors.grey.shade800 : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrendDateSelector() {
    String dateText = '';
    if (_trendPeriod == 'Daily' || _trendPeriod == 'Weekly') {
      dateText = DateFormat('MMMM yyyy').format(_trendDate);
    } else {
      dateText = DateFormat('yyyy').format(_trendDate);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                if (_trendPeriod == 'Monthly') {
                  _trendDate = DateTime(_trendDate.year - 1);
                } else {
                  _trendDate = DateTime(_trendDate.year, _trendDate.month - 1);
                }
              });
            },
          ),
          Text(
            dateText,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                if (_trendPeriod == 'Monthly') {
                  _trendDate = DateTime(_trendDate.year + 1);
                } else {
                  _trendDate = DateTime(_trendDate.year, _trendDate.month + 1);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final settings = Provider.of<SettingsProvider>(context);
        List<Map<String, dynamic>> data = [];
        if (_trendPeriod == 'Daily') {
          data = provider.getDailyTrends(_trendDate);
        } else if (_trendPeriod == 'Weekly') {
          data = provider.getWeeklyTrends(_trendDate);
        } else {
          data = provider.getMonthlyTrends(_trendDate.year);
        }

        if (data.isEmpty) {
          return const Center(child: Text('No data'));
        }

        double maxY = 0;
        for (var item in data) {
          if (item['income'] > maxY) maxY = item['income'];
          if (item['expense'] > maxY) maxY = item['expense'];
        }
        if (maxY == 0) maxY = 100;

        double interval = (maxY / 4) > 0 ? (maxY / 4) : 25;

        double barWidth = _trendPeriod == 'Daily' ? 16 : 24;

        Widget originalChart = BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceEvenly,
            maxY: maxY * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final isIncome = rodIndex == 0;
                  final realValue = isIncome
                      ? data[groupIndex]['income']
                      : data[groupIndex]['expense'];

                  final valStr = NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: settings.currencySymbol,
                    decimalDigits: 0,
                  ).format(realValue);
                  return BarTooltipItem(
                    valStr,
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() >= 0 && value.toInt() < data.length) {
                      String label = data[value.toInt()]['label'];
                      // Good font size since we will scroll horizontally
                      double fSize = 10;

                      return SideTitleWidget(
                        meta: meta,
                        space: 4,
                        child: Text(
                          label,
                          style: TextStyle(fontSize: fSize, color: Colors.grey),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 64,
                  interval: interval,
                  getTitlesWidget: (value, meta) {
                    if (value == maxY * 1.2) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      NumberFormat.decimalPattern('id_ID').format(value),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: interval,
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> item = entry.value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: item['income'] > 0 && item['income'] < (maxY * 0.05)
                        ? (maxY * 0.05)
                        : item['income'],
                    color: AppTheme.incomeColor,
                    width: barWidth,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  BarChartRodData(
                    toY: item['expense'] > 0 && item['expense'] < (maxY * 0.05)
                        ? (maxY * 0.05)
                        : item['expense'],
                    color: AppTheme.expenseColor,
                    width: barWidth,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              );
            }).toList(),
          ),
        );

        Widget chartWidget = originalChart;

        if (_trendPeriod == 'Daily') {
          chartWidget = LayoutBuilder(
            builder: (context, constraints) {
              // Calculate width: per day width for two thick bars + margin + Y axis
              double requiredWidth = (data.length * 50.0) + 64;
              double width = requiredWidth > constraints.maxWidth
                  ? requiredWidth
                  : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: originalChart,
                  ),
                ),
              );
            },
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 10,
            right: _trendPeriod == 'Daily' ? 0 : 30,
            top: 20,
            bottom: 10,
          ),
          child: chartWidget,
        );
      },
    );
  }
}
