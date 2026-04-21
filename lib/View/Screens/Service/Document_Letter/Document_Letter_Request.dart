import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Controller/Document_Letter_Requset_controller.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';

class DocumentLetterRequest extends StatefulWidget {
  const DocumentLetterRequest({super.key});

  @override
  State<DocumentLetterRequest> createState() => _DocumentLetterRequestState();
}

class _DocumentLetterRequestState extends State<DocumentLetterRequest>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  Document_letter_requestcontroller controller = Document_letter_requestcontroller();


  // Sample requests data
  final List<Map<String, dynamic>> _myRequests = [
    {
      'id': 'REQ001',
      'type': 'Experience Letter',
      'requestDate': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Approved',
      'statusColor': Colors.green,
      'document': 'experience_letter_2024.pdf',
      'purpose': 'Job Application',
    },
    {
      'id': 'REQ002',
      'type': 'Salary Certificate',
      'requestDate': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'Pending',
      'statusColor': Colors.orange,
      'document': null,
      'purpose': 'Loan Application',
      'forMonth': 'January 2024',
    },
    {
      'id': 'REQ003',
      'type': 'Experience Letter',
      'requestDate': DateTime.now().subtract(const Duration(days: 10)),
      'status': 'Rejected',
      'statusColor': Colors.red,
      'document': null,
      'purpose': 'Higher Studies',
      'rejectionReason': 'Insufficient tenure',
    },
    {
      'id': 'REQ004',
      'type': 'Salary Certificate',
      'requestDate': DateTime.now().subtract(const Duration(days: 15)),
      'status': 'Approved',
      'statusColor': Colors.green,
      'document': 'salary_certificate_dec_2023.pdf',
      'purpose': 'Visa Application',
      'forMonth': 'December 2023',
    },
  ];

  // Sample downloadable documents
  final List<Map<String, dynamic>> _downloadableDocs = [
    {
      'id': 'DOC001',
      'name': 'Experience Letter - March 2024',
      'type': 'Experience Letter',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'size': '245 KB',
      'icon': Icons.description,
      'color': Colors.blue,
    },
    {
      'id': 'DOC002',
      'name': 'Salary Certificate - February 2024',
      'type': 'Salary Certificate',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'size': '180 KB',
      'icon': Icons.receipt,
      'color': Colors.green,
    },
    {
      'id': 'DOC003',
      'name': 'Experience Letter - December 2023',
      'type': 'Experience Letter',
      'date': DateTime.now().subtract(const Duration(days: 45)),
      'size': '250 KB',
      'icon': Icons.description,
      'color': Colors.blue,
    },
    {
      'id': 'DOC004',
      'name': 'Salary Certificate - January 2024',
      'type': 'Salary Certificate',
      'date': DateTime.now().subtract(const Duration(days: 20)),
      'size': '190 KB',
      'icon': Icons.receipt,
      'color': Colors.green,
    },
    {
      'id': 'DOC005',
      'name': 'Experience Letter - November 2023',
      'type': 'Experience Letter',
      'date': DateTime.now().subtract(const Duration(days: 75)),
      'size': '240 KB',
      'icon': Icons.description,
      'color': Colors.blue,
    },
  ];

  // Date format
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _monthFormat = DateFormat('MMMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
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
    print("user id ===> ${controller.userId}");
  }

  Future<DateTime?> selectMonth() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _downloadDocument(Map<String, dynamic> doc) {
    _showSnackBar('Downloading ${doc['name']}...', Colors.blue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document & Letter Request"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: "Experience Letter", icon: Icon(Icons.work)),
            Tab(text: "Salary Certificate", icon: Icon(Icons.attach_money)),
            Tab(text: "Downloads", icon: Icon(Icons.download)),
          ],
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(

        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildExperienceLetterTab(),
            _buildSalaryCertificateTab(),
            _buildDownloadsTab(),
          ],
        ),
      ),
    );
  }

  // Tab 1: Experience Letter Request
  Widget _buildExperienceLetterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade500,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.work, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Experience Letter Request",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Request your work experience certificate",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Request Form
          Card(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Request Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Purpose Field
                  _buildLabel("Purpose of Request", Icons.question_answer),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.expPurposeController,
                    maxLines: 2,
                    decoration: _buildInputDecoration(
                      "e.g., Job Application, Higher Studies, Visa",
                      Icons.edit,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Additional Information
                  _buildLabel("Additional Information (Optional)", Icons.info),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.expAdditionalInfoController,
                    maxLines: 3,
                    decoration: _buildInputDecoration(
                      "Any specific details you want to include",
                      Icons.description,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.expirenceletter(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit Request",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recent Requests
          _buildRecentRequestsSection('Experience Letter'),
        ],
      ),
    );
  }

  // Tab 2: Salary Certificate Request
  Widget _buildSalaryCertificateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade500,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.attach_money, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Salary Certificate Request",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Request your salary certificate for specific months",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Request Form
          Card(
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Request Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Month Selection
                  _buildLabel("Select Month", Icons.calendar_today),
                  const SizedBox(height: 8),
                  Obx(() {
                    return TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: controller.fromDateText),
                      onTap: () async {
                        DateTime? pickedDate = await selectMonth();
                        if (pickedDate != null) {
                          controller.selectedMonth.value = pickedDate;
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Select date",
                        prefixIcon: const Icon(Icons.date_range),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (controller.selectedMonth.value == null) {
                          return 'Required';
                        }
                        return null;
                      },
                    );

                  }),

                  const SizedBox(height: 16),

                  // Purpose Field
                  _buildLabel("Purpose of Request", Icons.question_answer),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.salPurposeController,
                    maxLines: 2,
                    decoration: _buildInputDecoration(
                      "e.g., Loan Application, Visa, Tax Purpose",
                      Icons.edit,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Additional Information
                  _buildLabel("Additional Information (Optional)", Icons.info),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller.salAdditionalInfoController,
                    maxLines: 3,
                    decoration: _buildInputDecoration(
                      "Any specific details you want to include",
                      Icons.description,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.Salarycertificate(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Submit Request",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recent Requests
          _buildRecentRequestsSection('Salary Certificate'),
        ],
      ),
    );
  }

  // Tab 3: Downloads
  Widget _buildDownloadsTab() {
    return Column(
      children: [
        // Header Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.shade500,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.download, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Documents",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Download your approved documents",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search documents...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('All', true),
              _buildFilterChip('Experience Letter', false),
              _buildFilterChip('Salary Certificate', false),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Documents List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _downloadableDocs.length,
            itemBuilder: (context, index) {
              final doc = _downloadableDocs[index];
              return _buildDownloadableDocCard(doc);
            },
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
        onSelected: (selected) {},
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDownloadableDocCard(Map<String, dynamic> doc) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: doc['color'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(doc['icon'], color: doc['color']),
        ),
        title: Text(
          doc['name'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doc['type']),
            Row(
              children: [
                Text(
                  _dateFormat.format(doc['date']),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(" • ${doc['size']}", style: TextStyle(
                    fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: Colors.blue),
          onPressed: () => _downloadDocument(doc),
        ),
      ),
    );
  }

  Widget _buildRecentRequestsSection(String type) {
    final filteredRequests = _myRequests
        .where((r) => r['type'] == type)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Requests",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("View All"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        filteredRequests.isEmpty
            ? Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  "No recent requests",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        )
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredRequests.length > 3 ? 3 : filteredRequests.length,
          itemBuilder: (context, index) {
            final request = filteredRequests[index];
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: request['statusColor'].withOpacity(0.1),
                  child: Icon(
                    request['type'] == 'Experience Letter' ? Icons.work : Icons
                        .attach_money,
                    color: request['statusColor'],
                    size: 16,
                  ),
                ),
                title: Text(
                  request['purpose'],
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(_dateFormat.format(request['requestDate'])),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: request['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: request['statusColor']),
                  ),
                  child: Text(
                    request['status'],
                    style: TextStyle(
                      color: request['statusColor'],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
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

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey.shade500),
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
}