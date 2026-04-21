import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Controller/Expense_Reimbursement_controller.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ExpenseReimbursement extends StatefulWidget {
  const ExpenseReimbursement({super.key});

  @override
  State<ExpenseReimbursement> createState() => _ExpenseReimbursementState();
}

class _ExpenseReimbursementState extends State<ExpenseReimbursement>
    with SingleTickerProviderStateMixin {

  Expense_Reimbursement controller = Expense_Reimbursement();
  late TabController _tabController;

  // Selected tab index
  int _selectedTabIndex = 0;


  // File attachment variables
  String? _fileName;
  int? _fileSize;
  bool _isUploading = false;

  // File attachment
  List<Map<String, dynamic>> _attachedFiles = [];


  // Date format
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _displayFormat = DateFormat('dd MMM yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
      locale: 'en_IN', symbol: '₹');

  // Expense categories
  final List<Map<String, dynamic>> _expenseCategories = [
    {
      'name': 'Travel',
      'icon': Icons.flight_takeoff,
      'color': Colors.blue,
      'budget': 5000,
      'spent': 3200
    },
    {
      'name': 'Food',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'budget': 3000,
      'spent': 1850
    },
    {
      'name': 'Fuel',
      'icon': Icons.local_gas_station,
      'color': Colors.green,
      'budget': 4000,
      'spent': 2100
    },
    {
      'name': 'Medical',
      'icon': Icons.medical_services,
      'color': Colors.red,
      'budget': 2000,
      'spent': 750
    },
    {
      'name': 'Stationery',
      'icon': Icons.inventory,
      'color': Colors.purple,
      'budget': 1000,
      'spent': 450
    },
    {
      'name': 'Internet',
      'icon': Icons.wifi,
      'color': Colors.teal,
      'budget': 1500,
      'spent': 1200
    },
    {
      'name': 'Mobile',
      'icon': Icons.phone_android,
      'color': Colors.pink,
      'budget': 1000,
      'spent': 800
    },
    {
      'name': 'Training',
      'icon': Icons.school,
      'color': Colors.indigo,
      'budget': 3000,
      'spent': 0
    },
  ];

  // Sample expense claims
  final List<Map<String, dynamic>> _expenseClaims = [
    {
      'id': 'EXP001',
      'title': 'Client Meeting Lunch',
      'category': 'Food',
      'amount': 1250.00,
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Approved',
      'statusColor': Colors.green,
      'billNo': 'BILL123',
      'submittedBy': 'Rahul Sharma',
      'remarks': 'Lunch with client at Taj Hotel',
    },
    {
      'id': 'EXP002',
      'title': 'Taxi to Airport',
      'category': 'Travel',
      'amount': 850.00,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'Pending',
      'statusColor': Colors.orange,
      'billNo': 'BILL456',
      'submittedBy': 'Rahul Sharma',
      'remarks': 'Airport pickup for business trip',
    },
    {
      'id': 'EXP003',
      'title': 'Fuel Reimbursement',
      'category': 'Fuel',
      'amount': 2100.00,
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'Approved',
      'statusColor': Colors.green,
      'billNo': 'BILL789',
      'submittedBy': 'Rahul Sharma',
      'remarks': 'Monthly fuel expenses',
    },
    {
      'id': 'EXP004',
      'title': 'Medical Consultation',
      'category': 'Medical',
      'amount': 1500.00,
      'date': DateTime.now().subtract(const Duration(days: 10)),
      'status': 'Rejected',
      'statusColor': Colors.red,
      'billNo': 'BILL101',
      'submittedBy': 'Rahul Sharma',
      'remarks': 'Doctor consultation fee',
      'rejectionReason': 'Bill not clear',
    },
    {
      'id': 'EXP005',
      'title': 'Office Supplies',
      'category': 'Stationery',
      'amount': 450.00,
      'date': DateTime.now().subtract(const Duration(days: 12)),
      'status': 'Paid',
      'statusColor': Colors.blue,
      'billNo': 'BILL202',
      'submittedBy': 'Rahul Sharma',
      'remarks': 'Printer paper and pens',
    },
  ];

  // Approval tracking
  final List<Map<String, dynamic>> _approvalSteps = [
    {
      'step': 'Submitted',
      'status': 'completed',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'by': 'Self'
    },
    {
      'step': 'Manager Approval',
      'status': 'completed',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'by': 'Rahul Sir'
    },
    {
      'step': 'Finance Review',
      'status': 'in_progress',
      'date': null,
      'by': null
    },
    {
      'step': 'Payment Processing',
      'status': 'pending',
      'date': null,
      'by': null
    },
    {'step': 'Amount Credited', 'status': 'pending', 'date': null, 'by': null},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    controller.dateController.text = _dateFormat.format(DateTime.now());
    controller.fetctExpenseCategory();
    getID();
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  getID() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    controller.userId = await sp.getString("user_id") ?? "";
  }

  Future<DateTime?> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    return picked;


    if (picked != null) {
      setState(() {
        controller.dateController.text = _dateFormat.format(picked);
      });
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'txt'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        setState(() {
          controller.selectedFile = File(file.path!);
          _fileName = file.name;
          _fileSize = file.size;
          _isUploading = false;
        });

        // Show success message
        _showSnackBar(
          "File '${file.name}' attached successfully",
          Colors.green,
        );
      }
    } catch (e) {
      _showSnackBar(
        "Error picking file: $e",
        Colors.red,
      );
    }
  }

  Future<void> _removeFile() async {
    setState(() {
      controller.selectedFile = null;
      _fileName = null;
      _fileSize = null;
    });

    _showSnackBar(
      "File removed",
      Colors.orange,
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }


  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double get _totalApproved {
    return _expenseClaims
        .where((e) => e['status'] == 'Approved' || e['status'] == 'Paid')
        .fold(0, (sum, e) => sum + (e['amount'] as double));
  }

  double get _totalPending {
    return _expenseClaims
        .where((e) => e['status'] == 'Pending')
        .fold(0, (sum, e) => sum + (e['amount'] as double));
  }

  double get _totalRejected {
    return _expenseClaims
        .where((e) => e['status'] == 'Rejected')
        .fold(0, (sum, e) => sum + (e['amount'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Reimbursement"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Dashboard", icon: Icon(Icons.dashboard)),
            Tab(text: "Add Expense", icon: Icon(Icons.add_circle)),
            Tab(text: "My Claims", icon: Icon(Icons.receipt)),
            Tab(text: "Approval", icon: Icon(Icons.gpp_good)),
          ],
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildAddExpenseTab(),
          _buildMyClaimsTab(),
          _buildApprovalTrackingTab(),
        ],
      ),
    );
  }

  // Tab 1: Dashboard with Category-wise Expense
  Widget _buildDashboardTab() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        label: 'Approved',
                        amount: _totalApproved,
                        icon: Icons.check_circle,
                        color: Colors.green.shade300,
                      ),
                      _buildSummaryItem(
                        label: 'Pending',
                        amount: _totalPending,
                        icon: Icons.pending,
                        color: Colors.orange.shade300,
                      ),
                      _buildSummaryItem(
                        label: 'Rejected',
                        amount: _totalRejected,
                        icon: Icons.cancel,
                        color: Colors.red.shade300,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Category-wise Expense
            const Text(
              "Category-wise Expenses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _expenseCategories.length,
              itemBuilder: (context, index) {
                final category = _expenseCategories[index];
                return _buildCategoryCard(category);
              },
            ),

            const SizedBox(height: 20),

            // Reimbursement Status Summary
            const Text(
              "Reimbursement Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
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
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatusPieChart(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusLegend(
                            'Approved', Colors.green, _totalApproved),
                        const SizedBox(height: 8),
                        _buildStatusLegend(
                            'Pending', Colors.orange, _totalPending),
                        const SizedBox(height: 8),
                        _buildStatusLegend(
                            'Rejected', Colors.red, _totalRejected),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required double amount,
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
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          _currencyFormat.format(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    double spentPercentage = (category['spent'] / category['budget']) * 100;
    Color progressColor = spentPercentage > 80 ? Colors.red : category['color'];

    return Card(
      elevation: 5,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: category['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category['icon'],
                    color: category['color'],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: category['color'],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '₹${category['spent']} / ₹${category['budget']}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: category['spent'] / category['budget'],
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPieChart() {
    // Simple pie chart representation
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Colors.green,
            Colors.green,
            Colors.orange,
            Colors.orange,
            Colors.red,
            Colors.red,
            Colors.green,
          ],
          stops: const [0.0, 0.5, 0.5, 0.7, 0.7, 0.9, 0.9],
        ),
      ),
      child: Center(
        child: Container(
          height: 70,
          width: 70,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${_expenseClaims.length}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLegend(String label, Color color, double amount) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Text(
          _currencyFormat.format(amount),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Tab 2: Add Expense Claim
  Widget _buildAddExpenseTab() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade500],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_circle, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add Expense Claim",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Submit your expense with bill photo",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Expense Title
              _buildLabel("Expense Title", Icons.title),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.expenseTitleController,
                decoration: _buildInputDecoration(
                    "e.g., Client Lunch", Icons.title),
              ),

              const SizedBox(height: 16),

              // Category Dropdown
              _buildLabel("Category", Icons.category),
              const SizedBox(height: 8),
              Obx(() {
                return DropdownButtonFormField(
                  value: controller.Selectedcategory,
                  decoration: _buildInputDecoration(
                      "Select category", Icons.category),
                  items: controller.expenseCategories.map((e) {
                    return DropdownMenuItem<String>(
                      child: Text(e["expences_name"],),
                      value: e["expences_name"],
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      controller.Selectedcategory = value!;
                      print(
                          "=========>category ${controller.Selectedcategory}");
                    });
                  },
                );
              }),

              const SizedBox(height: 16),

              // Amount
              _buildLabel("Amount (₹)", Icons.currency_rupee  ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.amountController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration(
                    "Enter amount", Icons.currency_rupee),
              ),

              const SizedBox(height: 16),

              // Date
              _buildLabel("Expense Date", Icons.calendar_today),
              const SizedBox(height: 8),
              Obx(() {
                return TextFormField(
                  controller: TextEditingController(text: controller.DateText),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await selectDate();
                    if (pickedDate != null) {
                      controller.date.value = pickedDate;
                    }
                  },
                  decoration: _buildInputDecoration(
                      "Select date", Icons.calendar_today,
                      suffixIcon: Icons.arrow_drop_down),
                );
              }),

              const SizedBox(height: 16),

              // Bill Photo Upload
              _buildLabel("Upload Bill Photo", Icons.camera_alt),
              const SizedBox(height: 8),
              // File picker button
              if (controller.selectedFile == null)
                InkWell(
                  onTap: _pickDocument,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap to upload Bill Photo",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Supported: PDF, DOC, DOCX, JPG, PNG, TXT",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // File info card when file is selected
              if (controller.selectedFile != null)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.green.withOpacity(0.05),
                  ),
                  child: Column(
                    children: [
                      // File details
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getFileIcon(_fileName ?? ''),
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          _fileName ?? 'Unknown file',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _fileSize != null
                              ? _formatFileSize(_fileSize!)
                              : 'Unknown size',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: _removeFile,
                        ),
                      ),

                      // File actions
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // View file
                                  _showSnackBar(
                                    "Opening file viewer...",
                                    Colors.blue,
                                  );
                                },
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text("View"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                  side: BorderSide(color: Colors.blue.shade200),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickDocument,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text("Replace"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.orange,
                                  side: BorderSide(
                                      color: Colors.orange.shade200),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Upload progress indicator
              if (_isUploading)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: null, // Indeterminate
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            primary_color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Uploading document...",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Description
              _buildLabel("Description", Icons.description),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                    "Describe the expense", Icons.description),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                   controller.expense_reimbursement(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Submit Claim",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab 3: My Claims (Reimbursement Status)
  Widget _buildMyClaimsTab() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterChip('All', 0),
                ),
                Expanded(
                  child: _buildFilterChip('Pending', 1),
                ),
                Expanded(
                  child: _buildFilterChip('Approved', 2),
                ),
                Expanded(
                  child: _buildFilterChip('Rejected', 3),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _expenseClaims.length,
              itemBuilder: (context, index) {
                final claim = _expenseClaims[index];
                return _buildClaimCard(claim);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: _selectedTabIndex == index,
        onSelected: (selected) {},
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildClaimCard(Map<String, dynamic> claim) {
    return Card(
      color: Colors.white,
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: claim['statusColor'].withOpacity(0.3)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: claim['statusColor'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt,
            color: claim['statusColor'],
            size: 20,
          ),
        ),
        title: Text(
          claim['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${claim['category']} • ${_currencyFormat.format(
                claim['amount'])}'),
            Text(
              _displayFormat.format(claim['date']),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: claim['statusColor'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: claim['statusColor']),
          ),
          child: Text(
            claim['status'],
            style: TextStyle(
              color: claim['statusColor'],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('Bill No', claim['billNo']),
                _buildDetailRow('Submitted By', claim['submittedBy']),
                _buildDetailRow('Remarks', claim['remarks']),
                if (claim['rejectionReason'] != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Rejected: ${claim['rejectionReason']}',
                            style: const TextStyle(color: Colors.red,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 4: Approval Tracking
  Widget _buildApprovalTrackingTab() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.purple.shade500],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Text(
                  "Approval Tracking",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Track your expense claim status",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Approval Steps
          Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(_approvalSteps.length, (index) {
                  final step = _approvalSteps[index];
                  return _buildApprovalStep(step, index);
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recent Approvals
          const Text(
            "Recent Approvals",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._expenseClaims.take(3).map((claim) {
            return Card(
              color: Colors.white,
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: claim['statusColor'].withOpacity(0.1),
                  child: Icon(
                      Icons.receipt, color: claim['statusColor'], size: 16),
                ),
                title: Text(claim['title']),
                subtitle: Text(_displayFormat.format(claim['date'])),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: claim['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    claim['status'],
                    style: TextStyle(color: claim['statusColor'], fontSize: 11),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildApprovalStep(Map<String, dynamic> step, int index) {
    IconData icon;
    Color color;

    switch (step['status']) {
      case 'completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'in_progress':
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        break;
      default:
        icon = Icons.radio_button_unchecked;
        color = Colors.grey;
    }

    return Row(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            if (index < _approvalSteps.length - 1)
              Container(
                height: 30,
                width: 2,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step['step'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: step['status'] == 'pending' ? Colors.grey : Colors
                      .black,
                ),
              ),
              if (step['date'] != null)
                Text(
                  '${_displayFormat.format(step['date'])} • by ${step['by']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primary_color),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon,
      {IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
      suffixIcon: suffixIcon != null ? Icon(
          suffixIcon, color: Colors.grey.shade500) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primary_color, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  IconData _getFileIcon(String fileName) {
    String extension = fileName
        .split('.')
        .last
        .toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

}