import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:fl_chart/fl_chart.dart';

class LeaveBalance extends StatefulWidget {
  const LeaveBalance({super.key});

  @override
  State<LeaveBalance> createState() => _LeaveBalanceState();
}

class _LeaveBalanceState extends State<LeaveBalance> {
  // Leave balance data
  final Map<String, dynamic> paidLeave = {
    'total': 24,
    'used': 18,
    'remaining': 6,
    'pending': 2,
  };

  final List<Map<String, dynamic>> leaveCategories = [
    {
      'type': 'Casual Leave',
      'icon': Icons.beach_access,
      'color': Colors.blue,
      'total': 12,
      'used': 8,
      'remaining': 4,
    },
    {
      'type': 'Sick Leave',
      'icon': Icons.local_hospital,
      'color': Colors.green,
      'total': 10,
      'used': 6,
      'remaining': 4,
    },
    {
      'type': 'Earned Leave',
      'icon': Icons.account_balance,
      'color': Colors.orange,
      'total': 15,
      'used': 12,
      'remaining': 3,
    },
    {
      'type': 'Compensatory Off',
      'icon': Icons.timer,
      'color': Colors.purple,
      'total': 5,
      'used': 2,
      'remaining': 3,
    },
  ];

  // Monthly leave data for charts
  final List<Map<String, dynamic>> monthlyLeaveData = [
    {'month': 'Jan', 'used': 3, 'available': 21},
    {'month': 'Feb', 'used': 4, 'available': 17},
    {'month': 'Mar', 'used': 2, 'available': 15},
    {'month': 'Apr', 'used': 5, 'available': 10},
    {'month': 'May', 'used': 3, 'available': 7},
    {'month': 'Jun', 'used': 1, 'available': 6},
  ];

  int _selectedChartType = 0; // 0 for bar chart, 1 for pie chart

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        title: const Text("Leave Balance"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_selectedChartType == 0 ? Icons.pie_chart : Icons.bar_chart),
            onPressed: () {
              setState(() {
                _selectedChartType = _selectedChartType == 0 ? 1 : 0;
              });
            },
            tooltip: _selectedChartType == 0 ? "Show Pie Chart" : "Show Bar Chart",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Paid Leave Summary Card
            _buildPaidLeaveCard(),

            const SizedBox(height: 20),

            // Charts Section
            _buildChartSection(),

            // const SizedBox(height: 20),
            //
            // // Leave Categories
            // _buildSectionHeader("Leave Categories", Icons.category),
            // const SizedBox(height: 12),
            // ...leaveCategories.map((leave) => _buildLeaveCategoryCard(leave)).toList(),

            const SizedBox(height: 20),

            // Monthly Breakdown
            _buildSectionHeader("Monthly Breakdown", Icons.calendar_month),
            const SizedBox(height: 12),
            _buildMonthlyBreakdown(),

            const SizedBox(height: 20),

            // Leave Summary Table
            _buildSectionHeader("Leave Summary", Icons.summarize),
            const SizedBox(height: 12),
            _buildLeaveSummaryTable(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaidLeaveCard() {
    double usedPercentage = paidLeave['used'] / paidLeave['total'];
    double remainingPercentage = paidLeave['remaining'] / paidLeave['total'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
       color: primary_color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary_color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.paid, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Text(
                "Total Paid Leave",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPaidLeaveStat(
                label: "Total",
                value: "${paidLeave['total']}",
                icon: Icons.event_available,
                color: Colors.white,
              ),
              _buildPaidLeaveStat(
                label: "Used",
                value: "${paidLeave['used']}",
                icon: Icons.check_circle,
                color: Colors.green.shade300,
              ),
              _buildPaidLeaveStat(
                label: "Remaining",
                value: "${paidLeave['remaining']}",
                icon: Icons.hourglass_empty,
                color: Colors.orange.shade300,
              ),
              _buildPaidLeaveStat(
                label: "Pending",
                value: "${paidLeave['pending']}",
                icon: Icons.pending,
                color: Colors.yellow.shade300,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress indicators
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Used: ${paidLeave['used']} days",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "${(usedPercentage * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: usedPercentage,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 12,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Remaining: ${paidLeave['remaining']} days",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "${(remainingPercentage * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: remainingPercentage,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  minHeight: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaidLeaveStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Leave Analytics",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primary_color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedChartType == 0 ? "Bar Chart" : "Pie Chart",
                  style: TextStyle(
                    color: primary_color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: _selectedChartType == 0 ? _buildBarChart() : _buildPieChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 25,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String month = monthlyLeaveData[groupIndex]['month'];
              return BarTooltipItem(
                '$month\n${rod.toY.toStringAsFixed(0)} days',
                const TextStyle(color: Colors.white),
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
                if (value.toInt() >= 0 && value.toInt() < monthlyLeaveData.length) {
                  return Text(
                    monthlyLeaveData[value.toInt()]['month'],
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 5),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: monthlyLeaveData.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> data = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data['used'].toDouble(),
                color: Colors.blue,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: data['available'].toDouble(),
                color: Colors.green.shade200,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            value: paidLeave['used'].toDouble(),
            title: '${paidLeave['used']}',
            color: Colors.blue,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: paidLeave['remaining'].toDouble(),
            title: '${paidLeave['remaining']}',
            color: Colors.green,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: paidLeave['pending'].toDouble(),
            title: '${paidLeave['pending']}',
            color: Colors.orange,
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildLeaveCategoryCard(Map<String, dynamic> leave) {
  //   double usedPercentage = leave['used'] / leave['total'];
  //
  //   return Card(
  //     margin: const EdgeInsets.only(bottom: 12),
  //     elevation: 2,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.all(8),
  //                 decoration: BoxDecoration(
  //                   color: leave['color'].withOpacity(0.1),
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: Icon(
  //                   leave['icon'],
  //                   color: leave['color'],
  //                   size: 22,
  //                 ),
  //               ),
  //               const SizedBox(width: 12),
  //               Expanded(
  //                 child: Text(
  //                   leave['type'],
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                     color: leave['color'],
  //                   ),
  //                 ),
  //               ),
  //               Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                 decoration: BoxDecoration(
  //                   color: leave['color'].withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(20),
  //                 ),
  //                 child: Text(
  //                   "${leave['remaining']} left",
  //                   style: TextStyle(
  //                     color: leave['color'],
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 12,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "Total: ${leave['total']} days",
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         color: Colors.grey.shade600,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       "Used: ${leave['used']} days",
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         color: Colors.grey.shade600,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "Remaining: ${leave['remaining']} days",
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         color: leave['color'],
  //                         fontWeight: FontWeight.w600,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       "${(usedPercentage * 100).toStringAsFixed(1)}% used",
  //                       style: TextStyle(
  //                         fontSize: 12,
  //                         color: Colors.grey.shade600,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 12),
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(6),
  //             child: LinearProgressIndicator(
  //               value: usedPercentage,
  //               backgroundColor: Colors.grey.shade200,
  //               valueColor: AlwaysStoppedAnimation<Color>(leave['color']),
  //               minHeight: 8,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMonthlyBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Table(
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                children: [
                  _buildTableCell("Month", isHeader: true),
                  _buildTableCell("Used", isHeader: true),
                  _buildTableCell("Available", isHeader: true),
                  _buildTableCell("Status", isHeader: true),
                ],
              ),
              ...monthlyLeaveData.map((data) {
                return TableRow(
                  children: [
                    _buildTableCell(data['month']),
                    _buildTableCell("${data['used']}"),
                    _buildTableCell("${data['available']}"),
                    _buildTableCell(
                      data['used'] <= 3 ? "Good" : "High Usage",
                      color: data['used'] <= 3 ? Colors.green : Colors.orange,
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: color ?? (isHeader ? Colors.black87 : Colors.grey.shade700),
          fontSize: isHeader ? 14 : 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLeaveSummaryTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Table(
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                children: [
                  _buildTableCell("Leave Type", isHeader: true),
                  _buildTableCell("Total", isHeader: true),
                  _buildTableCell("Used", isHeader: true),
                  _buildTableCell("Left", isHeader: true),
                ],
              ),
              ...leaveCategories.map((leave) {
                return TableRow(
                  children: [
                    _buildTableCell(leave['type']),
                    _buildTableCell("${leave['total']}"),
                    _buildTableCell("${leave['used']}"),
                    _buildTableCell(
                      "${leave['remaining']}",
                      color: leave['remaining'] > 0 ? Colors.green : Colors.red,
                    ),
                  ],
                );
              }).toList(),
              TableRow(
                decoration: BoxDecoration(
                  color: primary_color.withOpacity(0.1),
                ),
                children: [
                  _buildTableCell("Total", isHeader: true),
                  _buildTableCell(
                    "${leaveCategories.fold(0, (sum, item) => sum + (item['total'] as int))}",
                    isHeader: true,
                  ),
                  _buildTableCell(
                    "${leaveCategories.fold(0, (sum, item) => sum + (item['used'] as int))}",
                    isHeader: true,
                  ),
                  _buildTableCell(
                    "${leaveCategories.fold(0, (sum, item) => sum + (item['remaining'] as int))}",
                    isHeader: true,
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: primary_color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}