import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';

class LeaveHistory extends StatefulWidget {
  const LeaveHistory({super.key});

  @override
  State<LeaveHistory> createState() => _LeaveHistoryState();
}

class _LeaveHistoryState extends State<LeaveHistory> {
  // Sample leave history data
  final List<Map<String, dynamic>> leaveHistory = [
    {
      'id': 'LV001',
      'type': 'Casual Leave',
      'fromDate': DateTime(2024, 3, 15),
      'toDate': DateTime(2024, 3, 17),
      'days': 3,
      'reason': 'Family function',
      'status': 'Approved',
      'statusColor': Colors.green,
      'appliedOn': DateTime(2024, 3, 10),
      'approvedBy': 'Manager Rajesh',
      'document': 'function_invite.pdf',
    },
    {
      'id': 'LV002',
      'type': 'Sick Leave',
      'fromDate': DateTime(2024, 3, 5),
      'toDate': DateTime(2024, 3, 6),
      'days': 2,
      'reason': 'Viral fever',
      'status': 'Approved',
      'statusColor': Colors.green,
      'appliedOn': DateTime(2024, 3, 4),
      'approvedBy': 'HR Team',
      'document': 'medical_certificate.pdf',
    },
    {
      'id': 'LV003',
      'type': 'Earned Leave',
      'fromDate': DateTime(2024, 2, 20),
      'toDate': DateTime(2024, 2, 25),
      'days': 5,
      'reason': 'Vacation trip',
      'status': 'Pending',
      'statusColor': Colors.orange,
      'appliedOn': DateTime(2024, 2, 15),
      'approvedBy': '-',
      'document': null,
    },
    {
      'id': 'LV004',
      'type': 'Casual Leave',
      'fromDate': DateTime(2024, 2, 10),
      'toDate': DateTime(2024, 2, 12),
      'days': 3,
      'reason': 'Personal work',
      'status': 'Rejected',
      'statusColor': Colors.red,
      'appliedOn': DateTime(2024, 2, 5),
      'approvedBy': 'Manager Priya',
      'document': null,
      'rejectionReason': 'Insufficient team members',
    },
    {
      'id': 'LV005',
      'type': 'WFH',
      'fromDate': DateTime(2024, 1, 28),
      'toDate': DateTime(2024, 1, 28),
      'days': 1,
      'reason': 'Internet connectivity issue',
      'status': 'Approved',
      'statusColor': Colors.green,
      'appliedOn': DateTime(2024, 1, 27),
      'approvedBy': 'Tech Lead',
      'document': null,
    },
    {
      'id': 'LV006',
      'type': 'Compensatory Off',
      'fromDate': DateTime(2024, 1, 20),
      'toDate': DateTime(2024, 1, 20),
      'days': 1,
      'reason': 'Weekend work compensation',
      'status': 'Approved',
      'statusColor': Colors.green,
      'appliedOn': DateTime(2024, 1, 18),
      'approvedBy': 'Project Manager',
      'document': 'timesheet.pdf',
    },
    {
      'id': 'LV007',
      'type': 'Sick Leave',
      'fromDate': DateTime(2024, 1, 10),
      'toDate': DateTime(2024, 1, 12),
      'days': 3,
      'reason': 'Food poisoning',
      'status': 'Cancelled',
      'statusColor': Colors.grey,
      'appliedOn': DateTime(2024, 1, 9),
      'approvedBy': '-',
      'document': null,
      'cancelledBy': 'Self',
    },
    {
      'id': 'LV008',
      'type': 'Earned Leave',
      'fromDate': DateTime(2023, 12, 28),
      'toDate': DateTime(2024, 1, 2),
      'days': 5,
      'reason': 'New Year celebration',
      'status': 'Approved',
      'statusColor': Colors.green,
      'appliedOn': DateTime(2023, 12, 20),
      'approvedBy': 'HR Manager',
      'document': null,
    },
  ];

  // Filter states
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Date format
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');

  List<Map<String, dynamic>> get _filteredHistory {
    return leaveHistory.where((leave) {
      // Apply status filter
      if (_selectedFilter != 'All' && leave['status'] != _selectedFilter) {
        return false;
      }

      // Apply search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return leave['type'].toLowerCase().contains(query) ||
            leave['reason'].toLowerCase().contains(query) ||
            leave['id'].toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  // Statistics
  int get _totalLeaves => leaveHistory.length;
  int get _approvedLeaves => leaveHistory.where((l) => l['status'] == 'Approved').length;
  int get _pendingLeaves => leaveHistory.where((l) => l['status'] == 'Pending').length;
  int get _rejectedLeaves => leaveHistory.where((l) => l['status'] == 'Rejected').length;
  int get _cancelledLeaves => leaveHistory.where((l) => l['status'] == 'Cancelled').length;
  int get _totalDays => leaveHistory.fold(0, (sum, l) => sum + (l['days'] as int));

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        title: const Text("Leave History"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Column(
          children: [
            // Statistics Cards
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        label: 'Total',
                        value: '$_totalLeaves',
                        icon: Icons.event_note,
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        label: 'Approved',
                        value: '$_approvedLeaves',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      _buildStatCard(
                        label: 'Pending',
                        value: '$_pendingLeaves',
                        icon: Icons.pending,
                        color: Colors.orange,
                      ),
                      _buildStatCard(
                        label: 'Rejected',
                        value: '$_rejectedLeaves',
                        icon: Icons.cancel,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary_color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Days Taken:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$_totalDays days',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primary_color,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by leave type, reason, or ID...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('All', _selectedFilter == 'All'),
                  _buildFilterChip('Approved', _selectedFilter == 'Approved'),
                  _buildFilterChip('Pending', _selectedFilter == 'Pending'),
                  _buildFilterChip('Rejected', _selectedFilter == 'Rejected'),
                  _buildFilterChip('Cancelled', _selectedFilter == 'Cancelled'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Leave History List
            Expanded(
              child: _filteredHistory.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No leave records found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your filters',
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
                itemCount: _filteredHistory.length,
                itemBuilder: (context, index) {
                  final leave = _filteredHistory[index];
                  return _buildLeaveHistoryCard(leave);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
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
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: isSelected
            ? label == 'Approved'
            ? Colors.green.withOpacity(0.2)
            : label == 'Pending'
            ? Colors.orange.withOpacity(0.2)
            : label == 'Rejected'
            ? Colors.red.withOpacity(0.2)
            : label == 'Cancelled'
            ? Colors.grey.withOpacity(0.2)
            : primary_color.withOpacity(0.2)
            : null,
        checkmarkColor: isSelected
            ? label == 'Approved'
            ? Colors.green
            : label == 'Pending'
            ? Colors.orange
            : label == 'Rejected'
            ? Colors.red
            : label == 'Cancelled'
            ? Colors.grey
            : primary_color
            : null,
      ),
    );
  }

  Widget _buildLeaveHistoryCard(Map<String, dynamic> leave) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: leave['statusColor'].withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showLeaveDetails(leave),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header with ID and Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      leave['id'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      leave['type'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: leave['statusColor'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: leave['statusColor'],
                      ),
                    ),
                    child: Text(
                      leave['status'],
                      style: TextStyle(
                        color: leave['statusColor'],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Date Range
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_dateFormat.format(leave['fromDate'])} - ${_dateFormat.format(leave['toDate'])}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${leave['days']} ${leave['days'] == 1 ? 'day' : 'days'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Reason
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.description,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      leave['reason'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Footer with applied date and document
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            size: 12,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Attachment',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Rejection reason if any
              if (leave['status'] == 'Rejected' && leave['rejectionReason'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Rejected: ${leave['rejectionReason']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Cancellation info if any
              if (leave['status'] == 'Cancelled')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          size: 14,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Cancelled by ${leave['cancelledBy'] ?? 'System'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Filter Leave History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterOption('All', _selectedFilter == 'All'),
                        _buildFilterOption('Approved', _selectedFilter == 'Approved'),
                        _buildFilterOption('Pending', _selectedFilter == 'Pending'),
                        _buildFilterOption('Rejected', _selectedFilter == 'Rejected'),
                        _buildFilterOption('Cancelled', _selectedFilter == 'Cancelled'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSortOption('Newest First'),
                        _buildSortOption('Oldest First'),
                        _buildSortOption('Longest Leave'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primary_color,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
        Navigator.pop(context);
      },
      backgroundColor: Colors.white,
      selectedColor: isSelected ? primary_color.withOpacity(0.2) : null,
    );
  }

  Widget _buildSortOption(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: false,
      onSelected: (selected) {},
      backgroundColor: Colors.white,
    );
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
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
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

                  // Header with ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Leave Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: leave['statusColor'],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: leave['statusColor'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: leave['statusColor']),
                        ),
                        child: Text(
                          leave['status'],
                          style: TextStyle(
                            color: leave['statusColor'],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Leave ID
                  _buildDetailRow(
                    'Leave ID',
                    leave['id'],
                    Icons.confirmation_number,
                  ),

                  // Leave Type
                  _buildDetailRow(
                    'Leave Type',
                    leave['type'],
                    Icons.category,
                  ),

                  // Date Range
                  _buildDetailRow(
                    'Duration',
                    '${_dateFormat.format(leave['fromDate'])} - ${_dateFormat.format(leave['toDate'])}',
                    Icons.date_range,
                  ),

                  // Number of Days
                  _buildDetailRow(
                    'Total Days',
                    '${leave['days']} ${leave['days'] == 1 ? 'day' : 'days'}',
                    Icons.timer,
                  ),

                  // Reason
                  _buildDetailRow(
                    'Reason',
                    leave['reason'],
                    Icons.description,
                  ),

                  // Applied On
                  _buildDetailRow(
                    'Applied On',
                    _dateFormat.format(leave['appliedOn']),
                    Icons.calendar_today,
                  ),

                  // Approved By
                  _buildDetailRow(
                    'Approved By',
                    leave['approvedBy'] ?? '-',
                    Icons.person,
                  ),

                  // Document
                  if (leave['document'] != null)
                    _buildDetailRow(
                      'Attached Document',
                      leave['document'],
                      Icons.attach_file,
                    ),

                  // Rejection Reason
                  if (leave['status'] == 'Rejected' && leave['rejectionReason'] != null)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rejection Reason:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  leave['rejectionReason'],
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Action buttons for pending leaves
                  if (leave['status'] == 'Pending')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showCancelConfirmation(leave);
                            },
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel Request'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(Map<String, dynamic> leave) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Leave Request'),
        content: Text(
          'Are you sure you want to cancel your ${leave['type']} request from ${_dateFormat.format(leave['fromDate'])}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Leave request cancelled successfully'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}