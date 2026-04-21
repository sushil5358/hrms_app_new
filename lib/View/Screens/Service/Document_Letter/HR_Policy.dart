import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';

class HrPolicy extends StatefulWidget {
  const HrPolicy({super.key});

  @override
  State<HrPolicy> createState() => _HrPolicyState();
}

class _HrPolicyState extends State<HrPolicy> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Policy categories
  final List<Map<String, dynamic>> _policyCategories = [
    {
      'name': 'Leave Policy',
      'icon': Icons.beach_access,
      'color': Colors.blue,
      'count': 5,
    },
    {
      'name': 'Attendance Policy',
      'icon': Icons.access_time,
      'color': Colors.green,
      'count': 3,
    },
    {
      'name': 'Compensation & Benefits',
      'icon': Icons.attach_money,
      'color': Colors.orange,
      'count': 4,
    },
    {
      'name': 'Code of Conduct',
      'icon': Icons.gavel,
      'color': Colors.purple,
      'count': 6,
    },
    {
      'name': 'Travel Policy',
      'icon': Icons.flight_takeoff,
      'color': Colors.teal,
      'count': 3,
    },
    {
      'name': 'Training & Development',
      'icon': Icons.school,
      'color': Colors.pink,
      'count': 4,
    },
    {
      'name': 'Health & Safety',
      'icon': Icons.health_and_safety,
      'color': Colors.red,
      'count': 3,
    },
    {
      'name': 'IT & Security Policy',
      'icon': Icons.security,
      'color': Colors.indigo,
      'count': 5,
    },
  ];

  // HR Policies data
  final List<Map<String, dynamic>> _hrPolicies = [
    {
      'id': 'POL001',
      'title': 'Leave Policy 2024',
      'category': 'Leave Policy',
      'description': 'Comprehensive guide for all types of leaves including casual, sick, earned, and maternity/paternity leaves.',
      'lastUpdated': DateTime(2024, 1, 15),
      'version': 'v2.1',
      'fileSize': '245 KB',
      'isNew': true,
      'popular': true,
      'icon': Icons.beach_access,
      'color': Colors.blue,
      'sections': [
        'Annual Leave Entitlement',
        'Sick Leave Procedure',
        'Casual Leave Guidelines',
        'Maternity & Paternity Leave',
        'Leave Application Process',
      ],
    },
    {
      'id': 'POL002',
      'title': 'Work From Home Policy',
      'category': 'Attendance Policy',
      'description': 'Guidelines for remote work, eligibility criteria, and expectations for work-from-home arrangements.',
      'lastUpdated': DateTime(2024, 2, 10),
      'version': 'v1.5',
      'fileSize': '180 KB',
      'isNew': true,
      'popular': true,
      'icon': Icons.home_work,
      'color': Colors.green,
      'sections': [
        'Eligibility Criteria',
        'Work Hours & Availability',
        'Infrastructure Requirements',
        'Performance Expectations',
        'Approval Process',
      ],
    },
    {
      'id': 'POL003',
      'title': 'Performance Bonus Structure',
      'category': 'Compensation & Benefits',
      'description': 'Details about performance-based bonuses, calculation methods, and payout schedules.',
      'lastUpdated': DateTime(2024, 1, 5),
      'version': 'v3.0',
      'fileSize': '320 KB',
      'isNew': false,
      'popular': true,
      'icon': Icons.emoji_events,
      'color': Colors.orange,
      'sections': [
        'Bonus Eligibility',
        'Performance Metrics',
        'Calculation Methodology',
        'Payout Schedule',
        'Tax Implications',
      ],
    },
    {
      'id': 'POL004',
      'title': 'Code of Conduct Handbook',
      'category': 'Code of Conduct',
      'description': 'Expected behavior, ethical guidelines, and professional standards for all employees.',
      'lastUpdated': DateTime(2023, 12, 20),
      'version': 'v4.2',
      'fileSize': '410 KB',
      'isNew': false,
      'popular': false,
      'icon': Icons.handshake,
      'color': Colors.purple,
      'sections': [
        'Professional Behavior',
        'Confidentiality',
        'Conflict of Interest',
        'Workplace Ethics',
        'Reporting Violations',
      ],
    },
    {
      'id': 'POL005',
      'title': 'Travel & Expense Policy',
      'category': 'Travel Policy',
      'description': 'Guidelines for business travel, expense claims, reimbursement limits, and approval processes.',
      'lastUpdated': DateTime(2024, 2, 1),
      'version': 'v2.3',
      'fileSize': '295 KB',
      'isNew': true,
      'popular': false,
      'icon': Icons.flight,
      'color': Colors.teal,
      'sections': [
        'Travel Booking Guidelines',
        'Expense Limits',
        'Reimbursement Process',
        'International Travel',
        'Documentation Requirements',
      ],
    },
    {
      'id': 'POL006',
      'title': 'Training Reimbursement Policy',
      'category': 'Training & Development',
      'description': 'Policy for skill development, course reimbursements, and learning & development opportunities.',
      'lastUpdated': DateTime(2024, 1, 25),
      'version': 'v1.8',
      'fileSize': '210 KB',
      'isNew': false,
      'popular': false,
      'icon': Icons.school,
      'color': Colors.pink,
      'sections': [
        'Eligible Courses',
        'Reimbursement Limits',
        'Approval Process',
        'Post-Training Commitment',
        'Application Procedure',
      ],
    },
    {
      'id': 'POL007',
      'title': 'Workplace Safety Guidelines',
      'category': 'Health & Safety',
      'description': 'Safety protocols, emergency procedures, and health guidelines for the workplace.',
      'lastUpdated': DateTime(2024, 2, 5),
      'version': 'v3.1',
      'fileSize': '185 KB',
      'isNew': true,
      'popular': false,
      'icon': Icons.safety_check,
      'color': Colors.red,
      'sections': [
        'Emergency Procedures',
        'First Aid',
        'Fire Safety',
        'Workplace Ergonomics',
        'Incident Reporting',
      ],
    },
    {
      'id': 'POL008',
      'title': 'Data Security Policy',
      'category': 'IT & Security Policy',
      'description': 'Guidelines for data protection, password policies, and secure handling of company information.',
      'lastUpdated': DateTime(2024, 1, 18),
      'version': 'v5.0',
      'fileSize': '280 KB',
      'isNew': false,
      'popular': true,
      'icon': Icons.security,
      'color': Colors.indigo,
      'sections': [
        'Password Requirements',
        'Data Classification',
        'Access Control',
        'Incident Response',
        'Remote Access Security',
      ],
    },
  ];

  // Recent downloads
  final List<Map<String, dynamic>> _recentDownloads = [
    {
      'title': 'Leave Policy 2024',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.beach_access,
      'color': Colors.blue,
    },
    {
      'title': 'Work From Home Policy',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'icon': Icons.home_work,
      'color': Colors.green,
    },
    {
      'title': 'Performance Bonus Structure',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'icon': Icons.emoji_events,
      'color': Colors.orange,
    },
  ];

  // Date format
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPolicies {
    if (_searchQuery.isEmpty) {
      return _hrPolicies;
    }
    return _hrPolicies.where((policy) {
      return policy['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          policy['category'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          policy['description'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get _popularPolicies {
    return _hrPolicies.where((policy) => policy['popular'] == true).toList();
  }

  List<Map<String, dynamic>> get _newPolicies {
    return _hrPolicies.where((policy) => policy['isNew'] == true).toList();
  }

  void _downloadPolicy(Map<String, dynamic> policy) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${policy['title']}...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'Open',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _viewPolicyDetails(Map<String, dynamic> policy) {
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
                          color: policy['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          policy['icon'],
                          color: policy['color'],
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              policy['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              policy['category'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  _buildDetailSection('Description', policy['description']),

                  const SizedBox(height: 16),

                  // Metadata
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetaItem(Icons.update, 'Updated', _dateFormat.format(policy['lastUpdated'])),
                        _buildMetaItem(Icons.tag, 'Version', policy['version']),
                        _buildMetaItem(Icons.file_present, 'Size', policy['fileSize']),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sections
                  _buildDetailSection(
                    'Policy Sections',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: policy['sections'].map<Widget>((section) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: policy['color']),
                              const SizedBox(width: 8),
                              Expanded(child: Text(section)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Download Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _downloadPolicy(policy);
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download Policy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: policy['color'],
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

  Widget _buildMetaItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, dynamic content) {
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
        if (content is String)
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          )
        else
          content,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HR Policy"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: "All Policies", icon: Icon(Icons.menu_book)),
            Tab(text: "Categories", icon: Icon(Icons.category)),
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
            _buildAllPoliciesTab(),
            _buildCategoriesTab(),
          ],
        ),
      ),
    );
  }

  // Tab 1: All Policies
  Widget _buildAllPoliciesTab() {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search policies...",
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

        // Quick Access Section
        if (_searchQuery.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Quick Access",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("View All"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _popularPolicies.length,
              itemBuilder: (context, index) {
                final policy = _popularPolicies[index];
                return _buildQuickAccessCard(policy);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Policies List
        Expanded(
          child: _filteredPolicies.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No policies found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredPolicies.length,

            itemBuilder: (context, index) {
              final policy = _filteredPolicies[index];

              return _buildPolicyCard(policy);
            },
          ),
        ),
      ],
    );
  }

  // Tab 2: Categories
  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Downloads
          const Text(
            "Recent Downloads",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentDownloads.length,
              itemBuilder: (context, index) {
                final download = _recentDownloads[index];
                return _buildRecentDownloadCard(download);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Categories Grid
          const Text(
            "Policy Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: _policyCategories.length,
            itemBuilder: (context, index) {
              final category = _policyCategories[index];
              return _buildCategoryCard(category);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(Map<String, dynamic> policy) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _viewPolicyDetails(policy),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: policy['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(policy['icon'], color: policy['color'], size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        policy['title'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyCard(Map<String, dynamic> policy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: policy['color'].withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => _viewPolicyDetails(policy),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: policy['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(policy['icon'], color: policy['color'], size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                policy['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (policy['isNew'])
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          policy['category'],
                          style: TextStyle(
                            fontSize: 12,
                            color: policy['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                policy['description'],
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.update, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'Updated: ${_dateFormat.format(policy['lastUpdated'])}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.file_present, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        policy['fileSize'],
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewPolicyDetails(policy),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: policy['color'],
                        side: BorderSide(color: policy['color']),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadPolicy(policy),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: policy['color'],
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _searchQuery = category['name'];
            _tabController.animateTo(0);
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: category['color'],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${category['count']} policies',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentDownloadCard(Map<String, dynamic> download) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(download['icon'], color: download['color'], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      download['title'],
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _dateFormat.format(download['date']),
                      style: TextStyle(fontSize: 8, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}