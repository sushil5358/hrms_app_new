import 'package:employee_app/utils/colers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Controller/Attendance_controller.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final AttensanceController controller = Get.find<AttensanceController>();

  @override
  void initState() {
    super.initState();
    controller.attandancehistory();
  }

  Color getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('present')) return Colors.green;
    if (status.contains('late')) return Colors.orange;
    if (status.contains('half')) return Colors.deepOrange;
    if (status.contains('on time')) return Colors.deepOrange;
    return Colors.red; // Default for Absent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light background
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("Attendance History"),
      ),
      body: Obx(() {
        if (controller.Attsdancehistorylist.isEmpty) {
          return const Center(child: Text("No history found"));
        }
        return RefreshIndicator(
          onRefresh: () async => controller.attandancehistory(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.Attsdancehistorylist.length,
            itemBuilder: (context, index) {
              final record = controller.Attsdancehistorylist[index];
              Color sColor = getStatusColor(record['status'] ?? "Absent");
              return Card(
                elevation: 5,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                record['date'] ?? "-",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: sColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: sColor, width: 1),
                            ),
                            child: Text(
                              record['status']?.toUpperCase() ?? "ABSENT",
                              style: TextStyle(color: sColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // નીચેની લાઈન: In અને Out સમય
                      Row(
                        children: [
                          _timeInfo(
                            icon: Icons.login_rounded,
                            label: "Check In",
                            time: record['checkin'] ?? "-",
                            color: Colors.green,
                          ),
                          Container(height: 30, width: 1, color: Colors.grey.shade300),
                          _timeInfo(
                            icon: Icons.logout_rounded,
                            label: "Check Out",
                            time: record['checkout'] ?? "-",
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }


  Widget _timeInfo({required IconData icon, required String label, required String time, required Color color}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(
                time,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}