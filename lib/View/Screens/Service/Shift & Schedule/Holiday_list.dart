import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../Controller/Holidaylist_controller.dart';
import '../../../../utils/colers.dart';
import 'package:get/get.dart';

class HolidayList extends StatefulWidget {
  const HolidayList({super.key});

  @override
  State<HolidayList> createState() => _HolidayListState();
}

class _HolidayListState extends State<HolidayList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedYear = DateTime.now().year.toString();

  HolidaylistController controller = Get.put(HolidaylistController());

  // Add this for calendar navigation
  DateTime _currentCalendarDate = DateTime.now();

  // Month names for calendar view
  final List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Fetch holidays when page loads

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Safe getter for holiday data with null handling
  String _getSafeString(Map<String, dynamic>? data, String key, {String defaultValue = 'N/A'}) {
    if (data == null) return defaultValue;
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  // Get all dates for a holiday (handles both single and range holidays)
  List<DateTime> _getHolidayDates(Map<String, dynamic> holiday) {
    List<DateTime> dates = [];

    String holidayType = _getSafeString(holiday, 'holiday_type');

    if (holidayType == 'single') {
      // Single day holiday
      String singleDate = _getSafeString(holiday, 'single_date');
      if (singleDate != 'N/A') {
        try {
          dates.add(DateTime.parse(singleDate));
        } catch (e) {
          print("Error parsing single date: $e");
        }
      }
    } else if (holidayType == 'range') {
      // Range holiday (multiple days)
      String fromDate = _getSafeString(holiday, 'from_date');
      String toDate = _getSafeString(holiday, 'to_date');

      if (fromDate != 'N/A' && toDate != 'N/A') {
        try {
          DateTime start = DateTime.parse(fromDate);
          DateTime end = DateTime.parse(toDate);

          // Generate all dates between from_date and to_date
          for (DateTime date = start;
          date.isBefore(end.add(const Duration(days: 1)));
          date = date.add(const Duration(days: 1))) {
            dates.add(date);
          }
        } catch (e) {
          print("Error parsing range dates: $e");
        }
      }
    }

    return dates;
  }

  // Check if a specific date is a holiday
  bool _isHolidayOnDate(DateTime date, List<dynamic> holidays) {
    for (var holiday in holidays) {
      List<DateTime> holidayDates = _getHolidayDates(holiday);
      for (var holidayDate in holidayDates) {
        if (holidayDate.year == date.year &&
            holidayDate.month == date.month &&
            holidayDate.day == date.day) {
          return true;
        }
      }
    }
    return false;
  }

  // Get holiday for a specific date
  Map<String, dynamic>? _getHolidayForDate(DateTime date, List<dynamic> holidays) {
    for (var holiday in holidays) {
      List<DateTime> holidayDates = _getHolidayDates(holiday);
      for (var holidayDate in holidayDates) {
        if (holidayDate.year == date.year &&
            holidayDate.month == date.month &&
            holidayDate.day == date.day) {
          return holiday;
        }
      }
    }
    return null;
  }

  // Format holiday date range for display
  String _formatHolidayDateRange(Map<String, dynamic> holiday) {
    String holidayType = _getSafeString(holiday, 'holiday_type');

    if (holidayType == 'single') {
      String singleDate = _getSafeString(holiday, 'single_date');
      if (singleDate != 'N/A') {
        try {
          DateTime date = DateTime.parse(singleDate);
          return DateFormat('EEEE, dd MMM yyyy').format(date);
        } catch (e) {
          return singleDate;
        }
      }
    } else if (holidayType == 'range') {
      String fromDate = _getSafeString(holiday, 'from_date');
      String toDate = _getSafeString(holiday, 'to_date');

      if (fromDate != 'N/A' && toDate != 'N/A') {
        try {
          DateTime start = DateTime.parse(fromDate);
          DateTime end = DateTime.parse(toDate);
          return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
        } catch (e) {
          return "$fromDate to $toDate";
        }
      }
    }

    return 'Invalid date';
  }

  // Get short date display for card
  String _getShortDateDisplay(Map<String, dynamic> holiday) {
    String holidayType = _getSafeString(holiday, 'holiday_type');

    if (holidayType == 'single') {
      String singleDate = _getSafeString(holiday, 'single_date');
      if (singleDate != 'N/A') {
        try {
          DateTime date = DateTime.parse(singleDate);
          return '${date.day}\n${DateFormat('MMM').format(date)}';
        } catch (e) {
          return singleDate;
        }
      }
    } else if (holidayType == 'range') {
      String fromDate = _getSafeString(holiday, 'from_date');
      String toDate = _getSafeString(holiday, 'to_date');

      if (fromDate != 'N/A' && toDate != 'N/A') {
        try {
          DateTime start = DateTime.parse(fromDate);
          DateTime end = DateTime.parse(toDate);

          if (start.month == end.month) {
            return '${start.day}-\n${end.day}\n${DateFormat('MMM').format(start)}';
          } else {
            return '${start.day}\n${DateFormat('MMM').format(start)}\nto\n${end.day}\n${DateFormat('MMM').format(end)}';
          }
        } catch (e) {
          return "Multiple\nDays";
        }
      }
    }

    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Holiday List"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All Holidays', icon: Icon(Icons.list)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
            Tab(text: 'By Month', icon: Icon(Icons.view_agenda)),
          ],
        ),
        actions: [
          // // Year selector
          // Container(
          //   margin: const EdgeInsets.only(right: 8),
          //   child: DropdownButton<String>(
          //     value: _selectedYear,
          //     dropdownColor: primary_color,
          //     icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          //     underline: const SizedBox(),
          //     items: ['2024', '2025', '2026', '2027'].map((String year) {
          //       return DropdownMenuItem<String>(
          //         value: year,
          //         child: Text(
          //           year,
          //           style: const TextStyle(color: Colors.white),
          //         ),
          //       );
          //     }).toList(),
          //     onChanged: (String? newValue) {
          //       if (newValue != null) {
          //         setState(() {
          //           _selectedYear = newValue;
          //         });
          //       }
          //     },
          //   ),
          // ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllHolidaysTab(),
          _buildCalendarTab(),
          _buildByMonthTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showHolidayStats,
        backgroundColor: primary_color,
        child: const Icon(Icons.pie_chart),
      ),
    );
  }

  // All Holidays Tab (List View)
  Widget _buildAllHolidaysTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          // Summary Cards
          Obx(() {
            final holidayList = controller.holidaylist.where((h) {
              // Check if any date of this holiday falls in selected year
              List<DateTime> dates = _getHolidayDates(h);
              return dates.any((date) => date.year.toString() == _selectedYear);
            }).toList();

            // Calculate total days (including range days)
            int totalDays = 0;
            for (var holiday in holidayList) {
              totalDays += _getHolidayDates(holiday).length;
            }

            return Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Holidays',
                      holidayList.length.toString(),
                      Icons.celebration,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Days',
                      totalDays.toString(),
                      Icons.calendar_today,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      'Remaining',
                      _getRemainingDays(holidayList).toString(),
                      Icons.event_available,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Holiday List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: primary_color,
                    size: 80,
                  ),
                );
              } else if (controller.holidaylist.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No holidays found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Filter by selected year
                final filteredHolidays = controller.holidaylist.where((h) {
                  List<DateTime> dates = _getHolidayDates(h);
                  return dates.any((date) => date.year.toString() == _selectedYear);
                }).toList();

                // Group holidays by month (using start date for range holidays)
                Map<String, List<dynamic>> groupedHolidays = {};
                for (var holiday in filteredHolidays) {
                  List<DateTime> dates = _getHolidayDates(holiday);
                  if (dates.isNotEmpty) {
                    DateTime firstDate = dates.first;
                    String monthYear = DateFormat('MMMM yyyy').format(firstDate);
                    if (!groupedHolidays.containsKey(monthYear)) {
                      groupedHolidays[monthYear] = [];
                    }
                    groupedHolidays[monthYear]!.add(holiday);
                  }
                }

                // Sort months chronologically
                var sortedKeys = groupedHolidays.keys.toList()
                  ..sort((a, b) {
                    DateFormat format = DateFormat('MMMM yyyy');
                    try {
                      DateTime dateA = format.parse(a);
                      DateTime dateB = format.parse(b);
                      return dateA.compareTo(dateB);
                    } catch (e) {
                      return a.compareTo(b);
                    }
                  });

                if (sortedKeys.isEmpty) {
                  return Center(
                    child: Text('No holidays found for $_selectedYear'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    String monthYear = sortedKeys[index];
                    List<dynamic> monthHolidays = groupedHolidays[monthYear]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Month Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            monthYear,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary_color,
                            ),
                          ),
                        ),
                        // Holidays in this month
                        ...monthHolidays
                            .map((holiday) => _buildHolidayCard(holiday))
                            .toList(),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  // Calendar Tab
  Widget _buildCalendarTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        int currentMonth = _currentCalendarDate.month;
        int currentYear = _currentCalendarDate.year;

        return Column(
          children: [
            // Month Navigation
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _currentCalendarDate = DateTime(currentYear, currentMonth - 1, 1);
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_currentCalendarDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _currentCalendarDate = DateTime(currentYear, currentMonth + 1, 1);
                      });
                    },
                  ),
                ],
              ),
            ),

            // Week Days Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map((day) => Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ))
                    .toList(),
              ),
            ),

            // Calendar Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: 42,
                itemBuilder: (context, index) {
                  int firstDayOfMonth = _getFirstDayOfMonth(currentYear, currentMonth);
                  int daysInMonth = _getDaysInMonth(currentYear, currentMonth);
                  int dayNumber = index - firstDayOfMonth + 1;

                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return Container();
                  }

                  DateTime currentDate = DateTime(currentYear, currentMonth, dayNumber);
                  bool hasHoliday = _isHolidayOnDate(currentDate, controller.holidaylist);
                  Map<String, dynamic>? holiday = _getHolidayForDate(currentDate, controller.holidaylist);
                  bool isToday = currentDate.year == DateTime.now().year &&
                      currentDate.month == DateTime.now().month &&
                      currentDate.day == DateTime.now().day;

                  return _buildCalendarDayWithTick(dayNumber, hasHoliday, holiday, isToday);
                },
              ),
            ),

            // Legend
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Wrap(
                spacing: 20,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildLegendItemWithIcon('Single Day', Colors.green, Icons.check_circle),
                  _buildLegendItemWithIcon('Range Holiday', Colors.orange, Icons.date_range),
                  _buildLegendItemWithIcon('Today', Colors.blue, Icons.today),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // Calendar Day Widget
  Widget _buildCalendarDayWithTick(int day, bool hasHoliday,
      Map<String, dynamic>? holiday, bool isToday) {
    Color? backgroundColor;
    Color textColor = Colors.black87;

    if (isToday) {
      backgroundColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue;
    } else if (hasHoliday) {
      String holidayType = _getSafeString(holiday, 'holiday_type');
      if (holidayType == 'range') {
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
      } else {
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
      }
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: Colors.blue, width: 1.5) : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                fontWeight: (isToday || hasHoliday) ? FontWeight.bold : FontWeight.normal,
                color: textColor,
                fontSize: 16,
              ),
            ),
          ),
          if (hasHoliday)
            Positioned(
              bottom: 2,
              right: 2,
              child: Icon(
                _getSafeString(holiday, 'holiday_type') == 'range'
                    ? Icons.date_range
                    : Icons.check_circle,
                color: _getSafeString(holiday, 'holiday_type') == 'range' ? Colors.orange : Colors.green,
                size: 14,
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods for calendar
  int _getDaysInMonth(int year, int month) {
    if (month == DateTime.february) {
      if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
        return 29;
      } else {
        return 28;
      }
    }
    if (month == DateTime.april ||
        month == DateTime.june ||
        month == DateTime.september ||
        month == DateTime.november) {
      return 30;
    }
    return 31;
  }

  int _getFirstDayOfMonth(int year, int month) {
    DateTime firstDay = DateTime(year, month, 1);
    return firstDay.weekday - 1;
  }

  // By Month Tab
  Widget _buildByMonthTab() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Group holidays by month (based on all dates in range)
        Map<int, List<dynamic>> holidaysByMonth = {};

        for (var holiday in controller.holidaylist) {
          List<DateTime> dates = _getHolidayDates(holiday);
          Set<int> monthsAdded = {};

          for (var date in dates) {
            if (date.year.toString() == _selectedYear && !monthsAdded.contains(date.month)) {
              if (!holidaysByMonth.containsKey(date.month)) {
                holidaysByMonth[date.month] = [];
              }
              if (!holidaysByMonth[date.month]!.contains(holiday)) {
                holidaysByMonth[date.month]!.add(holiday);
                monthsAdded.add(date.month);
              }
            }
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 12,
          itemBuilder: (context, index) {
            int month = index + 1;
            List<dynamic>? monthHolidays = holidaysByMonth[month];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary_color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    months[month - 1],
                    style: TextStyle(
                      color: primary_color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  DateFormat('MMMM').format(DateTime(2024, month)),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${monthHolidays?.length ?? 0} holidays',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary_color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${monthHolidays?.length ?? 0}',
                    style: TextStyle(
                      color: primary_color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                children: monthHolidays != null && monthHolidays.isNotEmpty
                    ? monthHolidays.map((holiday) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildHolidayCard(holiday, isCompact: true),
                )).toList()
                    : [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No holidays this month',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // Holiday Card Widget
  Widget _buildHolidayCard(Map<String, dynamic>? holiday, {bool isCompact = false}) {
    if (holiday == null) return const SizedBox.shrink();

    final holidayName = _getSafeString(holiday, 'holiday_name');
    final holidayType = _getSafeString(holiday, 'holiday_type');
    final description = _getSafeString(holiday, 'description', defaultValue: '');

    bool isRange = holidayType == 'range';
    String dateDisplay = _formatHolidayDateRange(holiday);
    String shortDateDisplay = _getShortDateDisplay(holiday);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRange ? Colors.orange.shade200 : Colors.green.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: isRange ? Colors.orange.withOpacity(0.1) : primary_color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                shortDateDisplay,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isRange ? 12 : 16,
                  fontWeight: FontWeight.bold,
                  color: isRange ? Colors.orange : primary_color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Holiday Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        holidayName,
                        style: TextStyle(
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isRange ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isRange ? 'Multiple Days' : 'Single Day',
                        style: TextStyle(
                          color: isRange ? Colors.orange : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  holidayType,
                  style: TextStyle(
                    color: primary_color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isCompact && description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isRange ? Icons.date_range : Icons.calendar_today,
                      size: 12,
                      color: isRange ? Colors.orange : Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        dateDisplay,
                        style: TextStyle(
                          fontSize: 11,
                          color: isRange ? Colors.orange : Colors.grey.shade500,
                          fontWeight: isRange ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Summary Card
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Legend Item with Icon
  Widget _buildLegendItemWithIcon(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // Helper Methods
  int _getRemainingDays(List<dynamic> holidays) {
    DateTime now = DateTime.now();
    int remainingDays = 0;

    for (var holiday in holidays) {
      List<DateTime> dates = _getHolidayDates(holiday);
      for (var date in dates) {
        if (date.isAfter(now)) {
          remainingDays++;
        }
      }
    }

    return remainingDays;
  }

  void _showHolidayStats() {
    final filteredHolidays = controller.holidaylist.where((h) {
      List<DateTime> dates = _getHolidayDates(h);
      return dates.any((date) => date.year.toString() == _selectedYear);
    }).toList();

    int totalHolidays = filteredHolidays.length;
    int totalDays = 0;
    int singleDayCount = 0;
    int rangeDayCount = 0;

    for (var holiday in filteredHolidays) {
      List<DateTime> dates = _getHolidayDates(holiday);
      totalDays += dates.length;

      if (_getSafeString(holiday, 'holiday_type') == 'single') {
        singleDayCount++;
      } else {
        rangeDayCount++;
      }
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Holiday Statistics ($_selectedYear)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatRow('Total Holidays', totalHolidays, primary_color, isTotal: true),
              _buildStatRow('Total Days Off', totalDays, Colors.blue),
              _buildStatRow('Single Day Holidays', singleDayCount, Colors.green),
              _buildStatRow('Range Holidays', rangeDayCount, Colors.orange),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, int count, Color color, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isTotal ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}