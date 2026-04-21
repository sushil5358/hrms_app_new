import 'package:flutter/material.dart';
import '../../../../utils/colers.dart';
import 'package:intl/intl.dart';

class TaxDeclaration extends StatefulWidget {
  const TaxDeclaration({super.key});

  @override
  State<TaxDeclaration> createState() => _TaxDeclarationState();
}

class _TaxDeclarationState extends State<TaxDeclaration> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Form controllers
  final _investmentAmountController = TextEditingController();
  final _rentAmountController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _medicalAmountController = TextEditingController();
  final _otherAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Financial Year
  String _selectedFinancialYear = "2024-25";
  final List<String> _financialYears = ["2024-25", "2023-24", "2022-23", "2021-22"];

  // Tax regimes
  String _selectedTaxRegime = "New Regime";
  final List<String> _taxRegimes = ["New Regime", "Old Regime"];

  // Investment categories
  final List<Map<String, dynamic>> _investmentCategories = [
    {
      'name': 'Section 80C',
      'icon': Icons.savings,
      'color': Colors.blue,
      'limit': 150000,
      'declared': 120000,
      'verified': 100000,
      'status': 'Partial',
      'description': 'PPF, ELSS, LIC, EPF, Tuition Fees, etc.',
    },
    {
      'name': 'Section 80D',
      'icon': Icons.health_and_safety,
      'color': Colors.green,
      'limit': 50000,
      'declared': 35000,
      'verified': 30000,
      'status': 'Partial',
      'description': 'Health Insurance Premium',
    },
    {
      'name': 'HRA',
      'icon': Icons.home,
      'color': Colors.orange,
      'limit': 120000,
      'declared': 96000,
      'verified': 96000,
      'status': 'Verified',
      'description': 'House Rent Allowance',
    },
    {
      'name': 'Section 24',
      'icon': Icons.account_balance,
      'color': Colors.purple,
      'limit': 200000,
      'declared': 180000,
      'verified': 150000,
      'status': 'Partial',
      'description': 'Home Loan Interest',
    },
    {
      'name': 'Section 80E',
      'icon': Icons.school,
      'color': Colors.teal,
      'limit': 50000,
      'declared': 0,
      'verified': 0,
      'status': 'Pending',
      'description': 'Education Loan Interest',
    },
    {
      'name': 'Section 80G',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'limit': 50000,
      'declared': 10000,
      'verified': 10000,
      'status': 'Verified',
      'description': 'Donations',
    },
  ];

  // Tax calculation summary
  final Map<String, dynamic> _taxSummary = {
    'grossIncome': 1200000,
    'exemptions': 200000,
    'standardDeduction': 50000,
    'netIncome': 950000,
    'deductions': 431000,
    'taxableIncome': 519000,
    'taxAmount': 28000,
    'cess': 1120,
    'totalTax': 29120,
  };

  // Declaration history
  final List<Map<String, dynamic>> _declarationHistory = [
    {
      'financialYear': '2023-24',
      'declaredAmount': 425000,
      'verifiedAmount': 400000,
      'status': 'Completed',
      'statusColor': Colors.green,
      'submittedDate': DateTime(2024, 3, 15),
    },
    {
      'financialYear': '2022-23',
      'declaredAmount': 380000,
      'verifiedAmount': 380000,
      'status': 'Completed',
      'statusColor': Colors.green,
      'submittedDate': DateTime(2023, 3, 20),
    },
    {
      'financialYear': '2021-22',
      'declaredAmount': 350000,
      'verifiedAmount': 320000,
      'status': 'Queried',
      'statusColor': Colors.orange,
      'submittedDate': DateTime(2022, 3, 10),
    },
  ];

  // Recent proofs
  final List<Map<String, dynamic>> _recentProofs = [
    {
      'name': 'PPF Statement',
      'category': 'Section 80C',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'size': '245 KB',
    },
    {
      'name': 'Health Insurance Premium',
      'category': 'Section 80D',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'size': '180 KB',
    },
    {
      'name': 'Rent Receipts',
      'category': 'HRA',
      'date': DateTime.now().subtract(const Duration(days: 7)),
      'size': '1.2 MB',
    },
  ];

  // Date format
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _investmentAmountController.dispose();
    _rentAmountController.dispose();
    _loanAmountController.dispose();
    _medicalAmountController.dispose();
    _otherAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  void _submitDeclaration() {
    _showSnackBar('Tax declaration submitted successfully', Colors.green);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tax Declaration"),
        backgroundColor: primary_color,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Dashboard", icon: Icon(Icons.dashboard)),
            Tab(text: "Declarations", icon: Icon(Icons.note_add)),
            Tab(text: "History", icon: Icon(Icons.history)),
          ],
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primary_color.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboardTab(),
            _buildDeclarationsTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  // Tab 1: Dashboard
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Financial Year Selector
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
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 12),
                const Text(
                  "Financial Year",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFinancialYear,
                      items: _financialYears.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFinancialYear = value!;
                        });
                      },
                      icon: const Icon(Icons.arrow_drop_down),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tax Regime Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.purple.shade500],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      "Tax Regime",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTaxRegime,
                          items: _taxRegimes.map((regime) {
                            return DropdownMenuItem(
                              value: regime,
                              child: Text(
                                regime,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTaxRegime = value!;
                            });
                          },
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildTaxRegimeInfo('Standard Deduction', '₹50,000', Icons.remove),
                      const Divider(color: Colors.white24),
                      _buildTaxRegimeInfo('Rebate Limit', '₹7,00,000', Icons.attach_money),
                      const Divider(color: Colors.white24),
                      _buildTaxRegimeInfo('Surcharge', '> ₹50 Lakhs', Icons.warning),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tax Calculation Summary
          const Text(
            "Tax Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryRow('Gross Income', _currencyFormat.format(_taxSummary['grossIncome'])),
                  _buildSummaryRow('Less: Exemptions', _currencyFormat.format(_taxSummary['exemptions']), color: Colors.green),
                  _buildSummaryRow('Less: Standard Deduction', _currencyFormat.format(_taxSummary['standardDeduction']), color: Colors.green),
                  const Divider(),
                  _buildSummaryRow('Net Income', _currencyFormat.format(_taxSummary['netIncome']), isBold: true),
                  _buildSummaryRow('Less: Deductions', _currencyFormat.format(_taxSummary['deductions']), color: Colors.green),
                  const Divider(),
                  _buildSummaryRow('Taxable Income', _currencyFormat.format(_taxSummary['taxableIncome']), isBold: true),
                  const Divider(),
                  _buildSummaryRow('Income Tax', _currencyFormat.format(_taxSummary['taxAmount'])),
                  _buildSummaryRow('Health & Education Cess', _currencyFormat.format(_taxSummary['cess'])),
                  const Divider(thickness: 2),
                  _buildSummaryRow(
                    'Total Tax Payable',
                    _currencyFormat.format(_taxSummary['totalTax']),
                    isBold: true,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recent Proofs
          const Text(
            "Recent Proofs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._recentProofs.map((proof) => _buildRecentProofCard(proof)),
        ],
      ),
    );
  }

  Widget _buildTaxRegimeInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProofCard(Map<String, dynamic> proof) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
        title: Text(proof['name']),
        subtitle: Text('${proof['category']} • ${proof['size']}'),
        trailing: Text(
          _dateFormat.format(proof['date']),
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  // Tab 2: Declarations
  Widget _buildDeclarationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                Icon(Icons.note_add, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Investment Declarations",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Declare your investments for tax benefits",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Investment Categories
          ..._investmentCategories.map((category) => _buildInvestmentCategoryCard(category)),

          const SizedBox(height: 24),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submitDeclaration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Submit Declaration",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentCategoryCard(Map<String, dynamic> category) {
    double declaredPercentage = (category['declared'] / category['limit']) * 100;
    double verifiedPercentage = (category['verified'] / category['limit']) * 100;

    Color getStatusColor(String status) {
      switch (status) {
        case 'Verified':
          return Colors.green;
        case 'Partial':
          return Colors.orange;
        default:
          return Colors.red;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: category['color'].withOpacity(0.3)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: category['color'].withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(category['icon'], color: category['color']),
        ),
        title: Text(
          category['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: category['color'],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Limit: ${_currencyFormat.format(category['limit'])}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: getStatusColor(category['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category['status'],
                    style: TextStyle(
                      color: getStatusColor(category['status']),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress bars
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Declared', style: TextStyle(fontSize: 12)),
                        Text(
                          '${_currencyFormat.format(category['declared'])} / ${_currencyFormat.format(category['limit'])}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: category['declared'] / category['limit'],
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(category['color']),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Verified', style: TextStyle(fontSize: 12)),
                        Text(
                          '${_currencyFormat.format(category['verified'])} / ${_currencyFormat.format(category['limit'])}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: category['verified'] / category['limit'],
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category['description'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),

                const SizedBox(height: 16),

                // Declaration Form
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Declared Amount',
                          prefixIcon: const Icon(Icons.currency_rupee, size: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: category['color'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: const Text('Update'),
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

  // Tab 3: History
  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade700, Colors.orange.shade500],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.history, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Declaration History",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "View your past tax declarations",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // History List
          ..._declarationHistory.map((record) => _buildHistoryCard(record)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record['financialYear'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: record['statusColor'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: record['statusColor']),
                  ),
                  child: Text(
                    record['status'],
                    style: TextStyle(
                      color: record['statusColor'],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHistoryItem('Declared', record['declaredAmount']),
                _buildHistoryItem('Verified', record['verifiedAmount']),
                _buildHistoryItem(
                  'Submitted',
                  _dateFormat.format(record['submittedDate']),
                  isDate: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String label, dynamic value, {bool isDate = false}) {
    return Column(
      children: [
        Text(
          isDate ? value : _currencyFormat.format(value),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}