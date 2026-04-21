import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';

class LeaveCancle extends StatefulWidget {
  const LeaveCancle({super.key});

  @override
  State<LeaveCancle> createState() => _LeaveCancleState();
}

class _LeaveCancleState extends State<LeaveCancle> {
  // Sample pending leave data
  List<Map<String, dynamic>> pendingLeaves = [
    {
      'id': 'LV003',
      'type': 'Earned Leave',
      'icon': Icons.account_balance,
      'color': Colors.orange,
      'fromDate': DateTime(2024, 3, 20),
      'toDate': DateTime(2024, 3, 25),
      'days': 5,
      'reason': 'Vacation trip to Goa',
      'appliedOn': DateTime(2024, 3, 15),
      'status': 'Pending',
      'document': null,
    },
    {
      'id': 'LV009',
      'type': 'Casual Leave',
      'icon': Icons.beach_access,
      'color': Colors.blue,
      'fromDate': DateTime(2024, 3, 18),
      'toDate': DateTime(2024, 3, 19),
      'days': 2,
      'reason': 'Family function',
      'appliedOn': DateTime(2024, 3, 16),
      'status': 'Pending',
      'document': 'function_invite.pdf',
    },
    {
      'id': 'LV010',
      'type': 'Sick Leave',
      'icon': Icons.local_hospital,
      'color': Colors.green,
      'fromDate': DateTime(2024, 3, 22),
      'toDate': DateTime(2024, 3, 23),
      'days': 2,
      'reason': 'Medical appointment',
      'appliedOn': DateTime(2024, 3, 17),
      'status': 'Pending',
      'document': 'doctor_prescription.pdf',
    },
    {
      'id': 'LV011',
      'type': 'WFH',
      'icon': Icons.home_work,
      'color': Colors.purple,
      'fromDate': DateTime(2024, 3, 25),
      'toDate': DateTime(2024, 3, 26),
      'days': 2,
      'reason': 'Internet connectivity issues at home',
      'appliedOn': DateTime(2024, 3, 18),
      'status': 'Pending',
      'document': null,
    },
    {
      'id': 'LV012',
      'type': 'Compensatory Off',
      'icon': Icons.timer,
      'color': Colors.teal,
      'fromDate': DateTime(2024, 3, 28),
      'toDate': DateTime(2024, 3, 28),
      'days': 1,
      'reason': 'Weekend work compensation',
      'appliedOn': DateTime(2024, 3, 19),
      'status': 'Pending',
      'document': 'timesheet.pdf',
    },
  ];

  // Selected leaves for bulk cancellation
  final Set<String> _selectedLeaves = {};
  bool _isSelectionMode = false;

  // Date format
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _dayFormat = DateFormat('EEEE');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        title: Text(_isSelectionMode ? "Select Leaves" : "Leave Cancel"),
        elevation: 0,
        actions: [
          if (!_isSelectionMode && pendingLeaves.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _enableSelectionMode,
              tooltip: 'Select multiple',
            ),
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectAll,
              tooltip: 'Select all',
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _cancelSelectionMode,
              tooltip: 'Cancel selection',
            ),
          ],
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Column(
          children: [
            // Info Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade700,
                    Colors.orange.shade500,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Leave Requests',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You have ${pendingLeaves.length} pending leave request${pendingLeaves.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Cancel Instruction
            if (_isSelectionMode)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Select the leaves you want to cancel and tap the cancel button',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Pending Leaves List
            Expanded(
              child: pendingLeaves.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: Colors.green.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Pending Leaves',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All your leave requests have been processed',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingLeaves.length,
                itemBuilder: (context, index) {
                  final leave = pendingLeaves[index];
                  final isSelected = _selectedLeaves.contains(leave['id']);

                  return _buildPendingLeaveCard(leave, isSelected, index);
                },
              ),
            ),
          ],
        ),
      ),
      // Bottom Action Bar for Selection Mode
      bottomNavigationBar: _isSelectionMode && _selectedLeaves.isNotEmpty
          ? Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_selectedLeaves.length} Selected',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_getSelectedDays()} days total',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showBulkCancelConfirmation,
              icon: const Icon(Icons.cancel),
              label: Text('Cancel ${_selectedLeaves.length} Leave${_selectedLeaves.length > 1 ? 's' : ''}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      )
          : null,
    );
  }

  Widget _buildPendingLeaveCard(Map<String, dynamic> leave, bool isSelected, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? leave['color'] : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (_isSelectionMode) {
            _toggleSelection(leave['id']);
          } else {
            _showLeaveDetails(leave);
          }
        },
        onLongPress: () {
          if (!_isSelectionMode) {
            _enableSelectionMode();
            _toggleSelection(leave['id']);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected ? leave['color'].withOpacity(0.05) : Colors.white,
          ),
          child: Stack(
            children: [
              // Selection Indicator
              if (_isSelectionMode)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? leave['color'] : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.circle_outlined,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),

              Column(
                children: [
                  // Header with ID and Type
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: leave['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          leave['icon'],
                          color: leave['color'],
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              leave['type'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: leave['color'],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${leave['id']}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'Pending',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Date Range
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                _dateFormat.format(leave['fromDate']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _dayFormat.format(leave['fromDate']),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: leave['color'],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                _dateFormat.format(leave['toDate']),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _dayFormat.format(leave['toDate']),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Reason and Days
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.description,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                leave['reason'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: leave['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${leave['days']} ${leave['days'] == 1 ? 'day' : 'days'}',
                          style: TextStyle(
                            color: leave['color'],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Footer with Applied Date and Document
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Applied: ${_dateFormat.format(leave['appliedOn'])}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      if (leave['document'] != null)
                        Row(
                          children: [
                            Icon(
                              Icons.attach_file,
                              size: 12,
                              color: Colors.blue.shade500,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Attachment',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Cancel Button (when not in selection mode)
                  if (!_isSelectionMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showCancelConfirmation(leave),
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Cancel Request'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _enableSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedLeaves.clear();
    });
  }

  void _cancelSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedLeaves.clear();
    });
  }

  void _toggleSelection(String leaveId) {
    setState(() {
      if (_selectedLeaves.contains(leaveId)) {
        _selectedLeaves.remove(leaveId);
      } else {
        _selectedLeaves.add(leaveId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedLeaves.length == pendingLeaves.length) {
        _selectedLeaves.clear();
      } else {
        _selectedLeaves.addAll(pendingLeaves.map((l) => l['id'] as String));
      }
    });
  }

  int _getSelectedDays() {
    return pendingLeaves
        .where((l) => _selectedLeaves.contains(l['id']))
        .fold(0, (sum, l) => sum + (l['days'] as int));
  }

  void _showCancelConfirmation(Map<String, dynamic> leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Leave Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel your ${leave['type']}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDialogInfoRow('Leave ID', leave['id']),
                  _buildDialogInfoRow('Duration', '${leave['days']} days'),
                  _buildDialogInfoRow(
                    'Date',
                    '${_dateFormat.format(leave['fromDate'])} - ${_dateFormat.format(leave['toDate'])}',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep it'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _performCancellation([leave]);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBulkCancelConfirmation() {
    final selectedLeavesList = pendingLeaves
        .where((l) => _selectedLeaves.contains(l['id']))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel ${selectedLeavesList.length} Leaves'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel ${selectedLeavesList.length} selected leave request${selectedLeavesList.length > 1 ? 's' : ''}?',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDialogInfoRow('Total Leaves', '${selectedLeavesList.length}'),
                  _buildDialogInfoRow('Total Days', '${_getSelectedDays()} days'),
                  _buildDialogInfoRow(
                    'Date Range',
                    '${_dateFormat.format(selectedLeavesList.first['fromDate'])} - ${_dateFormat.format(selectedLeavesList.last['toDate'])}',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _performBulkCancellation(selectedLeavesList);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Yes, Cancel ${selectedLeavesList.length}'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _performCancellation(List<Map<String, dynamic>> leaves) {
    setState(() {
      for (var leave in leaves) {
        pendingLeaves.removeWhere((l) => l['id'] == leave['id']);
      }
      _selectedLeaves.clear();
      _isSelectionMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${leaves.length} leave request${leaves.length > 1 ? 's' : ''} cancelled successfully',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _performBulkCancellation(List<Map<String, dynamic>> leaves) {
    _performCancellation(leaves);
  }

  void _showLeaveDetails(Map<String, dynamic> leave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: leave['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          leave['icon'],
                          color: leave['color'],
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              leave['type'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: leave['color'],
                              ),
                            ),
                            Text(
                              'ID: ${leave['id']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'Pending',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Details
                  _buildDetailSection(
                    'Leave Details',
                    [
                      _buildDetailRow('From Date', _dateFormat.format(leave['fromDate'])),
                      _buildDetailRow('To Date', _dateFormat.format(leave['toDate'])),
                      _buildDetailRow('Duration', '${leave['days']} days'),
                      _buildDetailRow('Applied On', _dateFormat.format(leave['appliedOn'])),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildDetailSection(
                    'Reason',
                    [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(leave['reason']),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (leave['document'] != null)
                    _buildDetailSection(
                      'Attachment',
                      [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                color: leave['color'],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(leave['document']),
                              ),
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Cancel Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showCancelConfirmation(leave);
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel this Request'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}